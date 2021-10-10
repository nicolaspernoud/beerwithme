#[macro_export]
macro_rules! crud_use {
    () => {
        use actix_web::{delete, get, patch, post, web, HttpResponse};
        use diesel::prelude::*;
        use diesel::r2d2::ConnectionManager;
        type DbPool = r2d2::Pool<ConnectionManager<SqliteConnection>>;
    };
}

#[macro_export]
macro_rules! crud_read {
    ($model:ty, $uri:expr, $table:tt) => {
        #[get($uri)]
        pub async fn read(
            pool: web::Data<DbPool>,
            oid: web::Path<i32>,
        ) -> Result<HttpResponse, ServerError> {
            let conn = pool.get()?;
            let object = web::block(move || {
                use crate::schema::$table::dsl::*;
                $table.filter(id.eq(oid.clone())).first::<$model>(&conn)
            })
            .await?;
            Ok(HttpResponse::Ok().json(object))
        }
    };
}

#[macro_export]
macro_rules! crud_read_all {
    ($model:ty, $uri:expr, $table:tt) => {
        #[get($uri)]
        pub async fn read_all(pool: web::Data<DbPool>) -> Result<HttpResponse, ServerError> {
            let conn = pool.get()?;
            let object = web::block(move || {
                use crate::schema::$table::dsl::*;
                $table.load::<$model>(&conn)
            })
            .await?;
            Ok(HttpResponse::Ok().json(object))
        }
    };
}

#[macro_export]
macro_rules! crud_create {
    ($inmodel:ty, $outmodel:ty, $uri:expr, $table:tt) => {
        #[post($uri)]
        pub async fn create(
            pool: web::Data<DbPool>,
            o: web::Json<$inmodel>,
        ) -> Result<HttpResponse, ServerError> {
            let conn = pool.get().expect("couldn't get db connection from pool");
            let created_o = web::block(move || {
                use crate::schema::$table::dsl::*;
                diesel::insert_into($table)
                    .values(o.clone().trim())
                    .execute(&conn)?;
                let o = $table.order(id.desc()).first::<$outmodel>(&conn)?;
                Ok(o)
            })
            .await?;
            Ok(HttpResponse::Ok().json(created_o))
        }
    };
}

#[macro_export]
macro_rules! crud_update {
    ($model:ty, $uri:expr, $table:tt) => {
        #[patch($uri)]
        pub async fn update(
            pool: web::Data<DbPool>,
            o: web::Json<$model>,
            oid: web::Path<i32>,
        ) -> Result<HttpResponse, ServerError> {
            let conn = pool.get().expect("couldn't get db connection from pool");
            let o_value = o.clone();
            let patched_o = web::block(move || {
                use crate::schema::$table::dsl::*;
                diesel::update($table)
                    .filter(id.eq(oid.clone()))
                    .set(o_value.trim())
                    .execute(&conn)?;
                $table.filter(id.eq(oid.clone())).first::<$model>(&conn)
            })
            .await?;
            Ok(HttpResponse::Ok().json(patched_o))
        }
    };
}

#[macro_export]
macro_rules! crud_delete {
    ($model:ty, $uri:expr, $table:tt) => {
        #[delete($uri)]
        pub async fn delete(
            pool: web::Data<DbPool>,
            oid: web::Path<i32>,
        ) -> Result<HttpResponse, ServerError> {
            let conn = pool.get().expect("couldn't get db connection from pool");
            let id = *oid;
            web::block(move || {
                use crate::schema::$table::dsl::*;
                let deleted = diesel::delete($table)
                    .filter(id.eq(oid.clone()))
                    .execute(&conn)?;
                match deleted {
                    0 => Err(diesel::result::Error::NotFound),
                    _ => Ok(deleted),
                }
            })
            .await?;
            Ok(HttpResponse::Ok().body(format!("Deleted object with id: {}", id)))
        }
    };
}

#[macro_export]
macro_rules! crud_delete_all {
    ($model:ty, $uri:expr, $table:tt) => {
        #[delete($uri)]
        pub async fn delete_all(pool: web::Data<DbPool>) -> Result<HttpResponse, ServerError> {
            let conn = pool.get().expect("couldn't get db connection from pool");
            web::block(move || {
                use crate::schema::$table::dsl::*;
                let deleted = diesel::delete($table).execute(&conn)?;
                match deleted {
                    0 => Err(diesel::result::Error::NotFound),
                    _ => Ok(deleted),
                }
            })
            .await?;
            Ok(HttpResponse::Ok().body(format!("Deleted all objects")))
        }
    };
}
