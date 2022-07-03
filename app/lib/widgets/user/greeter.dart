import 'package:flutter/widgets.dart';
import 'dart:math' as math;
import 'user_state.dart';

String getRandomText() {
  var random = math.Random();
  var messages = ["Cheers", "Prost", "Skål", "¡Salut", "yра"];

  var randomInt = random.nextInt(messages.length);
  return messages[randomInt];
}

class Greeter extends StatelessWidget {
  final UserModel model;
  final String message;

  Greeter({Key? key, required this.model}) : message = getRandomText(), super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.only(
        top: 12,
        left: 10,
      ),
      child: Text(
        '🍻 $message, ${model.userName}',
        style: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
        ),
      ),

    );
  }
}
