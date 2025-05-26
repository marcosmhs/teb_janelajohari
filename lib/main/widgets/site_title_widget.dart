import 'package:flutter/material.dart';
import 'package:teb_package/visual_elements/teb_text.dart';

class SiteTitleWidget extends StatelessWidget {
  final bool mobile;
  const SiteTitleWidget({super.key, this.mobile = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Image.asset('assets/images/logo.png', fit: BoxFit.fitHeight, height: mobile ? 30 : 45),
          ),
          TebText('Janela de Johari', textSize: mobile ? 38 : 48),
        ],
      ),
    );
  }
}
