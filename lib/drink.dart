class Drink {
  late double amount;
  late String name;
  late String emoji;
  late double alcohol;

  Drink({required this.emoji, required this.name, required this.amount, required this.alcohol});

  Drink.fromJson(Map<String, dynamic> json)
  : emoji = json['emoji'],
    name = json['name'],
    amount = json['amount'],
    alcohol = json['alcohol'];

  Map<String, dynamic> toJson() => {
    'emoji': emoji,
    'name': name,
    'amount': amount,
    'alcohol': alcohol,
  };

  double getScore() {
    var score = alcohol * amount * 100;
    return score;
  }
}