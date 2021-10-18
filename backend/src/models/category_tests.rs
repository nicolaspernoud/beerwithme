use crate::create_app;

pub async fn category_test(
    pool: &r2d2::Pool<diesel::r2d2::ConnectionManager<diesel::SqliteConnection>>,
) {
    use crate::do_test;
    use actix_web::{
        http::{Method, StatusCode},
        test,
    };

    let mut app = test::init_service(create_app!(pool)).await;

    // Get default categories
    do_test!(
        app,
        Method::GET,
        "/api/categories",
        "",
        StatusCode::OK,
        r#"[{"id":1,"name":"Pale Lager & Pilsner""#
    );
}
