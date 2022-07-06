#[macro_use]
extern crate rocket;

mod routes;
mod types;
mod services;
mod cors;

use std::sync::Arc;
use routes::drinks::{get_drinks, add_drink};
use routes::user::{create_user, validate_user, take_a_drink, get_drink_value};
use routes::parties::{get_near_parties, create_party, join_party};
use routes::get_precision;
use rocket::{Build, Rocket, routes};
use rocket::futures::lock::Mutex;
use crate::cors::CORS;
use crate::services::drink_manager::DrinkManager;
use crate::services::party_manager::PartyManager;
use crate::services::user_manager::UserManager;

const H3_PRECISION: u8 = 10;


pub fn configure(
) -> Rocket<Build> {
    let party_manager = Arc::new(Mutex::new(PartyManager::default()));
    let user_manager = Arc::new(Mutex::new(UserManager::default()));
    let drink_manager = Arc::new(Mutex::new(DrinkManager::default()));

    rocket::build()
        .manage(party_manager)
        .manage(user_manager)
        .manage(drink_manager)
        .attach(CORS)
        .mount("/drinks", routes![get_drinks, add_drink])
        .mount("/user", routes![create_user, validate_user, take_a_drink, get_drink_value])
        .mount("/party", routes![get_near_parties, create_party, join_party])
        .mount("/precision", routes![get_precision])
}


//noinspection RsMainFunctionNotFound
#[launch]
fn rocket() -> _ {
    configure()
}