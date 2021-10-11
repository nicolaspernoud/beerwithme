#[macro_export]
macro_rules! create_app {
    ($pool:expr) => {{
        use crate::models::{brand, category, item};
        use actix_web::{error, middleware, web, App, HttpResponse};
        App::new()
            .data($pool.clone())
            .app_data(
                web::JsonConfig::default()
                    .limit(4096)
                    .error_handler(|err, _req| {
                        error::InternalError::from_response(err, HttpResponse::Conflict().finish())
                            .into()
                    }),
            )
            .wrap(middleware::Logger::default())
            .service(
                web::scope("/api/brand")
                    .service(brand::read_all)
                    .service(brand::read)
                    .service(brand::create)
                    .service(brand::update)
                    .service(brand::delete_all)
                    .service(brand::delete),
            )
            .service(
                web::scope("/api/category")
                    .service(category::read_all)
                    .service(category::read)
                    .service(category::create)
                    .service(category::update)
                    .service(category::delete_all)
                    .service(category::delete),
            )
            .service(
                web::scope("/api/item")
                    .service(item::read_all)
                    .service(item::read)
                    .service(item::create)
                    .service(item::update)
                    .service(item::delete_all)
                    .service(item::delete),
            )
    }};
}
