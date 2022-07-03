use h3ron::{H3Cell, Index};
use crate::types::geo::PartyKey;
use crate::types::Location;
use crate::types::users::Participant;

use rocket::serde::{json::Json, Deserialize, Serialize};

#[derive(Debug, Clone, Deserialize, Serialize)]
pub struct Party {
    pub key: PartyKey,
    participants: Vec<Participant>,
}

impl Party {
    pub fn create(name: &str, location: Location) -> Self {
        Self {
            key: PartyKey::create(name.to_string(), location),
            participants: vec![],
        }
    }

    pub fn is_close_to(&self, location: Location) -> bool {
        self.key.h3.is_neighbor_to(location) || self.key.h3 == location || self.key.h3.contains(&location)
    }

    pub fn join(&mut self, participant: Participant) {
        self.participants.push(participant);
    }
}