use actix_web::error::BlockingError;
use actix_web::error::ResponseError;
use actix_web::HttpResponse;

#[derive(Debug)]
pub enum ServerError {
    R2D2Error,
    DieselError,
    DieselNotFoundError,
}

impl std::fmt::Display for ServerError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "Server Error")
    }
}

impl ResponseError for ServerError {
    fn error_response(&self) -> HttpResponse {
        match self {
            ServerError::R2D2Error => HttpResponse::InternalServerError().body("R2D2 error"),
            ServerError::DieselError => HttpResponse::InternalServerError().body("Diesel error"),
            ServerError::DieselNotFoundError => HttpResponse::NotFound().body("Item not found"),
        }
    }
}

impl From<r2d2::Error> for ServerError {
    fn from(_: r2d2::Error) -> ServerError {
        ServerError::R2D2Error
    }
}

impl From<diesel::result::Error> for ServerError {
    fn from(err: diesel::result::Error) -> ServerError {
        match err {
            diesel::result::Error::NotFound => ServerError::DieselNotFoundError,
            _ => ServerError::DieselError,
        }
    }
}

impl From<BlockingError<diesel::result::Error>> for ServerError {
    fn from(err: BlockingError<diesel::result::Error>) -> ServerError {
        match err {
            BlockingError::Error(e) => match e {
                diesel::result::Error::NotFound => ServerError::DieselNotFoundError,
                /*diesel::result::Error::InvalidCString(_) => todo!(),
                diesel::result::Error::DatabaseError(_, _) => todo!(),
                diesel::result::Error::QueryBuilderError(_) => todo!(),
                diesel::result::Error::DeserializationError(_) => todo!(),
                diesel::result::Error::SerializationError(_) => todo!(),
                diesel::result::Error::RollbackTransaction => todo!(),
                diesel::result::Error::AlreadyInTransaction => todo!(),
                diesel::result::Error::__Nonexhaustive => todo!(),*/
                _ => ServerError::DieselError,
            },
            BlockingError::Canceled => todo!(),
        }
    }
}
