use crate::types::geo::PartyKey;
use crate::types::Location;
use crate::types::parties::Party;
use thiserror::Error;
use crate::services::party_manager::PartyError::{AlreadyExists};
use rocket::serde::Serialize;
use crate::types::users::Participant;

#[derive(Default)]
pub struct PartyManager {
    parties: Vec<Party>
}

#[derive(Error, Debug, Serialize)]
pub enum PartyError {
    #[error("could not find any party with key {0}")]
    UnknownParty(PartyKey),
    #[error("party with key {0} already exists")]
    AlreadyExists(PartyKey),
}

impl PartyManager {
    pub fn add_party(&mut self, party: Party) -> Result<(), PartyError> {
        if !self.party_exists(&party.key) {
            self.parties.push(party);
            Ok(())
        } else {
            Err(AlreadyExists(party.key))
        }
    }

    pub fn party_exists(&self, party_key: &PartyKey) -> bool {
        self.parties.iter().any(|p| &p.key == party_key)
    }

    pub fn join_party(&mut self, key: PartyKey, participant: Participant) -> Result<(), PartyError> {
        let party_ref = self.parties.iter_mut().find(|p| p.key == key);

        if let Some(p) = party_ref{
            p.join(participant);
            Ok(())
        } else {
            Err(PartyError::UnknownParty(key))
        }
    }

    pub fn get_parties_close_to(&self, location: Location) -> Vec<Party> {
        self.parties.iter().filter(|p| p.is_close_to(location)).cloned().collect()
    }
}