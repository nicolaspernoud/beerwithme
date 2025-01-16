use actix_web::error::{self};
use actix_web::{dev::ServiceRequest, Error};
use actix_web_httpauth::extractors::bearer::BearerAuth;

pub struct AppConfig {
    pub bearer_token: String,
}

impl AppConfig {
    pub fn new(token: String) -> Self {
        AppConfig {
            bearer_token: token,
        }
    }
}

pub async fn validator(
    req: ServiceRequest,
    credentials: BearerAuth,
) -> Result<ServiceRequest, (Error, ServiceRequest)> {
    let app_config = req
        .app_data::<actix_web::web::Data<AppConfig>>()
        .expect("Could not get token configuration");
    if app_config.bearer_token == credentials.token() {
        Ok(req)
    } else {
        Err((error::ErrorUnauthorized("Wrong token!"), req))
    }
}

#[macro_export]
macro_rules! create_app {
    ($pool:expr, $app_data:expr) => {{
        use $crate::models::{brand, category, item};
        use actix_cors::Cors;
        use actix_web::{error, middleware, web, web::Data, App, HttpResponse};
        use actix_web_httpauth::middleware::HttpAuthentication;

        App::new()
            .app_data(Data::new($pool.clone()))
            .app_data(
                web::JsonConfig::default()
                    .limit(4096)
                    .error_handler(|err, _req| {
                        error::InternalError::from_response(err, HttpResponse::Conflict().finish())
                            .into()
                    }),
            )
            .app_data(Data::clone($app_data))
            .wrap(Cors::permissive())
            .wrap(middleware::Logger::default())
            .service(
                web::scope("/api/brands")
                    .wrap(HttpAuthentication::bearer($crate::app::validator))
                    .service(brand::read_all)
                    .service(brand::read)
                    .service(brand::create)
                    .service(brand::update)
                    .service(brand::delete_all)
                    .service(brand::delete),
            )
            .service(
                web::scope("/api/categories")
                    .wrap(HttpAuthentication::bearer($crate::app::validator))
                    .service(category::read_all)
                    .service(category::read)
                    .service(category::create)
                    .service(category::update)
                    .service(category::delete_all)
                    .service(category::delete),
            )
            .service(
                web::scope("/api/items")
                    .wrap(HttpAuthentication::bearer($crate::app::validator))
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
            .service(actix_files::Files::new("/", "./web").index_file("index.html"))
    }};
}
