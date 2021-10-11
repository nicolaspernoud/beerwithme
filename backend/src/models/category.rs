use serde::{Deserialize, Serialize};

use crate::{
    crud_create, crud_delete, crud_delete_all, crud_read, crud_read_all, crud_update, crud_use,
    errors::ServerError, schema::categories,
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
#[table_name = "categories"]
pub struct Category {
    pub id: i32,
    pub name: String,
    pub description: String,
}
impl Category {
    trim!();
}

#[derive(Debug, Clone, Serialize, Deserialize, Insertable)]
#[table_name = "categories"]
pub struct NewCategory {
    pub name: String,
    pub description: String,
}
impl NewCategory {
    trim!();
}

crud_use!();
crud_create!(NewCategory, Category, categories,);
crud_read_all!(Category, categories);
crud_read!(Category, categories);
crud_update!(Category, categories,);
crud_delete!(Category, categories);
crud_delete_all!(Category, categories);
