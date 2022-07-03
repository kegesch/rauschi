#[macro_use]
extern crate rocket;

mod routes;
mod types;
mod services;
mod cors;

use std::sync::Arc;
use routes::user::{create_user};
use routes::parties::{get_near_parties, create_party, join_party};
use routes::get_precision;
use rocket::{Build, Rocket, routes};
use rocket::futures::lock::Mutex;
use crate::cors::CORS;
use crate::services::party_manager::PartyManager;
use crate::services::user_manager::UserManager;

const H3_PRECISION: u8 = 10;


pub fn configure(
) -> Rocket<Build> {
    let party_manager = Arc::new(Mutex::new(PartyManager::default()));
    let user_manager = Arc::new(Mutex::new(UserManager::default()));

    rocket::build()
        .manage(party_manager)
        .manage(user_manager)
        .attach(CORS)
        .mount("/user", routes![create_user])
        .mount("/party", routes![get_near_parties, create_party, join_party])
        .mount("/precision", routes![get_precision])
}


//noinspection RsMainFunctionNotFound
#[launch]
fn rocket() -> _ {
    configure()
}