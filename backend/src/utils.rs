use rand::{distr::Alphanumeric, rng, Rng};

pub fn random_string() -> std::string::String {
    rng()
        .sample_iter(&Alphanumeric)
        .take(48)
        .map(char::from)
        .collect()
}
