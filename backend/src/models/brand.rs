use serde::{Deserialize, Serialize};

use crate::{
    crud_create, crud_delete, crud_delete_all, crud_read, crud_read_all, crud_update, crud_use,
    errors::ServerError, schema::brands,
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
    Debug, Clone, Serialize, Deserialize, Queryable, Insertable, AsChangeset, Identifiable,
)]
#[table_name = "brands"]
pub struct Brand {
    pub id: i32,
    pub name: String,
    pub description: String,
}
impl Brand {
    trim!();
}

#[derive(Debug, Clone, Serialize, Deserialize, Insertable)]
#[table_name = "brands"]
pub struct NewBrand {
    pub name: String,
    pub description: String,
}
impl NewBrand {
    trim!();
}

crud_use!();
crud_create!(NewBrand, Brand, "/brand", brands);
crud_read_all!(Brand, "/brand/all", brands);
crud_read!(Brand, "/brand/{oid}", brands);
crud_update!(Brand, "/brand/{oid}", brands);
crud_delete!(Brand, "/brand/{oid}", brands);
crud_delete_all!(Brand, "/brand/all", brands);
