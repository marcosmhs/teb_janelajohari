import 'package:flutter/material.dart';
import 'package:teb_package/visual_elements/teb_text.dart';

class AreaTitleWidget extends StatelessWidget {
  final bool mobile;
  final Size size;
  final String title;
  final double? lineWidth;
  final bool cropped;

  const AreaTitleWidget({
    super.key,
    required this.size,
    this.title = '',
    this.lineWidth,
    required this.mobile,
    this.cropped = false,
  });

  @override
  Widget build(BuildContext context) {
    var titleTebTextWidget = TebText(title, textSize: 32.0, letterSpacing: 3.0, textWeight: FontWeight.w700);

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (mobile) Expanded(child: titleTebTextWidget),
            if (!mobile) titleTebTextWidget,
            if (!mobile) SizedBox(width: size.width * 0.005),
            if (!mobile && (lineWidth ?? 0) > 0)
              Container(width: lineWidth ?? size.width / 4, height: 2.50, color: Theme.of(context).dividerColor),
          ],
        ),
        if (!cropped) SizedBox(height: 30),
      ],
    );
  }
}
