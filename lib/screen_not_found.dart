import 'package:flutter/material.dart';
import 'package:teb_janelajohari/main/widgets/status_message_screen.dart';
import 'package:teb_janelajohari/routes.dart';
import 'package:teb_janelajohari/theme/app_theme.dart';

class ScreenNotFound extends StatelessWidget {
  final String screenName;

  // ignore: use_key_in_widget_constructors
  const ScreenNotFound(this.screenName);

  @override
  Widget build(BuildContext context) {
    return StatusMessageScreen(
      icon: Icons.explore_off_outlined,
      accent: AppColors.purple,
      accentSoft: AppColors.purpleSoft,
      title: 'Tela não encontrada',
      message: 'O endereço acessado não existe ou foi movido.',
      detail: 'Rota: $screenName',
      actionLabel: 'Tela inicial',
      // limpa a pilha de telas e chama a tela inicial
      onAction: () => Navigator.restorablePushNamedAndRemoveUntil(context, Routes.landingScreen, (route) => false),
    );
  }
}
