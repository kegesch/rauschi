use std::sync::Arc;
use rocket::futures::lock::Mutex;
use rocket::http::Status;
use rocket::request::{FromRequest, Outcome};
use rocket::response::status::BadRequest;
use rocket::serde::{json::Json, Deserialize, Serialize};
use rocket::{Request, State};
use crate::services::user_manager::{UniqueUser, UserError, UserManager};

#[derive(Debug, Clone, Deserialize, Serialize)]
pub struct UserRequest {
    name: String,
    number: Option<u16>,
}


#[post("/", format = "json", data = "<request>")]
pub async fn create_user(request: Json<UserRequest>, user_manager: &State<Arc<Mutex<UserManager>>>) -> Json<UniqueUser> {
    let name = request.into_inner().name;
    println!("Created a new user {}", name);

    let unique_user = user_manager.lock().await.register(name.as_str());

    Json(unique_user)
}

#[post("/validate", format = "json", data = "<request>")]
pub async fn validate_user(request: Json<UserRequest>, user_manager: &State<Arc<Mutex<UserManager>>>) -> Result<Json<bool>, BadRequest<String>> {
    let user_request = request.into_inner();
    let name = user_request.name.clone();
    let number = user_request.number;


    if number.is_none() {
        return Err(BadRequest(Option::from("The parameter 'number' is missing.".to_string())));
    }
    println!("Validate user {}#{}", name, number.unwrap());

    let user_exists = user_manager.lock().await.user_already_exists(name.as_str(), number.unwrap());

    Ok(Json(user_exists))
}

#[derive(Debug, Clone, Deserialize, Serialize)]
pub struct TakeADrinkRequest {
    drink_value: f32,
}

#[post("/drink", format = "json", data = "<request>")]
pub async fn take_a_drink(auth: UniqueUser, request: Json<TakeADrinkRequest>, user_manager: &State<Arc<Mutex<UserManager>>>) -> Result<(), Json<UserError>> {
    let drink_value = request.into_inner().drink_value;

    user_manager.lock().await.take_drink(auth.clone(), drink_value as f64)?;
    println!("User {} took a drink", auth);
    Ok(())
}

#[get("/drink", format = "json")]
pub async fn get_drink_value(auth: UniqueUser, user_manager: &State<Arc<Mutex<UserManager>>>) -> Result<Json<f64>, Json<UserError>> {
    let total_value = user_manager.lock().await.get_drink_value(auth.clone())?;
    println!("User {} fetched drink value", auth);
    Ok(Json(total_value))
}