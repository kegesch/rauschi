use std::sync::Arc;
use rocket::futures::lock::Mutex;
use rocket::http::Status;
use rocket::request::{FromRequest, Outcome};
use rocket::serde::{json::Json, Deserialize, Serialize};
use rocket::{Request, State};
use rocket::response::{Responder};
use serde_json::json;
use crate::services::user_management::{UserError, UserManagement};
use crate::types::users::{UserIdentification};
use thiserror::Error;

#[derive(Error, Debug)]
pub enum UserRequestError {
    #[error("user error {0}")]
    UserError(#[from] UserError),
    #[error("bad request: {0}")]
    BadRequest(String),
}

impl <'r, 'o: 'r> Responder<'r, 'o> for UserRequestError {
    fn respond_to(self, request: &'r Request<'_>) -> rocket::response::Result<'o> {
        json!({
            "error": format!("{}", self)
        }).respond_to(request)
    }
}

#[derive(Debug, Clone, Deserialize, Serialize)]
pub struct UserRequest {
    name: String,
    number: Option<u16>,
}

#[post("/", format = "json", data = "<request>")]
pub async fn create_user(request: Json<UserRequest>, user_manager: &State<Arc<Mutex<dyn UserManagement>>>) -> Result<Json<UserIdentification>, UserRequestError> {
    let name = request.into_inner().name;

    let unique_user = user_manager.lock().await.register(name.as_str()).await?;

    println!("Created a new user {}", name);

    Ok(Json(unique_user))
}

#[post("/validate", format = "json", data = "<request>")]
pub async fn validate_user(request: Json<UserRequest>, user_manager: &State<Arc<Mutex<dyn UserManagement>>>) -> Result<Json<bool>, UserRequestError> {
    let user_request = request.into_inner();
    let name = user_request.name.clone();
    let number = user_request.number;


    if number.is_none() {
        return Err(UserRequestError::BadRequest("The parameter 'number' is missing.".to_string()));
    }
    println!("Validate user {}#{}", name, number.unwrap());

    let user_exists = user_manager.lock().await.user_already_exists(name.as_str(), number.unwrap()).await?;

    Ok(Json(user_exists))
}

#[derive(Debug, Clone, Deserialize, Serialize)]
pub struct TakeADrinkRequest {
    drink_value: f32,
}

/// Contains errors relating to the [BasicAuth] request guard
#[derive(Debug)]
pub enum AuthError {
    /// Length check fail or misc error
    BadCount,

    /// Header is invalid in formatting/encoding
    Invalid,
}

#[rocket::async_trait]
impl<'r> FromRequest<'r> for UserIdentification {
    type Error = AuthError;

    async fn from_request(request: &'r Request<'_>) -> Outcome<Self, Self::Error> {
        let keys: Vec<_> = request.headers().get("Authorization").collect();
        match keys.len() {
            0 => Outcome::Forward(()),
            1 => match UserIdentification::from_auth(keys[0]) {
                Some(auth_header) => Outcome::Success(auth_header),
                None => Outcome::Failure((Status::BadRequest, AuthError::Invalid)),
            },
            _ => Outcome::Failure((Status::BadRequest, AuthError::BadCount)),
        }
    }
}


#[post("/drink", format = "json", data = "<request>")]
pub async fn take_a_drink(auth: UserIdentification, request: Json<TakeADrinkRequest>, user_manager: &State<Arc<Mutex<dyn UserManagement>>>) -> Result<(), UserRequestError> {
    let drink_value = request.into_inner().drink_value;

    user_manager.lock().await.take_drink(auth.clone(), drink_value as f64).await?;
    println!("User {} took a drink", auth.user);
    Ok(())
}

#[get("/drink", format = "json")]
pub async fn get_drink_value(auth: UserIdentification, user_manager: &State<Arc<Mutex<dyn UserManagement>>>) -> Result<Json<f64>, UserRequestError> {
    let total_value = user_manager.lock().await.get_drink_value(auth.clone()).await?;
    println!("User {} fetched drink value", auth.user);
    Ok(Json(total_value))
}