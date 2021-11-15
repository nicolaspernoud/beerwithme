use actix_web::error::BlockingError;
use actix_web::error::PayloadError;
use actix_web::error::ResponseError;
use actix_web::HttpResponse;
use image::ImageError;

#[derive(Debug)]
pub enum ServerError {
    R2D2,
    Diesel,
    DieselNotFound,
    DieselDatabaseError(String),
    BlockingCanceled,
    Image,
}

impl std::fmt::Display for ServerError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            ServerError::R2D2 => write!(f, "R2D2 error"),
            ServerError::Diesel => write!(f, "Diesel error"),
            ServerError::DieselNotFound => write!(f, "Item not found"),
            ServerError::DieselDatabaseError(m) => write!(f, "{}", m),
            ServerError::BlockingCanceled => write!(f, "Blocking error"),
            ServerError::Image => write!(f, "Image error"),
        }
    }
}

impl std::error::Error for ServerError {}

impl ResponseError for ServerError {
    fn error_response(&self) -> HttpResponse {
        match self {
            ServerError::R2D2 => HttpResponse::InternalServerError().body("R2D2 error"),
            ServerError::Diesel => HttpResponse::InternalServerError().body("Diesel error"),
            ServerError::DieselNotFound => HttpResponse::NotFound().body("Item not found"),
            ServerError::DieselDatabaseError(m) => HttpResponse::NotFound().body(m),
            ServerError::BlockingCanceled => {
                HttpResponse::InternalServerError().body("Blocking error")
            }
            ServerError::Image => HttpResponse::InternalServerError().body("Image error"),
        }
    }
}

impl From<r2d2::Error> for ServerError {
    fn from(_: r2d2::Error) -> ServerError {
        ServerError::R2D2
    }
}

fn server_error_from_diesel_error(err: diesel::result::Error) -> ServerError {
    match err {
        diesel::result::Error::NotFound => ServerError::DieselNotFound,
        diesel::result::Error::DatabaseError(_, info) => {
            ServerError::DieselDatabaseError(info.message().to_string())
        }
        _ => ServerError::Diesel,
    }
}

impl From<diesel::result::Error> for ServerError {
    fn from(err: diesel::result::Error) -> ServerError {
        server_error_from_diesel_error(err)
    }
}

impl From<BlockingError<diesel::result::Error>> for ServerError {
    fn from(err: BlockingError<diesel::result::Error>) -> ServerError {
        match err {
            BlockingError::Error(e) => server_error_from_diesel_error(e),
            BlockingError::Canceled => ServerError::BlockingCanceled,
        }
    }
}

impl From<std::io::Error> for ServerError {
    fn from(_err: std::io::Error) -> ServerError {
        ServerError::Image
    }
}

impl From<PayloadError> for ServerError {
    fn from(_err: PayloadError) -> ServerError {
        ServerError::Image
    }
}

impl From<BlockingError<ImageError>> for ServerError {
    fn from(_err: BlockingError<ImageError>) -> ServerError {
        ServerError::Image
    }
}

impl From<ImageError> for ServerError {
    fn from(_err: ImageError) -> ServerError {
        ServerError::Image
    }
}

impl From<BlockingError<std::io::Error>> for ServerError {
    fn from(_err: BlockingError<std::io::Error>) -> ServerError {
        ServerError::Image
    }
}
