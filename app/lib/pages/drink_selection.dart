import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:rauschmelder/widgets/user/add_drink_button.dart';
import 'package:rauschmelder/widgets/card.dart';
import 'package:rauschmelder/widgets/user/greeter.dart';
import 'package:rauschmelder/widgets/user/user_state.dart';
import 'package:rauschmelder/widgets/user/user_stats.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:rauschmelder/widgets/drink.dart';
import 'package:rauschmelder/widgets/party/party_status_widget.dart';

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
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: FutureBuilder(
            future: widget.model.getUserName(),
            builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
              if (snapshot.hasData) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Greeter(model: widget.model),
                    FutureBuilder(
                      future: widget.model.getNearbyParties(),
                      builder:
                          (BuildContext context, AsyncSnapshot<int> snapshot) {
                        return <Widget>[
                          const PartyStatus(),
                          UserStats(
                            model: widget.model,
                          )
                        ].toStack();
                      },
                    ),
                    GridView.count(
                        crossAxisCount: 3,
                        crossAxisSpacing: 2,
                        mainAxisSpacing: 2,
                        children: [
                          AddDrinkButton(
                              drink: Drink(
                                  emoji: "🍺",
                                  name: "Bier",
                                  alcohol: 0.05,
                                  amount: 0.5),
                              model: widget.model,
                              onPressed: Reload),
                          AddDrinkButton(
                              drink: Drink(
                                  emoji: "🍷",
                                  name: "Wein",
                                  alcohol: 0.11,
                                  amount: 0.2),
                              model: widget.model,
                              onPressed: Reload),
                          AddDrinkButton(
                              drink: Drink(
                                  emoji: "🍹",
                                  name: "Cocktail",
                                  alcohol: 0.17,
                                  amount: 0.4),
                              model: widget.model,
                              onPressed: Reload),
                          AddDrinkButton(
                              drink: Drink(
                                  emoji: "🥃",
                                  name: "Whiskey",
                                  alcohol: 0.17,
                                  amount: 0.4),
                              model: widget.model,
                              onPressed: Reload),
                          AddDrinkButton(
                              drink: Drink(
                                  emoji: "🥛",
                                  name: "Longdrink",
                                  alcohol: 0.17,
                                  amount: 0.4),
                              model: widget.model,
                              onPressed: Reload),
                          AddDrinkButton(
                              drink: Drink(
                                  emoji: "🔫",
                                  name: "Shot",
                                  alcohol: 0.04,
                                  amount: 0.02),
                              model: widget.model,
                              onPressed: Reload),
                        ]).expanded(),
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
