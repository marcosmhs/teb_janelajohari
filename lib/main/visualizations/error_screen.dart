import 'package:flutter/material.dart';
import 'package:teb_janelajohari/routes.dart';
import 'package:teb_package/control_widgets/teb_buttons_line.dart';
import 'package:teb_package/control_widgets/teb_text.dart';
import 'package:teb_package/screen_widgets/teb_scaffold.dart';

class ErrorScreen extends StatelessWidget {
  final String errorMessage;
  const ErrorScreen({super.key, this.errorMessage = ''});

  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;
    var finalMessage = arguments['errorMessage'] ?? errorMessage;

    return TebScaffold(
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
