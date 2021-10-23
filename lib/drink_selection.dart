import 'package:flutter/material.dart';
import 'package:rauschmelder/add_drink_button.dart';
import 'package:rauschmelder/drunken_status.dart';
import 'package:rauschmelder/user_state.dart';
import 'package:flutter/widgets.dart';

import 'drink.dart';

class DrinkSelectionPage extends StatefulWidget {
  final UserModel model;

  const DrinkSelectionPage({Key? key, required this.model}) : super(key: key);

  @override
  _DrinkSelectionPageState createState() => _DrinkSelectionPageState();
}

class _DrinkSelectionPageState extends State<DrinkSelectionPage> {

  void Reload() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child:
        FutureBuilder(
            future: widget.model.getUserName(),
            builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
              if (snapshot.hasData) {
                return Column(
                  children: [
                    DrunkenStatus(model: widget.model),
                    Expanded(child: ListView(
                      children: [
                        AddDrinkButton(drink: Drink(name: "🍺 Bier", alcohol: 0.05, amount: 0.5), model: widget.model, onPressed: Reload),
                        AddDrinkButton(drink: Drink(name: "🍷 Wein", alcohol: 0.11, amount: 0.2), model: widget.model, onPressed: Reload),
                        AddDrinkButton(drink: Drink(name: "🍹 Cocktail", alcohol: 0.17, amount: 0.4), model: widget.model, onPressed: Reload),
                        AddDrinkButton(drink: Drink(name: "🔫 Shot", alcohol: 0.04, amount: 0.02), model: widget.model, onPressed: Reload),
                      ],
                    ))
                  ],
                );
              } else if (snapshot.hasError) {
                return const Text("Error in retrieving userName");
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            }),

      ),
    );
  }
}
