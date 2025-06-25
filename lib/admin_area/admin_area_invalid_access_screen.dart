import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:teb_janelajohari/routes.dart';
import 'package:teb_package/teb_package.dart';

class AdminAreaInvalidAccessScreen extends StatelessWidget {
  const AdminAreaInvalidAccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TebScaffold(
      showAppBar: false,
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FontAwesomeIcons.usersSlash, size: 100, color: Colors.black54),
            TebText('Acesso negado', textSize: 30, padding: EdgeInsets.symmetric(vertical: 20)),
            TebButton(
              label: 'Voltar',
              buttonType: TebButtonType.outlinedButton,
              onPressed:
                  () => Navigator.of(context).popAndPushNamed(Routes.landingScreen, arguments: {'ignoreQueryParameters': true}),
            ),
          ],
        ),
      ),
    );
  }
}
