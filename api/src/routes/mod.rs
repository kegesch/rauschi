use rocket::serde::json::Json;
use crate::H3_PRECISION;

pub mod parties;
pub mod drinks;
pub mod user;

#[get("/")]
pub async fn get_precision() -> Json<u8> {
    Json(H3_PRECISION)
}