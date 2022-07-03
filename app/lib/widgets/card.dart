import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

class StyledCard extends StatelessWidget {
  final Widget child;
  Color color;
  double shadowSize;
  bool withMargin;

  StyledCard({Key? key, required this.child, Color? color, double? shadowSize, bool? withMargin}) : color = color ?? Colors.amber, shadowSize = shadowSize ?? 10, withMargin = withMargin ?? true, super(key: key) ;

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

    return Container(margin: withMargin ? const EdgeInsets.all(10) : const EdgeInsets.all(0), child: Styled.widget(child: child)
        .decorated(
          borderRadius: BorderRadius.circular(20),
          color: color)
        .elevation(
          shadowSize,
          shadowColor: lighten(color, .3),
          borderRadius: BorderRadius.circular(20)));
  }
}
