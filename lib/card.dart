import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

class StyledCard extends StatelessWidget {
  final Widget child;
  Color color;
  double shadowSize;

  StyledCard({Key? key, required this.child, Color? color, double? shadowSize}) : color = color ?? Colors.amber, shadowSize = shadowSize ?? 10, super(key: key) ;

  @override
  Widget build(BuildContext context) {
    Color darken(Color color, [double amount = .1]) {
      assert(amount >= 0 && amount <= 1);

      final hsl = HSLColor.fromColor(color);
      final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

      return hslDark.toColor();
    }

    Color lighten(Color color, [double amount = .1]) {
      assert(amount >= 0 && amount <= 1);

      final hsl = HSLColor.fromColor(color);
      final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

      return hslLight.toColor();
    }

    return Container(margin: const EdgeInsets.symmetric(horizontal: 10), child: Styled.widget(child: child)
        .decorated(
          borderRadius: BorderRadius.circular(20),
          color: color)
        .elevation(
          shadowSize,
          shadowColor: lighten(color, .3),
          borderRadius: BorderRadius.circular(20))
        .padding(vertical: 10, horizontal: 0));
  }
}
