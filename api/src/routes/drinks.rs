use std::sync::Arc;
use rocket::futures::lock::Mutex;
use rocket::serde::json::Json;
use rocket::State;
use crate::DrinkManager;
use crate::types::drinks::Drink;

#[get("/", format = "json")]
pub async fn get_drinks(drink_manager: &State<Arc<Mutex<DrinkManager>>>) -> Json<Vec<Drink>> {
    println!("Requested all available drinks");

    Json(drink_manager.lock().await.get_drinks())
}

#[post("/", format = "json", data = "<drink>")]
pub async fn add_drink(drink: Json<Drink>, drink_manager: &State<Arc<Mutex<DrinkManager>>>) {
    println!("Add new drink");

    drink_manager.lock().await.add_drink(drink.into_inner());
}