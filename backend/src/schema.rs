table! {
    brands (id) {
        id -> Integer,
        name -> Text,
        description -> Text,
    }
}

table! {
    items (id) {
        id -> Integer,
        brand_id -> Integer,
        name -> Text,
        description -> Text,
        time -> Timestamp,
    }
}

joinable!(items -> brands (brand_id));

allow_tables_to_appear_in_same_query!(
    brands,
    items,
);
