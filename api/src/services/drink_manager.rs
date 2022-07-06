use crate::types::drinks::Drink;

#[derive(Default)]
pub struct DrinkManager {
    drinks: Vec<Drink>
}

impl DrinkManager {
    pub fn get_drinks(&self) -> Vec<Drink> {
        self.drinks.clone()
    }

    pub fn add_drink(&mut self, drink: Drink) {
        self.drinks.push(drink);
    }
}