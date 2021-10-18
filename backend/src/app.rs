#[macro_export]
macro_rules! create_app {
    ($pool:expr) => {{
        use crate::models::{brand, category, item};
        use actix_cors::Cors;
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
            .wrap(Cors::permissive())
            .wrap(middleware::Logger::default())
            .service(
                web::scope("/api/brands")
                    .service(brand::read_all)
                    .service(brand::read)
                    .service(brand::create)
                    .service(brand::update)
                    .service(brand::delete_all)
                    .service(brand::delete),
            )
            .service(
                web::scope("/api/categories")
                    .service(category::read_all)
                    .service(category::read)
                    .service(category::create)
                    .service(category::update)
                    .service(category::delete_all)
                    .service(category::delete),
            )
            .service(
                web::scope("/api/items")
                    .service(item::read_filter)
                    .service(item::read)
                    .service(item::create)
                    .service(item::update)
                    .service(item::delete_all)
                    .service(item::delete)
                    .service(item::upload_photo)
                    .service(item::retrieve_photo)
                    .service(item::delete_photo),
            )
    }};
}
