use std::fmt::{Display, Formatter};
use rocket::serde::{Deserialize, Serialize};
use crate::services::user_management::DrinkValue;

#[derive(Debug, Clone, Deserialize, Serialize)]
pub struct Participant {
    name: String,
}

impl Display for Participant {
    fn fmt(&self, f: &mut Formatter<'_>) -> std::fmt::Result {
        f.write_str(self.name.as_str())
    }
}


#[derive(Debug, Default, Clone, Deserialize, Serialize, Eq, PartialEq, Ord, PartialOrd)]
pub struct UniqueUser {
    pub name: String,
    pub number: u16,
}

impl Display for UniqueUser {
    fn fmt(&self, f: &mut Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}#{:04}", self.name, self.number)
    }
}

impl UniqueUser {
    pub fn new(name: &str, number: u16) -> Self {
        Self {
            name: name.to_string(),
            number,
        }
    }
}

#[derive(Debug, Default, Clone, Deserialize, Serialize, Eq, PartialEq, Ord, PartialOrd)]
pub struct UserIdentification {
    pub user: UniqueUser,
    pub secret: String,
}

impl Display for UserIdentification {
    fn fmt(&self, f: &mut Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.user)
    }
}

impl UserIdentification {
    pub fn new(user: UniqueUser, secret: String) -> Self {
        Self {
            user,
            secret,
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
            user: UniqueUser::new(name.as_str(), number.unwrap()),
            secret,
        })
    }
}

#[derive(Debug, Serialize, Deserialize, Default, Clone)]
pub struct UserInformation {
    pub secret: String,
    pub identification: UniqueUser,
    pub drinks: Vec<DrinkValue>,
}

impl UserInformation {
    pub fn new(secret: String, identification: UniqueUser) -> Self {
        Self {
            secret,
            identification,
            drinks: vec![],
        }
    }
}