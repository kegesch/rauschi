class Drink {
  late double amount;
  late String name;
  late double alcohol;

  Drink({required this.name, required this.amount, required this.alcohol});

  Drink.fromJson(Map<String, dynamic> json)
  : name = json['name'],
    amount = json['amount'],
    alcohol = json['alcohol'];

  Map<String, dynamic> toJson() => {
    'name': name,
    'amount': amount,
    'alcohol': alcohol,
  };

  double getScore() {
    var score = alcohol * amount * 100;
    print("Calculated score for $name: $score");
    return score;
  }
}