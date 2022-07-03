use std::fmt::{Display, Formatter};
use rocket::serde::{json::Json, Deserialize, Serialize};

#[derive(Debug, Clone, Deserialize, Serialize)]
pub struct Participant {
    name: String,
}

impl Display for Participant {
    fn fmt(&self, f: &mut Formatter<'_>) -> std::fmt::Result {
        f.write_str(self.name.as_str())
    }
}