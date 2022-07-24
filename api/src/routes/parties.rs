use std::sync::Arc;
use geo_types::Coordinate;
use h3ron::H3Cell;
use rocket::futures::lock::Mutex;
use rocket::http::Status;
use rocket::serde::{json::Json, Deserialize, Serialize};
use rocket::State;
use crate::{H3_PRECISION, PartyManager};
use crate::services::party_manager::PartyError;
use crate::types::geo::PartyKey;
use crate::types::parties::Party;
use crate::types::users::Participant;

#[derive(Debug, Clone, Deserialize, Serialize, FromForm)]
pub struct Location {
    longitude: f64,
    latitude: f64,
}

impl From<Location> for H3Cell {
    fn from(loc: Location) -> Self {
        H3Cell::from_coordinate(&Coordinate::from((loc.longitude, loc.latitude)), H3_PRECISION).expect("Unexpected Coordinate")
    }
}

#[derive(Debug, Clone, Deserialize, Serialize)]
pub struct CreatePartyRequest {
    name: String,
    location: Location,
}

#[post("/", format = "json", data = "<request>")]
pub async fn create_party(request: Json<CreatePartyRequest>, party_manager: &State<Arc<Mutex<PartyManager>>>) -> Status {
    let request_inner = request.into_inner();
    let h3: H3Cell = request_inner.location.clone().into();
    let name = request_inner.name;
    println!("Created a new party {} for location {}", name, h3.to_string());

    let party = Party::create(name.as_str(), h3);
    if party_manager.lock().await.add_party(party).is_err() {
        return Status::AlreadyReported;
    };

    Status::Ok
}

#[get("/?<location>")]
pub async fn get_near_parties(location: Location, party_manager: &State<Arc<Mutex<PartyManager>>>) -> Json<Vec<Party>> {
    let h3: H3Cell = location.into();
    let nearby_parties = party_manager.lock().await.get_parties_close_to(h3).to_vec();

    println!("Requested near parties for location {}", h3.to_string());

    Json(nearby_parties)
}

#[derive(Debug, Clone, Deserialize, Serialize)]
pub struct JoinPartyRequest {
    party_key: PartyKey,
    participant: Participant,
}

#[post("/join", format = "json", data = "<request>")]
pub async fn join_party(request: Json<JoinPartyRequest>, party_manager: &State<Arc<Mutex<PartyManager>>>) -> Json<Result<(), PartyError>> {
    let request_inner = request.into_inner();
    let participant = request_inner.participant.clone();
    let party_key =request_inner.party_key;

    let res = party_manager.lock().await.join_party(party_key.clone(), participant.clone());
    if res.is_ok() {
        println!("Participant {} joined party {}", participant, party_key);
    }

    Json(res)
}