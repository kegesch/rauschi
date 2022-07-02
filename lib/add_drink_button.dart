import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rauschmelder/card.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:rauschmelder/user_state.dart';

import 'drink.dart';

class AddDrinkButton extends StatelessWidget {
  final Drink drink;
  final UserModel model;
  final Function? onPressed;
  const AddDrinkButton({Key? key, required this.drink, required this.model, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {


    return <Widget>[
          Text(drink.emoji)
              .fontSize(50),
          //Text(drink.name)
          //    .fontSize(20)
        ].toColumn(mainAxisAlignment: MainAxisAlignment.center)
        .gestures(onTap: () async {
          try {
            await model.addDrink(drink);
            if (onPressed != null) {
              onPressed!();
            }
          } catch(e) {
            const snackdemo = SnackBar(
              content: Text("Try again later. Adding a drink is only allowed every 5 minutes."),
              backgroundColor: Colors.redAccent,
              elevation: 10,
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(12),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackdemo);
          }
    });
  }
}
