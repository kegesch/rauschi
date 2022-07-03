use std::fmt::{Display, Formatter};
use h3ron::H3Cell;
use rocket::serde::{json::Json, Deserialize, Serialize};

#[derive(Debug, Clone, Deserialize, Serialize, PartialEq)]
pub struct PartyKey {
    pub name: String,
    pub h3: H3Cell,
}

impl Display for PartyKey {
    fn fmt(&self, f: &mut Formatter<'_>) -> std::fmt::Result {
        let str = format!("{}-{}", self.name, self.h3.to_string());
        f.write_str(str.as_str())
    }
}

impl PartyKey {
    pub fn create(name: String, location: H3Cell) -> Self {
        Self {
            name,
            h3: location
        }
    }
}