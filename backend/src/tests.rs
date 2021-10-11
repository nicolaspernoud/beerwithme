#[cfg(test)]
mod tests {
    use crate::models::{brand_tests::brand_test, item_tests::item_test};
    #[actix_rt::test]
    async fn test_models() {
        use diesel::r2d2::{self, ConnectionManager};
        use diesel::SqliteConnection;
        std::env::set_var("RUST_LOG", "actix_web=info");
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
        brand_test(&pool).await;
        item_test(&pool).await;
    }
}
