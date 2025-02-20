use actix_files::NamedFile;

use actix_web::{HttpRequest, Result};
use futures_util::StreamExt;
use image::GenericImageView;
use std::fs::{self};

use image::imageops::FilterType::Lanczos3;
use serde::{Deserialize, Serialize};

use crate::{
    crud_create, crud_delete_all, crud_read, crud_update, crud_use,
    errors::ServerError,
    models::{brand::Brand, category::Category},
    schema::items,
};

macro_rules! trim {
    () => {
        fn trim(&mut self) -> &Self {
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
#[diesel(table_name = items)]
#[diesel(belongs_to(Brand))]
pub struct Item {
    pub id: i32,
    pub brand_id: i32,
    pub category_id: i32,
    pub name: String,
    pub alcohol: f32,
    pub barcode: String,
    pub description: String,
    pub rating: i32,
    pub time: chrono::NaiveDateTime,
}
impl Item {
    trim!();
}

#[derive(Debug, Clone, Serialize, Deserialize, Insertable)]
#[diesel(table_name = items)]
pub struct NewItem {
    pub brand_id: i32,
    pub category_id: i32,
    pub name: String,
    pub alcohol: f32,
    pub barcode: String,
    pub description: String,
    pub rating: i32,
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
    barcode: String,
}

#[derive(Serialize)]
struct OutItem {
    brand_name: String,
    #[serde(flatten)]
    item: Item,
}

#[get("")]
pub async fn read_filter(
    req: HttpRequest,
    pool: web::Data<DbPool>,
) -> Result<HttpResponse, ServerError> {
    let mut conn = pool.get()?;
    let params = web::Query::<Params>::from_query(req.query_string());
    use crate::schema::items::dsl::*;
    let object = match params {
        Ok(p) => {
            web::block(move || {
                items
                    .inner_join(crate::schema::brands::table)
                    .filter(name.like(format!("%{}%", p.name)))
                    .or_filter(crate::schema::brands::name.like(format!("%{}%", p.name)))
                    .filter(barcode.like(format!("%{}%", p.barcode)))
                    .order((rating.desc(), name.asc()))
                    .load::<(Item, Brand)>(&mut conn)
            })
            .await?
        }
        Err(_) => {
            web::block(move || {
                items
                    .inner_join(crate::schema::brands::table)
                    .order((rating.desc(), name.asc()))
                    .load::<(Item, Brand)>(&mut conn)
            })
            .await?
        }
    };
    if let Ok(object) = object {
        let mut out_items: Vec<OutItem> = Vec::new();
        for o in object {
            out_items.push(OutItem {
                item: o.0,
                brand_name: o.1.name,
            })
        }
        Ok(HttpResponse::Ok().json(out_items))
    } else {
        let res = HttpResponse::NotFound().body("No objects found".to_string());
        Ok(res)
    }
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
crud_delete_all!(Item, items);

#[delete("/{oid}")]
pub async fn delete(
    pool: web::Data<DbPool>,
    oid: web::Path<i32>,
) -> Result<HttpResponse, ServerError> {
    let mut conn = pool.get()?;
    let oid = *oid;
    let d = web::block(move || {
        use crate::schema::items::dsl::*;
        let deleted = diesel::delete(items)
            .filter(id.eq(oid))
            .execute(&mut conn)?;
        match deleted {
            0 => Err(diesel::result::Error::NotFound),
            _ => Ok(deleted),
        }
    })
    .await?;
    let _ = web::block(move || fs::remove_file(photo_filename(oid))).await;
    if d.is_ok() {
        Ok(HttpResponse::Ok().body(format!("Deleted object with id: {}", oid)))
    } else {
        let res = HttpResponse::NotFound().body("Item not found");
        Ok(res)
    }
}

///////////////////////
// PHOTOS MANAGEMENT //
///////////////////////

const PHOTOS_PATH: &str = "data/items/photos";

#[post("/photos/{oid}")]
async fn upload_photo(
    oid: web::Path<i32>,
    mut body: web::Payload,
) -> Result<HttpResponse, ServerError> {
    fs::create_dir_all(PHOTOS_PATH)?;
    let filename = photo_filename(*oid);
    let mut bytes = web::BytesMut::new();
    while let Some(item) = body.next().await {
        bytes.extend_from_slice(&item?);
    }
    let r = web::block(move || image::load_from_memory(&bytes)).await?;

    if let Ok(r) = r {
        r.resize(
            std::cmp::min(1280, r.dimensions().0),
            std::cmp::min(1280, r.dimensions().1),
            Lanczos3,
        )
        .save_with_format(
            &filename,
            image::ImageFormat::from_extension("jpg").unwrap(),
        )?;
        Ok(HttpResponse::Ok().body(filename))
    } else {
        let res = HttpResponse::InternalServerError().body("Error loading image");
        Ok(res)
    }
}

#[get("/photos/{oid}")]
async fn retrieve_photo(oid: web::Path<i32>) -> Result<NamedFile> {
    Ok(NamedFile::open(photo_filename(*oid))?)
}

#[delete("/photos/{oid}")]
async fn delete_photo(oid: web::Path<i32>) -> Result<HttpResponse, ServerError> {
    let d = web::block(move || fs::remove_file(photo_filename(*oid))).await?;
    if d.is_ok() {
        Ok(HttpResponse::Ok().body("File deleted"))
    } else {
        let res = HttpResponse::NotFound().body("File not found");
        Ok(res)
    }
}

fn photo_filename(id: i32) -> String {
    format!("{path}/{id}.jpg", path = PHOTOS_PATH, id = id)
}
