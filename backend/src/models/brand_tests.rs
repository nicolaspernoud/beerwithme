use crate::create_app;

pub async fn brand_test(
    pool: &r2d2::Pool<diesel::r2d2::ConnectionManager<diesel::SqliteConnection>>,
) {
    use crate::{do_test, do_test_extract_id};
    use actix_web::{
        http::{Method, StatusCode},
        test,
    };

    let mut app = test::init_service(create_app!(pool)).await;

    // Create a brand
    let id = do_test_extract_id!(
        app,
        Method::POST,
        "/api/brand",
        "{\"name\":\"  Test brand  \",\"description\":\"    Test description       \"}",
        StatusCode::OK,
        "{\"id\""
    );

    // Get a brand
    do_test!(
        app,
        Method::GET,
        &format!("/api/brand/{}", id),
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
        &format!("/api/brand/{}", id + 1),
        "",
        StatusCode::NOT_FOUND,
        "Item not found"
    );

    // Patch the brand
    do_test!(
        app,
        Method::PATCH,
        &format!("/api/brand/{}", id),
        &format!("{{\"id\":{}, \"name\":\"  Patched test brand   \",\"description\":\"    Patched test description       \"}}",id),
        StatusCode::OK,
        "{\"id\""
    );

    // Delete the brand
    do_test!(
        app,
        Method::DELETE,
        &format!("/api/brand/{}", id),
        "",
        StatusCode::OK,
        format!("Deleted object with id: {}", id)
    );

    // Delete a non existing brand
    do_test!(
        app,
        Method::DELETE,
        &format!("/api/brand/{}", id + 1),
        "",
        StatusCode::NOT_FOUND,
        "Item not found"
    );

    // Delete all the brands
    let req = test::TestRequest::delete()
        .uri("/api/brand/all")
        .to_request();
    test::call_service(&mut app, req).await;

    // Create two brands and get them all
    let id1 = do_test_extract_id!(
        app,
        Method::POST,
        "/api/brand",
        "{\"name\":\"01_name\",\"description\":\"01_description\"}",
        StatusCode::OK,
        "{\"id\""
    );
    let id2 = do_test_extract_id!(
        app,
        Method::POST,
        "/api/brand",
        "{\"name\":\"02_name\",\"description\":\"02_description\"}",
        StatusCode::OK,
        "{\"id\""
    );
    do_test!(
        app,
        Method::GET,
        "/api/brand/all",
        "",
        StatusCode::OK,
        format!("[{{\"id\":{},\"name\":\"01_name\",\"description\":\"01_description\"}},{{\"id\":{},\"name\":\"02_name\",\"description\":\"02_description\"}}]", id1, id2)
    );

    // Delete all the brands
    do_test!(
        app,
        Method::DELETE,
        "/api/brand/all",
        "",
        StatusCode::OK,
        "Deleted all objects"
    );
}
