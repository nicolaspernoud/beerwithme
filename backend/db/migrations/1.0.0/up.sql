CREATE TABLE brands (
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    name VARCHAR NOT NULL,
    description VARCHAR NOT NULL
);

CREATE TABLE categories (
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    name VARCHAR NOT NULL,
    description VARCHAR NOT NULL
);

INSERT INTO
    categories (name, description)
VALUES
    (
        "Belgian Style",
        "Belgian beers are known for their spiced fruity flavors and high alcohol content."
    ),
    (
        "Brown Ale",
        "Brown ales feature malty overtones and tend to have toasty, caramel flavors."
    ),
    (
        "Dark Lager",
        "Dark lager is malty and smooth with toasted caramel flavors. These beers tend to have mid-range alcohol content and lower bitterness profiles."
    ),
    (
        "German Bock",
        "German bocks are heavy on malty flavor, making them sweet and nutty."
    ),
    (
        "India Pale Ale (IPA)",
        "IPAs boast strong hop bitterness with piney and floral flavors."
    ),
    (
        "Pale Ale",
        "Pale ales are generally hoppy but lower in alcohol content than IPAs."
    ),
    (
        "Pale Lager & Pilsner",
        "Pale lager and pilsners are golden-colored beers that are light in flavor and low in alcohol content."
    ),
    (
        "Porter",
        "Porters are all dark in color, and they feature flavors reminiscent of chocolate, coffee, and caramel."
    ),
    (
        "Specialty Beer",
        "Beers made with additional spices, flavorings, or fruits are called specialty beers."
    ),
    (
        "Stout",
        "Stouts are dark beers that are similar to porters but with stronger roasted flavors."
    ),
    (
        "Wheat Beer",
        "Wheat beers use wheat as their malt. They're generally lighter in color and alcohol content."
    ),
    (
        "Wild & Sour Ale",
        "Wild or sour ales are typically very low in alcohol, and feature tart, sour flavors that come from (safe) bacteria in the brew mash."
    );

CREATE TABLE items (
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    brand_id INTEGER NOT NULL,
    category_id INTEGER NOT NULL,
    name VARCHAR NOT NULL,
    alcohol REAL NOT NULL,
    ibu INTEGER NOT NULL,
    description VARCHAR NOT NULL,
    rating INTEGER NOT NULL,
    time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(brand_id) REFERENCES brands(id) ON DELETE CASCADE,
    FOREIGN KEY(category_id) REFERENCES categories(id) ON DELETE CASCADE
);