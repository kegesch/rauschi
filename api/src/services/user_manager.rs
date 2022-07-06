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
use crate::types::drinks::Drink;

/// Contains errors relating to the [BasicAuth] request guard
#[derive(Debug)]
pub enum AuthError {
    /// Length check fail or misc error
    BadCount,

    /// Header is invalid in formatting/encoding
    Invalid,
}

#[derive(Error, Debug, Serialize)]
pub enum UserError {
    #[error("user with authentication {0} is invalid")]
    InvalidAuthentication(UniqueUser),
}



#[derive(Debug, Clone, Deserialize, Serialize)]
pub struct UniqueUser {
    name: String,
    number: u16,
    secret: String,
}

impl Display for UniqueUser {
    fn fmt(&self, f: &mut Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}#{:04}", self.name, self.number)
    }
}

impl UniqueUser {
    pub fn new(name: &str, number: u16, secret: String) -> Self {
        Self {
            name: name.to_string(),
            number,
            secret: secret.to_string(),
        }
    }

    pub fn from_auth<S: Into<String>>(auth: S) -> Option<Self> {
        let auth_str: String = auth.into();
        let split_auth = auth_str.split(':').collect::<Vec<&str>>();
        if split_auth.len() != 3 {
            return None;
        }

        let name = split_auth[0].to_string();
        let number = split_auth[1].parse::<u16>();
        if number.is_err() {
            return None;
        }
        let secret = split_auth[2].to_string();

        Some(Self {
            name,
            number: number.unwrap(),
            secret,
        })
    }
}

#[rocket::async_trait]
impl<'r> FromRequest<'r> for UniqueUser {
    type Error = AuthError;

    async fn from_request(request: &'r Request<'_>) -> Outcome<Self, Self::Error> {
        let keys: Vec<_> = request.headers().get("Authorization").collect();
        match keys.len() {
            0 => Outcome::Forward(()),
            1 => match UniqueUser::from_auth(keys[0]) {
                Some(auth_header) => Outcome::Success(auth_header),
                None => Outcome::Failure((Status::BadRequest, AuthError::Invalid)),
            },
            _ => Outcome::Failure((Status::BadRequest, AuthError::BadCount)),
        }
    }
}

type DrinkValue<Tz> = (DateTime<Tz>, f64);

struct UserInformation {
    identification: UniqueUser,
    drinks: Vec<DrinkValue<Utc>>,
}

impl UserInformation {
    pub fn new(identification: UniqueUser) -> Self {
        Self {
            identification,
            drinks: vec![],
        }
    }
}

const REDUCE_AMOUNT_PER_HOUR: f64 = 1.5;

#[derive(Default)]
pub struct UserManager {
    users: Vec<UserInformation>,
}

fn cleanup_drinks<Tz: TimeZone>(relative_time: &DateTime<Tz>, drink_values: &mut Vec<DrinkValue<Tz>>) {
    drink_values.retain(|v| !((relative_time.clone() - v.0.clone()).num_hours() as f64 >= v.1 / REDUCE_AMOUNT_PER_HOUR))
}

fn get_random_4numbers() -> u16 {
    let mut rng = rand::thread_rng().gen_range(0..9999);
    rng as u16
}

fn get_random_secret() -> String {
    let random_bytes: Vec<u8> = (0..1024).map(|_| { rand::random::<u8>() }).collect();
    base64::encode(random_bytes)
}


impl UserManager {
    pub fn user_already_exists(&self, name: &str, number: u16) -> bool {
        self.users.iter().map(|u| &u.identification).any(|u| u.name.as_str() == name && u.number == number)
    }

    pub fn is_user_identification_valid<S: Into<String>>(&mut self, name: S, number: u16, secret: S) -> Option<&mut UserInformation> {
        let name_str = name.into();
        let secret_str = secret.into();
        self.users.iter_mut().find(|u| u.identification.name == name_str && u.identification.number == number && u.identification.secret == secret_str)
    }

    pub fn register(&mut self, name: &str) -> UniqueUser {
        loop {
            let number = get_random_4numbers();
            if !self.user_already_exists(name, number) {
                let secret = get_random_secret();
                let unique_user = UniqueUser::new(name, number, secret);
                self.users.push(UserInformation::new(unique_user.clone()));

                return unique_user;
            }
        }
    }

    pub fn take_drink(&mut self, identification: UniqueUser, drink_value: f64) -> Result<(), UserError> {
        if let Some(user) = self.is_user_identification_valid(identification.name.as_str(), identification.number, identification.secret.as_str()) {
            let now = Utc::now();
            cleanup_drinks(&now, &mut user.drinks);
            user.drinks.push((now, drink_value));
            Ok(())
        } else {
            Err(UserError::InvalidAuthentication(identification))
        }
    }

    pub fn get_drink_value(&mut self, identification: UniqueUser) -> Result<f64, UserError> {
        if let Some(user) = self.is_user_identification_valid(identification.name.as_str(), identification.number, identification.secret.as_str()) {
            let now = Utc::now();
            cleanup_drinks(&now,&mut user.drinks);
            let total_actual_drink_value = user.drinks.iter().map(|v| Self::calculate_time_based_drink_value(now, v)).sum();
            Ok(total_actual_drink_value)
        } else {
            Err(UserError::InvalidAuthentication(identification))
        }
    }

    fn calculate_time_based_drink_value<Tz: TimeZone>(relative_time: DateTime<Tz>, v: &DrinkValue<Tz>) -> f64 {
        f64::min(f64::max(0.0, v.1 - (relative_time - v.0.clone()).num_hours() as f64 * REDUCE_AMOUNT_PER_HOUR), v.1)
    }
}

#[cfg(test)]
mod tests {
    use chrono::{DateTime, Duration, TimeZone, Utc};

    #[test]
    pub fn calculate_time_based_drink_value_should_be_correct() {
        let datetime = DateTime::parse_from_rfc2822("01 Jun 2016 14:31:46 +0000").unwrap();
        let drink_value = (datetime, 2.0);
        let relative_time = datetime + Duration::hours(1);

        assert_eq!(super::UserManager::calculate_time_based_drink_value(relative_time, &drink_value), 0.5);
    }

    #[test]
    pub fn calculate_time_based_drink_value_should_not_be_negative() {
        let datetime = DateTime::parse_from_rfc2822("01 Jun 2016 14:31:46 +0000").unwrap();
        let drink_value = (datetime, 2.0);
        let relative_time = datetime + Duration::hours(2);

        assert_eq!(super::UserManager::calculate_time_based_drink_value(relative_time, &drink_value), 0.0);
    }

    #[test]
    pub fn calculate_time_based_drink_value_should_be_bigger_than_original() {
        let datetime = DateTime::parse_from_rfc2822("01 Jun 2016 14:31:46 +0000").unwrap();
        let drink_value = (datetime, 2.0);
        let relative_time = datetime - Duration::hours(1);

        assert_eq!(super::UserManager::calculate_time_based_drink_value(relative_time, &drink_value), 2.0);
    }
}

