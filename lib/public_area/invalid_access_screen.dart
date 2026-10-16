import 'package:flutter/material.dart';
import 'package:teb_janelajohari/main/widgets/status_message_screen.dart';
import 'package:teb_janelajohari/routes.dart';

class InvalidAccessScreen extends StatelessWidget {
  const InvalidAccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StatusMessageScreen(
      icon: Icons.lock_outline_rounded,
      title: 'Não foi possível acessar',
      message: 'Ops, parece que alguma coisa quebrou por aqui. Tente repetir o que fez ou volte mais tarde.',
      actionLabel: 'Voltar',
      onAction:
          () => Navigator.of(context).popAndPushNamed(Routes.landingScreen, arguments: {'ignoreQueryParameters': true}),
    );
  }
}
