#[cfg(test)]
mod tests {
    use actix_web::web::Data;

    use crate::{
        app::AppConfig,
        models::{brand_tests::brand_test, category_tests::category_test, item_tests::item_test},
    };
    #[actix_rt::test]
    async fn test_models() {
        use diesel::r2d2::{self, ConnectionManager};
        use diesel::SqliteConnection;
        std::env::set_var("RUST_LOG", "debug");
        env_logger::init();

        // set up database connection pool
        let manager = ConnectionManager::<SqliteConnection>::new("db/test_db.sqlite");
        let pool = r2d2::Pool::builder()
            .build(manager)
            .expect("Failed to create pool.");
        embed_migrations!("db/migrations");
        embedded_migrations::run_with_output(
            &pool.get().expect("couldn't get db connection from pool"),
            &mut std::io::stdout(),
        )
        .expect("couldn't run migrations");

        // Set up authorization token
        let app_config = AppConfig::new("0101".to_string());
        let app_data = Data::new(app_config);

        brand_test(&pool, &app_data).await;
        category_test(&pool, &app_data).await;
        item_test(&pool, &app_data).await;
    }
}
