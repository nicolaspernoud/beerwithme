use actix_web::HttpRequest;
use serde::{Deserialize, Serialize};

use crate::{
    crud_create, crud_delete, crud_delete_all, crud_read, crud_update, crud_use,
    errors::ServerError,
    models::{brand::Brand, category::Category},
    schema::items,
};

macro_rules! trim {
    () => {
        fn trim(mut self) -> Self {
            self.name = self.name.trim().to_string();
            self.description = self.description.trim().to_string();
            self
        }
    };
}

#[derive(
    Debug,
    Clone,
    Serialize,
    Deserialize,
    Queryable,
    Insertable,
    AsChangeset,
    Identifiable,
    Associations,
)]
#[table_name = "items"]
#[belongs_to(Brand)]
pub struct Item {
    pub id: i32,
    pub brand_id: i32,
    pub category_id: i32,
    pub name: String,
    pub description: String,
    pub time: chrono::NaiveDateTime,
}
impl Item {
    trim!();
}

#[derive(Debug, Clone, Serialize, Deserialize, Insertable)]
#[table_name = "items"]
pub struct NewItem {
    pub brand_id: i32,
    pub category_id: i32,
    pub name: String,
    pub description: String,
}
impl NewItem {
    trim!();
}

crud_use!();
crud_create!(
    NewItem,
    Item,
    items,
    Brand,
    brands,
    brand_id,
    Category,
    categories,
    category_id
);

#[derive(Deserialize)]
pub struct Params {
    name: String,
}

#[get("")]
pub async fn read_filter(
    req: HttpRequest,
    pool: web::Data<DbPool>,
) -> Result<HttpResponse, ServerError> {
    let conn = pool.get()?;
    let params = web::Query::<Params>::from_query(req.query_string());
    let object: Vec<Item>;
    use crate::schema::items::dsl::*;
    match params {
        Ok(p) => {
            object = web::block(move || {
                items
                    .filter(name.like(format!("%{}%", p.name)))
                    .load::<Item>(&conn)
            })
            .await?;
        }
        Err(_) => {
            object = web::block(move || items.load::<Item>(&conn)).await?;
        }
    }
    Ok(HttpResponse::Ok().json(object))
}

crud_read!(Item, items);
crud_update!(
    Item,
    items,
    Brand,
    brands,
    brand_id,
    Category,
    categories,
    category_id
);
crud_delete!(Item, items);
crud_delete_all!(Item, items);
