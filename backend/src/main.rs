//! Actix web Diesel integration example
//!
//! Diesel does not support tokio, so we have to run it in separate threads using the web::block
//! function which offloads blocking code (like Diesel's) in order to not block the server's thread.

#[macro_use]
extern crate diesel;
#[macro_use]
extern crate diesel_migrations;

use actix_web::HttpServer;
use diesel::prelude::*;
use diesel::r2d2::{self, ConnectionManager};

mod app;
mod errors;
mod models;
mod schema;
#[cfg(test)]
pub mod tester;
#[cfg(test)]
mod tests;

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    std::env::set_var("RUST_LOG", "actix_web=info");
    env_logger::init();

    // set up database connection pool
    let manager = ConnectionManager::<SqliteConnection>::new("db/db.sqlite");
    let pool = r2d2::Pool::builder()
        .build(manager)
        .expect("Failed to create pool.");
    embed_migrations!("db/migrations");
    embedded_migrations::run_with_output(
        &pool.get().expect("couldn't get db connection from pool"),
        &mut std::io::stdout(),
    )
    .expect("couldn't run migrations");

    let bind = "127.0.0.1:8080";

    println!("Starting server at: {}", &bind);

    // Start HTTP server
    HttpServer::new(move || create_app!(pool))
        .bind(&bind)?
        .run()
        .await
}
