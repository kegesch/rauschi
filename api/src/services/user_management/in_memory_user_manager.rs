use std::fmt::{Display, Formatter};
use std::ops::Sub;
use chrono::{Date, DateTime, TimeZone, Utc};
use rand::Rng;
use rand::rngs::OsRng;
use rocket::http::Status;
use rocket::Request;
use rocket::request::{FromRequest, Outcome};
use rocket::serde::{Deserialize, Serialize};
use thiserror::Error;
use crate::services::traits::user_management::UserManagement;
use crate::types::drinks::Drink;
use crate::types::users::UniqueUser;

#[derive(Default)]
pub struct InMemoryUserManager {
    users: Vec<UserInformation>,
}

impl UserManagement for InMemoryUserManager {
    fn user_already_exists(&self, name: &str, number: u16) -> bool {
        self.users.iter().map(|u| &u.identification).any(|u| u.name.as_str() == name && u.number == number)
    }

    fn is_user_identification_valid<S: Into<String>>(&mut self, name: S, number: u16, secret: S) -> Option<&mut UserInformation> {
        let name_str = name.into();
        let secret_str = secret.into();
        self.users.iter_mut().find(|u| u.identification.name == name_str && u.identification.number == number && u.identification.secret == secret_str)
    }
}
