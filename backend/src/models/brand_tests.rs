use crate::{app::AppConfig, create_app};

pub async fn brand_test(
    pool: &r2d2::Pool<diesel::r2d2::ConnectionManager<diesel::SqliteConnection>>,
    app_config: AppConfig,
) {
    use crate::{do_test, do_test_extract_id};
    use actix_web::{
        http::{Method, StatusCode},
        test,
    };

    let mut app = test::init_service(create_app!(pool, app_config)).await;

    // Delete all the brands
    let req = test::TestRequest::delete()
        .header("Authorization", "Bearer 0101")
        .uri("/api/brands")
        .to_request();
    test::call_service(&mut app, req).await;

    // Create a brand
    let id = do_test_extract_id!(
        app,
        Method::POST,
        "/api/brands",
        "{\"name\":\"  Test brand  \",\"description\":\"    Test description       \"}",
        StatusCode::CREATED,
        "{\"id\""
    );

    // Try to create a brand with the same name
    do_test!(
        app,
        Method::POST,
        "/api/brands",
        "{\"name\":\"  Test brand  \",\"description\":\"    Test description       \"}",
        StatusCode::NOT_FOUND,
        "UNIQUE constraint failed: brands.name"
    );

    // Get a brand
    do_test!(
        app,
        Method::GET,
        &format!("/api/brands/{}", id),
        "",
        StatusCode::OK,
        format!(
            "{{\"id\":{},\"name\":\"Test brand\",\"description\":\"Test description\"}}",
            id
        )
    );

    // Get a non existing brand
    do_test!(
        app,
        Method::GET,
        &format!("/api/brands/{}", id + 1),
        "",
        StatusCode::NOT_FOUND,
        "Item not found"
    );

    // Patch the brand
    do_test!(
        app,
        Method::PUT,
        &format!("/api/brands/{}", id),
        &format!("{{\"id\":{}, \"name\":\"  Patched test brand   \",\"description\":\"    Patched test description       \"}}",id),
        StatusCode::OK,
        "{\"id\""
    );

    // Delete the brand
    do_test!(
        app,
        Method::DELETE,
        &format!("/api/brands/{}", id),
        "",
        StatusCode::OK,
        format!("Deleted object with id: {}", id)
    );

    // Delete a non existing brand
    do_test!(
        app,
        Method::DELETE,
        &format!("/api/brands/{}", id + 1),
        "",
        StatusCode::NOT_FOUND,
        "Item not found"
    );

    // Delete all the brands
    let req = test::TestRequest::delete()
        .header("Authorization", "Bearer 0101")
        .uri("/api/brands")
        .to_request();
    test::call_service(&mut app, req).await;

    // Create two brands and get them all
    let id1 = do_test_extract_id!(
        app,
        Method::POST,
        "/api/brands",
        "{\"name\":\"01_name\",\"description\":\"01_description\"}",
        StatusCode::CREATED,
        "{\"id\""
    );
    let id2 = do_test_extract_id!(
        app,
        Method::POST,
        "/api/brands",
        "{\"name\":\"02_name\",\"description\":\"02_description\"}",
        StatusCode::CREATED,
        "{\"id\""
    );
    do_test!(
        app,
        Method::GET,
        "/api/brands",
        "",
        StatusCode::OK,
        format!("[{{\"id\":{},\"name\":\"01_name\",\"description\":\"01_description\"}},{{\"id\":{},\"name\":\"02_name\",\"description\":\"02_description\"}}]", id1, id2)
    );

    // Delete all the brands
    do_test!(
        app,
        Method::DELETE,
        "/api/brands",
        "",
        StatusCode::OK,
        "Deleted all objects"
    );
}
