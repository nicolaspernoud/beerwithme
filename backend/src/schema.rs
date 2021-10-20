table! {
    brands (id) {
        id -> Integer,
        name -> Text,
        description -> Text,
    }
}

table! {
    categories (id) {
        id -> Integer,
        name -> Text,
        description -> Text,
    }
}

table! {
    items (id) {
        id -> Integer,
        brand_id -> Integer,
        category_id -> Integer,
        name -> Text,
        alcohol -> Float,
        ibu -> Integer,
        description -> Text,
        rating -> Integer,
        time -> Timestamp,
    }
}

joinable!(items -> brands (brand_id));
joinable!(items -> categories (category_id));

allow_tables_to_appear_in_same_query!(
    brands,
    categories,
    items,
);
