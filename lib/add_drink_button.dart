import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:rauschmelder/user_state.dart';

import 'drink.dart';

class AddDrinkButton extends StatelessWidget {
  final Drink drink;
  final UserModel model;
  final Function? onPressed;
  const AddDrinkButton({Key? key, required this.drink, required this.model, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      child: Text(drink.name),
      onPressed: () {
        model.addDrink(drink).then((value) {
          if(onPressed != null) {
            onPressed!();
          }
        });
      });
    }
}
