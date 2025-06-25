import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:teb_janelajohari/routes.dart';
import 'package:teb_package/teb_package.dart';

class InvalidAccessScreen extends StatelessWidget {
  const InvalidAccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TebScaffold(
      showAppBar: false,
      body: Center(
        child: SizedBox(
          width: 500,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(FontAwesomeIcons.exclamation, size: 100, color: Colors.black54),
              Center(
                child: TebText(
                  'Ops, parece que alguma coisa quebrou por aqui, tente repetir o que fez ou retornar mais tarde.',
                  textSize: 30,
                  padding: EdgeInsets.symmetric(vertical: 20),
                ),
              ),
              TebButton(
                label: 'Voltar',
                buttonType: TebButtonType.outlinedButton,
                onPressed:
                    () => Navigator.of(context).popAndPushNamed(Routes.landingScreen, arguments: {'ignoreQueryParameters': true}),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
