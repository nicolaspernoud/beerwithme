use crate::{app::AppConfig, create_app};

pub async fn category_test(
    pool: &r2d2::Pool<diesel::r2d2::ConnectionManager<diesel::SqliteConnection>>,
    app_config: AppConfig,
) {
    use crate::do_test;
    use actix_web::{
        http::{Method, StatusCode},
        test,
    };

    let mut app = test::init_service(create_app!(pool, app_config)).await;

    // Get default categories
    do_test!(
        app,
        Method::GET,
        "/api/categories",
        "",
        StatusCode::OK,
        r#"[{"id":1,"name":"Belgian Style","#
    );
}
