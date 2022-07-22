#[macro_use]
extern crate rocket;

mod routes;
mod types;
mod services;
mod cors;

use std::sync::Arc;
use bonsaidb::local::config::{Builder, StorageConfiguration};
use bonsaidb::local::{AsyncDatabase};
use platform_dirs::AppDirs;
use routes::drinks::{get_drinks, add_drink};
use routes::user::{create_user, validate_user, take_a_drink, get_drink_value};
use routes::parties::{get_near_parties, create_party, join_party};
use routes::get_precision;
use rocket::{Build, Rocket, routes};
use rocket::futures::lock::Mutex;
use crate::cors::CORS;
use crate::services::drink_manager::DrinkManager;
use crate::services::party_manager::PartyManager;
use services::user_management::bonsai_db_user_manager::DatabaseUserManager;
use crate::services::user_management::UserManagement;
use crate::types::db_schema::DbSchema;

const H3_PRECISION: u8 = 10;

pub fn configure(db: AsyncDatabase) -> Rocket<Build> {
    let party_manager = Arc::new(Mutex::new(PartyManager::default()));
    let user_manager = Arc::new(Mutex::new(DatabaseUserManager::new(db))) as Arc<Mutex<dyn UserManagement>>;
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
async fn rocket() -> _ {
    let database_dir = AppDirs::new(Some("rauschmelder"), false).unwrap().data_dir;
    let database_file = database_dir.join("db.bonsaidb");

    let db = AsyncDatabase::open::<DbSchema>(StorageConfiguration::new(database_file)).await.expect("Could not open database");

    configure(db)
}