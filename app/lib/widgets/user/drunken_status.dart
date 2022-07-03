import 'package:flutter/material.dart';
import 'user_state.dart';
import 'dart:math' as math;
import 'package:styled_widget/styled_widget.dart';


class DrunkenStatus extends StatelessWidget {
  final UserModel model;

  const DrunkenStatus({Key? key, required this.model}) : super(key: key);


  String getRandomText(String name, double score) {
    var random = math.Random();
    var randomInt = random.nextInt(16);

    switch(randomInt) {
      case 0: return "Berauschter $name hat sich schon ${score.toString()} mal hinter die Binde gekippt";
      case 1: return "Berauschter $name hat sich schon ${score.toString()} mal ordentlich einen reingezimmert";
      case 2: return "Berauschter $name hat sich schon ${score.toString()} mal einen gehoben";
      case 3: return "Berauschter $name hat sich schon ${score.toString()} mal den Helm lackiert";
      case 4: return "Berauschter $name hat sich schon ${score.toString()} mal den Damm gebiebert";
      case 5: return "Berauschter $name hat sich schon ${score.toString()} mal die Batterien abgeklemmt";
      case 6: return "Berauschter $name hat sich schon ${score.toString()} mal die Festplatte gelöscht";
      case 7: return "Berauschter $name hat sich schon ${score.toString()} mal die Kontakte feucht gelegt";
      case 8: return "Berauschter $name hat sich schon ${score.toString()} Kanonen ins Esszimmer geschossen";
      case 9: return "Berauschter $name hat sich schon ${score.toString()} mal den Richtbaum vom First geschossen";
      case 10: return "Berauschter $name hat sich schon ${score.toString()} mal die Rinne verzinkt";
      case 11: return "Berauschter $name hat schon ${score.toString()} Kolben gepresst";
      case 12: return "Berauschter $name hat schon ${score.toString()} Kolben geköpft";
      case 13: return "Berauschter $name hat sich schon ${score.toString()} mal die Rüstung geschmiert";
      case 14: return "Berauschter $name hat schon ${score.toString()} mal in die Sakristei georgelt";
      case 15: return "Berauschter $name hat sich schon ${score.toString()} mal geschmeidig untern Zapfhahn gelegt";
    }
    return "";
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: model.load(),
        builder: (context, snapshot) {
          var text = "";
          if (snapshot.connectionState == ConnectionState.done) {
            var score = model.drinks.isEmpty ? 0.0 : model.drinks.map((e) => e.getScore()).sum;
            var userName = model.userName!;
            text = getRandomText(userName, score);
          } else if (snapshot.hasError) {
            text = "Berauschter user hat ein problem beim trinken";
          } else {
            text = "Am Bar nachfüllen....";
          }
          return Text(text)
              .textColor(Colors.white)
              .fontSize(15)
              .fontWeight(FontWeight.w500);
        },);
  }
}

extension IterableNum<T extends num> on Iterable<T> {
  T get max => reduce(math.max);
  T get min => reduce(math.min);
  T get sum => reduce((a, b) => a + b as T);
}
