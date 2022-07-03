class User {
  late String name;
  int? number;
  String? secret;

  User({required this.name, this.number, this.secret});

  User.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    number = json['number'];
    secret = json['secret'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['number'] = number;
    data['secret'] = secret;
    return data;
  }
}