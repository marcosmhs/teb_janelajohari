import 'package:flutter/material.dart';
import 'package:teb_janelajohari/theme/app_theme.dart';

/// Marca da Janela de Johari: a grade 2x2 com as cores dos quatro quadrantes.
class JohariLogo extends StatelessWidget {
  final double size;
  final bool showTitle;
  final double titleSize;
  final Color? titleColor;

  const JohariLogo({super.key, this.size = 34, this.showTitle = true, this.titleSize = 21, this.titleColor});

  @override
  Widget build(BuildContext context) {
    final gap = size * 0.06;
    final cell = (size - gap) / 2;
    Widget square(Color color) => Container(
      width: cell,
      height: cell,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(cell * 0.24)),
    );

    final mark = SizedBox(
      width: size,
      height: size,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(mainAxisSize: MainAxisSize.min, children: [square(AppColors.teal), SizedBox(width: gap), square(AppColors.blue)]),
          SizedBox(height: gap),
          Row(mainAxisSize: MainAxisSize.min, children: [square(AppColors.amber), SizedBox(width: gap), square(AppColors.purple)]),
        ],
      ),
    );

    if (!showTitle) return mark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        SizedBox(width: size * 0.35),
        Text(
          'Janela de Johari',
          style: AppTheme.display(TextStyle(fontSize: titleSize, color: titleColor ?? AppColors.ink, letterSpacing: -0.3)),
        ),
      ],
    );
  }
}
