import 'package:flutter/material.dart';
import 'package:teb_janelajohari/routes.dart';
import 'package:teb_package/screen_elements/teb_custom_scaffold.dart';
import 'package:teb_package/visual_elements/teb_buttons_line.dart';
import 'package:teb_package/visual_elements/teb_text.dart';

class ErrorScreen extends StatelessWidget {
  final String errorMessage;
  const ErrorScreen({super.key, this.errorMessage = ''});

  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;
    var finalMessage = arguments['errorMessage'] ?? errorMessage;

    return TebCustomScaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const TebText('Ops, parece que houve um erro', textSize: 20, textWeight: FontWeight.bold, textColor: Colors.red),
            const SizedBox(height: 20),
            Text(finalMessage, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20)),
            TebButton(
              label: 'Voltar para tela inicial',

              onPressed: () {
                Navigator.of(context).pushReplacementNamed(Routes.landingScreen, arguments: {'ignoreQueryParameters': true});
              },
            ),
          ],
        ),
      ),
    );
  }
}
