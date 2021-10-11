use crate::create_app;

pub async fn item_test(
    pool: &r2d2::Pool<diesel::r2d2::ConnectionManager<diesel::SqliteConnection>>,
) {
    use crate::{do_test, do_test_extract_id};
    use actix_web::{
        http::{Method, StatusCode},
        test,
    };

    let mut app = test::init_service(create_app!(pool)).await;

    impl std::fmt::Display for crate::models::item::Item {
        fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
            write!(
                f,
                "{{\"id\":{},\"brand_id\":{},\"name\":\"{}\",\"description\":\"{}\"}}",
                self.id, self.brand_id, self.name, self.description
            )
        }
    }

    // Create a item with a non existing brand
    do_test!(
        app,
        Method::POST,
        "/api/item",
        "{\"brand_id\":1,\"name\":\"  Test item  \",\"description\":\"    Test description       \"}",
        StatusCode::NOT_FOUND,
        "Item not found"
    );

    let brand_id = do_test_extract_id!(
        app,
        Method::POST,
        "/api/brand",
        "{\"name\":\"  Test brand  \",\"description\":\"    Test description       \"}",
        StatusCode::OK,
        "{\"id\""
    );

    // Create a item with an existing brand
    let id = do_test_extract_id!(
            app,
            Method::POST,
            "/api/item",
            &format!("{{\"brand_id\":{},\"name\":\"  Test item  \",\"description\":\"    Test description       \"}}",brand_id),
            StatusCode::OK,
            "{\"id\""
        );

    // Get a item
    do_test!(
        app,
        Method::GET,
        &format!("/api/item/{}", id),
        "",
        StatusCode::OK,
        format!(
            "{{\"id\":{},\"brand_id\":{},\"name\":\"Test item\",\"description\":\"Test description\",\"time\":",
            id, brand_id
        )
    );

    // Get a non existing item
    do_test!(
        app,
        Method::GET,
        &format!("/api/item/{}", id + 1),
        "",
        StatusCode::NOT_FOUND,
        "Item not found"
    );

    // Patch the item
    do_test!(
        app,
        Method::PATCH,
        &format!("/api/item/{}", id),
        &crate::models::item::Item {
            id: id,
            brand_id: brand_id,
            name: String::from("   Patched name   "),
            description: String::from("   Patched description   "),
            time: chrono::Utc::now().naive_utc()
        },
        StatusCode::OK,
        format!("{{\"id\":{},\"brand_id\":{},\"name\":\"Patched name\",\"description\":\"Patched description\"",id,brand_id)
    );

    // Delete the item
    do_test!(
        app,
        Method::DELETE,
        &format!("/api/item/{}", id),
        "",
        StatusCode::OK,
        format!("Deleted object with id: {}", id)
    );

    // Delete a non existing item
    do_test!(
        app,
        Method::DELETE,
        &format!("/api/item/{}", id + 1),
        "",
        StatusCode::NOT_FOUND,
        "Item not found"
    );

    // Create two items and get them all
    let id1 = do_test_extract_id!(
        app,
        Method::POST,
        "/api/item",
        &format!(
            "{{\"brand_id\":{}, \"name\":\"01_name\",\"description\":\"01_description\"}}",
            brand_id
        ),
        StatusCode::OK,
        "{\"id\""
    );
    do_test!(
        app,
        Method::POST,
        "/api/item",
        &format!(
            "{{\"brand_id\":{}, \"name\":\"02_name\",\"description\":\"02_description\"}}",
            brand_id
        ),
        StatusCode::OK,
        "{\"id\""
    );
    do_test!(
        app,
        Method::GET,
        "/api/item/all",
        "",
        StatusCode::OK,
        format!(
            "[{{\"id\":{},\"brand_id\":{},\"name\":\"01_name\",\"description\":\"01_description\"",
            id1, brand_id
        )
    );

    // Delete all the items
    do_test!(
        app,
        Method::DELETE,
        "/api/item/all",
        "",
        StatusCode::OK,
        "Deleted all objects"
    );
}
