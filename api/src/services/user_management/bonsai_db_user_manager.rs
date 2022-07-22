pub use std::ops::{Deref};
use bonsaidb::core::document::CollectionDocument;
use bonsaidb::core::schema::{SerializedCollection};
use bonsaidb::local::{AsyncDatabase};
use chrono::{DateTime, Utc};
use thiserror::Error;

use crate::services::user_management::{cleanup_drinks, DrinkValue, UserError, UserManagement};
use crate::types::db_schema::{DbUser, DbUserData};
use crate::types::users::{UniqueUser, UserIdentification, UserInformation};

pub struct DatabaseUserManager {
    pub db: AsyncDatabase,
}

#[derive(Error, Debug)]
pub enum BonsaiDbError {
    #[error("generic database error: {0}")]
    DatabaseError(#[from] bonsaidb::core::Error),
    #[error("user not found")]
    UserNotFound,
}

impl DatabaseUserManager {
    pub(crate) fn new(db: AsyncDatabase) -> Self {
        DatabaseUserManager { db }
    }

    async fn find_user(&self, name: &str, number: u16) -> Result<Option<CollectionDocument<DbUser>>, bonsaidb::core::Error> {
        let id = format!("{}#{:04}", name, number);
        let user = DbUser::get_async(id, &self.db).await?;
        Ok(user)
    }

    async fn find_user_data(&self, name: &str, number: u16) -> Result<Option<CollectionDocument<DbUserData>>, bonsaidb::core::Error> {
        let db_user: DbUser = UniqueUser::new(name, number).into();
        let user = DbUserData::get_async(db_user, &self.db).await?;
        Ok(user)
    }
}

#[async_trait]
impl UserManagement for DatabaseUserManager {
    async fn user_already_exists(&self, name: &str, number: u16) -> Result<bool, UserError> {
        let user = self.find_user(name, number).await.map_err(BonsaiDbError::DatabaseError)?;
        Ok(user.is_some())
    }

    async fn valid_user_identification(&self, name: String, number: u16, secret: String) -> Result<bool, UserError> {
        let user_option = self.find_user_data(name.as_str(), number).await.map_err(BonsaiDbError::DatabaseError)?;
        if let Some(user_doc) = user_option {
            let user: UserInformation = user_doc.contents.into();
            if user.secret == secret {
                Ok(true)
            } else {
                Ok(false)
            }
        } else {
            Ok(false)
        }
    }

    async fn add_user(&self, user: UserInformation) -> Result<(), UserError> {
        let user_data: DbUserData = user.clone().into();
        let user_id: DbUser = user.identification.into();
        user_id.clone().push_into_async(&self.db).await.map_err(|err| BonsaiDbError::DatabaseError(err.error))?;
        user_data.insert_into_async(user_id, &self.db).await.map_err(|err| BonsaiDbError::DatabaseError(err.error))?;
        Ok(())
    }

    async fn add_drink(&self, drink: DrinkValue, user: &UserIdentification) -> Result<(), UserError>  {
        let db_user: DbUser = user.clone().user.into();
        let data = DbUserData::get_async(db_user.clone(), &self.db).await.map_err(BonsaiDbError::DatabaseError)?;
        if let Some(user_data) = data {
            let mut user_information: UserInformation = user_data.contents.into();
            user_information.drinks.push(drink);
            let user_data: DbUserData = user_information.into();
            DbUserData::overwrite_async(db_user, user_data, &self.db).await.map_err(|err| BonsaiDbError::DatabaseError(err.error))?;
            return Ok(());
        }
        Err(UserError::DatabaseError(BonsaiDbError::UserNotFound))
    }

    async fn get_drinks(&self, user: &UserIdentification) -> Result<Vec<DrinkValue>, UserError> {
        let db_user: DbUser = user.clone().user.into();
        let data = DbUserData::get_async(db_user, &self.db).await.map_err(|err| BonsaiDbError::DatabaseError(err))?;
        if let Some(user_data) = data {
            let user_information: UserInformation = user_data.contents.into();
            Ok(user_information.drinks)
        } else {
            Err(UserError::DatabaseError(BonsaiDbError::UserNotFound))
        }
    }

    async fn cleanup_drinks(&self, relative_time: &DateTime<Utc>, user: &UserIdentification) -> Result<(), UserError> {
        let db_user: DbUser = user.clone().user.into();
        let data = DbUserData::get_async(db_user.clone(), &self.db).await.map_err(BonsaiDbError::DatabaseError)?;
        if let Some(user_data) = data {
            let mut user_information: UserInformation = user_data.contents.into();
            cleanup_drinks(relative_time, &mut user_information.drinks);
            let user_data: DbUserData = user_information.into();
            DbUserData::overwrite_async(db_user,user_data, &self.db).await.map_err(|insert_err| BonsaiDbError::DatabaseError(insert_err.error))?;
        }
        Ok(())
    }
}