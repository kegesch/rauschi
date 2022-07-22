use std::borrow::Cow;
use crate::types::users::{UniqueUser, UserInformation};
use bonsaidb::{
    core::{
        key::{Key, KeyEncoding},
        schema::{Collection, Schema},
    }
};
use serde::{Deserialize, Serialize};
use thiserror::Error;

#[derive(Debug, Schema)]
#[schema(name = "Schema", collections = [DbUser, DbUserData])]
pub struct DbSchema;

#[derive(Debug, Clone, Eq, PartialEq, Ord, PartialOrd, Serialize, Deserialize, Default, Collection)]
#[collection(name = "Users", primary_key = String, natural_id = |user: &DbUser| Some(format!("{}#{:04}", user.0.name, user.0.number)))]
pub struct DbUser(UniqueUser);

#[derive(Debug, Clone, Error, Serialize)]
pub enum DbError {
    #[error("Key could not be extracted")]
    KeyError,
}

impl <'k> KeyEncoding<'k, Self> for DbUser {
    type Error = DbError;
    const LENGTH: Option<usize> = None;

    fn as_ord_bytes(&'k self) -> Result<Cow<'k, [u8]>, Self::Error> {
        //let number_bytes = self.0.number.as_ord_bytes().map_err(|_| DbError::KeyError)?;
        //let name_bytes = self.0.name.as_ord_bytes().map_err(|_| DbError::KeyError)?;
        //let bytes = [number_bytes, name_bytes].concat();
        let bytes = bincode::serialize(&self.0).map_err(|_| DbError::KeyError)?;
        Ok(Cow::Owned(bytes))
    }
}

impl <'k> Key<'k> for DbUser {
    fn from_ord_bytes(bytes: &'k [u8]) -> Result<Self, Self::Error> {
        let user: UniqueUser = bincode::deserialize(bytes).map_err(|_| DbError::KeyError)?;
        Ok(DbUser(user))
    }
}

impl From<DbUser> for UniqueUser {
    fn from(user: DbUser) -> Self {
        user.0
    }
}
impl From<UniqueUser> for DbUser {
    fn from(user: UniqueUser) -> Self {
        Self(user)
    }
}

#[derive(Debug, Serialize, Deserialize, Default, Collection)]
#[collection(name = "UserData", primary_key = DbUser)]
pub struct DbUserData(UserInformation);


impl From<DbUserData> for UserInformation {
    fn from(user: DbUserData) -> Self {
        user.0
    }
}
impl From<UserInformation> for DbUserData {
    fn from(user: UserInformation) -> Self {
        Self(user)
    }
}