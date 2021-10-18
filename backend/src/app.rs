use std::sync::Arc;

use actix_web::error::{self};
use actix_web::{dev::ServiceRequest, Error};
use actix_web_httpauth::extractors::bearer::BearerAuth;

#[derive(Clone)]
pub struct AppConfig {
    bearer_token: Arc<String>,
}

impl AppConfig {
    pub fn new(token: String) -> Self {
        AppConfig {
            bearer_token: Arc::new(token),
        }
    }
}

pub async fn validator(
    req: ServiceRequest,
    credentials: BearerAuth,
) -> Result<ServiceRequest, Error> {
    let app_config = req
        .app_data::<AppConfig>()
        .expect("Could not get token configuration");
    if *app_config.bearer_token == credentials.token() {
        Ok(req)
    } else {
        Err(error::ErrorUnauthorized("Wrong token!"))
    }
}

#[macro_export]
macro_rules! create_app {
    ($pool:expr, $app_config:expr) => {{
        use crate::models::{brand, category, item};
        use actix_cors::Cors;
        use actix_web::{error, middleware, web, App, HttpResponse};
        use actix_web_httpauth::middleware::HttpAuthentication;

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
            .app_data($app_config)
            .wrap(HttpAuthentication::bearer(crate::app::validator))
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
