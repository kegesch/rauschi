use rocket::serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Deserialize, Serialize)]
pub struct Drink {
    amount: f32,
    name: String,
    emoji: String,
    alcohol: f32,
}

impl Drink {
    pub fn _new(amount: f32, name: String, emoji: String, alcohol: f32) -> Self {
        Drink { amount, name, emoji, alcohol }
    }
}