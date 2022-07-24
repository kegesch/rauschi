pub mod bonsai_db_user_manager;

use thiserror::Error;

const REDUCE_AMOUNT_PER_HOUR: f64 = 1.5;

#[derive(Error, Debug)]
pub enum UserError {
    #[error("user with authentication {0} is invalid")]
    InvalidAuthentication(UserIdentification),
    #[error("error with db: {0}")]
    DatabaseError(#[from] BonsaiDbError),
}

fn cleanup_drinks(relative_time: &DateTime<Utc>, drink_values: &mut Vec<DrinkValue>) {
    drink_values.retain(|v| !((*relative_time - v.0).num_hours() as f64 >= v.1 / REDUCE_AMOUNT_PER_HOUR))
}

fn get_random_4numbers() -> u16 {
    let rng = rand::thread_rng().gen_range(0..9999);
    rng as u16
}

fn get_random_secret() -> String {
    let random_bytes: Vec<u8> = (0..1024).map(|_| { rand::random::<u8>() }).collect();
    base64::encode(random_bytes)
}

fn calculate_time_based_drink_value(relative_time: DateTime<Utc>, v: &DrinkValue) -> f64 {
    f64::min(f64::max(0.0, v.1 - (relative_time - v.0).num_minutes() as f64 * REDUCE_AMOUNT_PER_HOUR / 60.), v.1)
}

use chrono::{DateTime, Utc};
use rand::Rng;
use crate::services::user_management::bonsai_db_user_manager::BonsaiDbError;
use crate::types::users::{UniqueUser, UserIdentification, UserInformation};

pub type DrinkValue = (DateTime<Utc>, f64);

#[async_trait]
pub trait UserManagement: Send + Sync {
    async fn user_already_exists(&self, name: &str, number: u16) -> Result<bool, UserError>;
    async fn valid_user_identification(&self, name: String, number: u16, secret: String) -> Result<bool, UserError> ;
    async fn add_user(&self, user: UserInformation) -> Result<(), UserError>;
    async fn add_drink(&self, drink: DrinkValue, user: &UserIdentification) -> Result<(), UserError>;
    async fn get_drinks(&self, user: &UserIdentification) -> Result<Vec<DrinkValue>, UserError>;
    async fn cleanup_drinks(&self, relative_time: &DateTime<Utc>, user: &UserIdentification) -> Result<(), UserError>;

    async fn register(&self, name: &str) -> Result<UserIdentification, UserError> {
        loop {
            let number = get_random_4numbers();
            if !self.user_already_exists(name, number).await? {
                let secret = get_random_secret();
                let unique_user = UniqueUser::new(name, number);
                self.add_user(UserInformation::new(secret.clone(), unique_user.clone())).await?;

                return Ok(UserIdentification::new(unique_user, secret));
            }
        }
    }


    async fn get_drink_value(&mut self, identification: UserIdentification) -> Result<f64, UserError> {
        if self.valid_user_identification(identification.user.name.clone(), identification.user.number.clone(), identification.secret.clone()).await? {
            let now = Utc::now();
            self.cleanup_drinks(&now, &identification).await?;
            let drinks = self.get_drinks(&identification).await?;

            for drink_val in drinks.iter() {
                println!("{:?}", drink_val);
            }

            let total_actual_drink_value = drinks.iter().map(|v| calculate_time_based_drink_value(now, v)).sum();
            Ok(total_actual_drink_value)
        } else {
            Err(UserError::InvalidAuthentication(identification))
        }
    }

    async fn take_drink(&mut self, identification: UserIdentification, drink_value: f64) -> Result<(), UserError> {
        if self.valid_user_identification(identification.user.name.clone(), identification.user.number.clone(), identification.secret.clone()).await? {
            let now = Utc::now();
            self.cleanup_drinks(&now, &identification).await?;
            self.add_drink((now, drink_value), &identification).await?;
            Ok(())
        } else {
            Err(UserError::InvalidAuthentication(identification))
        }
    }
}


#[cfg(test)]
mod tests {
    use chrono::{Duration, TimeZone, Utc};
    use crate::services::user_management::calculate_time_based_drink_value;

    #[test]
    pub fn calculate_time_based_drink_value_should_be_correct() {
        let datetime = Utc.datetime_from_str("2020-01-01T00:00:00", "%Y-%m-%dT%H:%M:%S").unwrap();
        let drink_value = (datetime, 2.0);
        let relative_time = datetime + Duration::hours(1);

        assert_eq!(calculate_time_based_drink_value(relative_time, &drink_value), 0.5);
    }

    #[test]
    pub fn calculate_time_based_drink_value_should_not_be_negative() {
        let datetime = Utc.datetime_from_str("2020-01-01T00:00:00", "%Y-%m-%dT%H:%M:%S").unwrap();
        let drink_value = (datetime, 2.0);
        let relative_time = datetime + Duration::hours(2);

        assert_eq!(calculate_time_based_drink_value(relative_time, &drink_value), 0.0);
    }

    #[test]
    pub fn calculate_time_based_drink_value_should_be_bigger_than_original() {
        let datetime = Utc.datetime_from_str("2020-01-01T00:00:00", "%Y-%m-%dT%H:%M:%S").unwrap();
        let drink_value = (datetime, 2.0);
        let relative_time = datetime - Duration::hours(1);

        assert_eq!(calculate_time_based_drink_value(relative_time, &drink_value), 2.0);
    }
}


