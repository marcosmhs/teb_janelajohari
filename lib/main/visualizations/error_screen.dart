import 'package:flutter/material.dart';
import 'package:teb_janelajohari/main/widgets/status_message_screen.dart';
import 'package:teb_janelajohari/routes.dart';
import 'package:teb_janelajohari/theme/app_theme.dart';

class ErrorScreen extends StatelessWidget {
  final String errorMessage;
  const ErrorScreen({super.key, this.errorMessage = ''});

  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;
    final String finalMessage = arguments['errorMessage'] ?? errorMessage;

    return StatusMessageScreen(
      icon: Icons.error_outline_rounded,
      accent: AppColors.error,
      accentSoft: AppColors.error.withValues(alpha: 0.1),
      title: 'Ops, parece que houve um erro',
      message: 'Algo não saiu como esperado. Volte para a tela inicial e tente novamente.',
      detail: finalMessage,
      actionLabel: 'Voltar para tela inicial',
      onAction:
          () => Navigator.of(context).pushReplacementNamed(Routes.landingScreen, arguments: {'ignoreQueryParameters': true}),
    );
  }
}
