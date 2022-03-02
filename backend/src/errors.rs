use actix_web::error::BlockingError;
use actix_web::error::PayloadError;
use actix_web::error::ResponseError;
use actix_web::HttpResponse;
use image::ImageError;

#[derive(Debug)]
pub enum ServerError {
    R2D2,
    Blocking,
    Image,
}

impl std::fmt::Display for ServerError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            ServerError::R2D2 => write!(f, "R2D2 error"),
            ServerError::Blocking => write!(f, "Blocking error"),
            ServerError::Image => write!(f, "Image error"),
        }
    }
}

impl std::error::Error for ServerError {}

impl ResponseError for ServerError {
    fn error_response(&self) -> HttpResponse {
        match self {
            ServerError::R2D2 => HttpResponse::InternalServerError().body("R2D2 error"),
            ServerError::Blocking => HttpResponse::InternalServerError().body("Blocking error"),
            ServerError::Image => HttpResponse::InternalServerError().body("Image error"),
        }
    }
}

impl From<r2d2::Error> for ServerError {
    fn from(_: r2d2::Error) -> ServerError {
        ServerError::R2D2
    }
}

impl From<BlockingError> for ServerError {
    fn from(_: BlockingError) -> ServerError {
        ServerError::Blocking
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

impl From<ImageError> for ServerError {
    fn from(_err: ImageError) -> ServerError {
        ServerError::Image
    }
}
