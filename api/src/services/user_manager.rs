use rand::Rng;
use rand::rngs::OsRng;
use rocket::serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Deserialize, Serialize)]
pub struct UniqueUser {
    name: String,
    number: u16,
    secret: String,
}

impl UniqueUser {
    pub fn new(name: &str, number: u16, secret: String) -> Self {
        Self {
            name: name.to_string(),
            number,
            secret: secret.to_string(),
        }
    }
}

#[derive(Default)]
pub struct UserManager {
    users: Vec<UniqueUser>,
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

    fn user_already_exists(&self, name: &str, number: u16) -> bool {
        self.users.iter().any(|u| u.name.as_str() == name && u.number == number)
    }

    pub fn register(&mut self, name: &str) -> UniqueUser {
        loop {
            let number = get_random_4numbers();
            if !self.user_already_exists(name, number) {
                let secret = get_random_secret();
                let unique_user = UniqueUser::new(name, number, secret);
                self.users.push(unique_user.clone());

                return unique_user;
            }
        }
    }
}

