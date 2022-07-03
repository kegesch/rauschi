use std::sync::Arc;
use rocket::futures::lock::Mutex;
use rocket::http::Status;
use rocket::serde::{json::Json, Deserialize, Serialize};
use rocket::State;
use crate::services::user_manager::{UniqueUser, UserManager};

#[derive(Debug, Clone, Deserialize, Serialize)]
pub struct UserRequest {
    name: String,
}

#[post("/", format = "json", data = "<request>")]
pub async fn create_user(request: Json<UserRequest>, user_manager: &State<Arc<Mutex<UserManager>>>) -> Json<UniqueUser> {
    let name = request.into_inner().name;
    println!("Created a new user {}", name);

    let unique_user = user_manager.lock().await.register(name.as_str());

    Json(unique_user)
}