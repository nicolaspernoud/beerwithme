use crate::{app::AppConfig, create_app};

pub async fn item_test(
    pool: &r2d2::Pool<diesel::r2d2::ConnectionManager<diesel::SqliteConnection>>,
    app_config: AppConfig,
) {
    use crate::{do_test, do_test_extract_id};
    use actix_web::{
        http::{Method, StatusCode},
        test,
    };

    let mut app = test::init_service(create_app!(pool, app_config)).await;

    impl std::fmt::Display for crate::models::item::Item {
        fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
            write!(
                f,
                "
                id: {}\n
                brand_id: {}\n
                category_id: {}\n
                name: {}\n
                alcohol: {}\n
                barcode: {}\n
                description: {}\n
                rating: {}\n
                ",
                self.id,
                self.brand_id,
                self.category_id,
                self.name,
                self.alcohol,
                self.barcode,
                self.description,
                self.rating
            )
        }
    }

    // Check that using the wrong token gives an unauthorized error
    let req = test::TestRequest::with_uri("/api/items")
        .method(Method::GET)
        .header("Authorization", "Bearer 0102")
        .to_request();
    use actix_web::dev::Service;
    let resp = app.call(req).await;
    assert!(resp.is_err());
    assert!(resp.err().unwrap().to_string() == "Wrong token!");

    // Create a item with a non existing brand
    do_test!(
        app,
        Method::POST,
        "/api/items",
        r#"{"brand_id":1,"category_id":6,"name":"  Test item  ","description":"    Test description       ","alcohol":5.0,"barcode":"my barcode","rating":5}"#,
        StatusCode::NOT_FOUND,
        "Item not found"
    );

    let brand_id = do_test_extract_id!(
        app,
        Method::POST,
        "/api/brands",
        r#"{"name":"  Test brand  ","description":"    Test description       "}"#,
        StatusCode::CREATED,
        "{\"id\""
    );

    // Create a item with an non existing category
    do_test!(
        app,
        Method::POST,
        "/api/items",
        &format!(
            r#"{{"brand_id":{},"category_id":106,"name":"  Test item  ","description":"    Test description       ","alcohol":5.0,"barcode":"my barcode","rating":5}}"#,
            brand_id
        ),
        StatusCode::NOT_FOUND,
        "Item not found"
    );

    // Create a item with an existing brand and category
    let id = do_test_extract_id!(
        app,
        Method::POST,
        "/api/items",
        &format!(
            r#"{{"brand_id":{},"category_id":6,"name":"  Test item  ","description":"    Test description       ","alcohol":5.0,"barcode":"my barcode","rating":5}}"#,
            brand_id
        ),
        StatusCode::CREATED,
        "{\"id\""
    );

    // Get a item
    do_test!(
        app,
        Method::GET,
        &format!("/api/items/{}", id),
        "",
        StatusCode::OK,
        format!(
            r#"{{"id":{},"brand_id":{},"category_id":6,"name":"Test item","alcohol":5.0,"barcode":"my barcode","description":"Test description","rating":5,"time":"#,
            id, brand_id
        )
    );

    // Get a non existing item
    do_test!(
        app,
        Method::GET,
        &format!("/api/items/{}", id + 1),
        "",
        StatusCode::NOT_FOUND,
        "Item not found"
    );

    // Patch the item
    do_test!(
        app,
        Method::PUT,
        &format!("/api/items/{}", id),
        &crate::models::item::Item {
            id: id,
            brand_id: brand_id,
            category_id: 6,
            name: String::from("   Patched name   "),
            alcohol: 5.0,
            barcode: String::from("my barcode"),
            description: String::from("   Patched description   "),
            rating: 5,
            time: chrono::Utc::now().naive_utc()
        },
        StatusCode::OK,
        format!(
            r#"{{"id":{},"brand_id":{},"category_id":6,"name":"Patched name","alcohol":5.0,"barcode":"my barcode","description":"Patched description","rating":5"#,
            id, brand_id
        )
    );

    // Delete the item
    do_test!(
        app,
        Method::DELETE,
        &format!("/api/items/{}", id),
        "",
        StatusCode::OK,
        format!("Deleted object with id: {}", id)
    );

    // Delete a non existing item
    do_test!(
        app,
        Method::DELETE,
        &format!("/api/items/{}", id + 1),
        "",
        StatusCode::NOT_FOUND,
        "Item not found"
    );

    // Create two items and get them all
    let id1 = do_test_extract_id!(
        app,
        Method::POST,
        "/api/items",
        &format!(
            r#"{{"brand_id":{},"category_id":6, "name":"01_name","description":"01_description","alcohol":5.0,"barcode":"my barcode","rating":5}}"#,
            brand_id
        ),
        StatusCode::CREATED,
        "{\"id\""
    );
    let id2 = do_test_extract_id!(
        app,
        Method::POST,
        "/api/items",
        &format!(
            r#"{{"brand_id":{},"category_id":6, "name":"02_name","description":"02_description","alcohol":5.0,"barcode":"my barcode","rating":5}}"#,
            brand_id
        ),
        StatusCode::CREATED,
        "{\"id\""
    );
    do_test!(
        app,
        Method::GET,
        "/api/items",
        "",
        StatusCode::OK,
        format!(
            r#"[{{"id":{},"brand_id":{},"category_id":6,"name":"01_name","alcohol":5.0,"barcode":"my barcode","description":"01_description","rating":5"#,
            id1, brand_id
        )
    );
    do_test!(
        app,
        Method::GET,
        "/api/items?name=02",
        "",
        StatusCode::OK,
        format!(
            r#"[{{"id":{},"brand_id":{},"category_id":6,"name":"02_name","alcohol":5.0,"barcode":"my barcode","description":"02_description","rating":5"#,
            id2, brand_id
        )
    );

    // Delete all the items
    do_test!(
        app,
        Method::DELETE,
        "/api/items",
        "",
        StatusCode::OK,
        "Deleted all objects"
    );

    //////////////////
    // PHOTOS TESTS //
    //////////////////

    // Create an item
    let id = do_test_extract_id!(
        app,
        Method::POST,
        "/api/items",
        &format!(
            r#"{{"brand_id":{},"category_id":6, "name":"01_name","description":"01_description","alcohol":5.0,"barcode":"my barcode","rating":5}}"#,
            brand_id
        ),
        StatusCode::CREATED,
        "{\"id\""
    );

    // Upload a photo for this item
    let img_body = std::fs::read("test_img.jpg").unwrap();
    let req = test::TestRequest::with_uri(format!("/api/items/photos/{}", id).as_str())
        .method(Method::POST)
        .header("Authorization", "Bearer 0101")
        .set_payload(img_body.clone())
        .to_request();
    let resp = test::call_service(&mut app, req).await;
    assert_eq!(resp.status(), StatusCode::OK);

    // Retrieve the photo
    let req = test::TestRequest::with_uri(format!("/api/items/photos/{}", id).as_str())
        .method(Method::GET)
        .header("Authorization", "Bearer 0101")
        .to_request();
    let resp = test::call_service(&mut app, req).await;
    assert_eq!(resp.status(), StatusCode::OK);
    let body = test::read_body(resp).await;
    assert_eq!(body, img_body);

    // Delete the item
    do_test!(
        app,
        Method::DELETE,
        &format!("/api/items/{}", id),
        "",
        StatusCode::OK,
        format!("Deleted object with id: {}", id)
    );

    // Check that the photo is gone too
    let req = test::TestRequest::with_uri(format!("/api/items/photos/{}", id).as_str())
        .method(Method::GET)
        .header("Authorization", "Bearer 0101")
        .to_request();
    let resp = test::call_service(&mut app, req).await;
    assert_eq!(resp.status(), StatusCode::NOT_FOUND);
}
