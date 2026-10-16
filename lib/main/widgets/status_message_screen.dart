import 'package:flutter/material.dart';
import 'package:teb_janelajohari/main/widgets/johari_logo.dart';
import 'package:teb_janelajohari/theme/app_theme.dart';

/// Tela de mensagem centralizada (erro, acesso inválido, rota inexistente)
/// no visual do redesign: logo no topo e um cartão com ícone, título,
/// texto e ação.
class StatusMessageScreen extends StatelessWidget {
  final IconData icon;
  final Color accent;
  final Color accentSoft;
  final String title;
  final String message;
  final String? detail;
  final String actionLabel;
  final VoidCallback onAction;

  const StatusMessageScreen({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
    this.detail,
    this.accent = AppColors.amber,
    this.accentSoft = AppColors.amberSoft,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                children: [
                  const JohariLogo(),
                  const SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.cardLarge),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(color: accentSoft, borderRadius: BorderRadius.circular(20)),
                          child: Icon(icon, size: 30, color: accent),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: AppTheme.display(const TextStyle(fontSize: 28, color: AppColors.ink, height: 1.15)),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          message,
                          textAlign: TextAlign.center,
                          style: AppTheme.body(const TextStyle(fontSize: 16, color: AppColors.inkSoft, height: 1.55)),
                        ),
                        if (detail != null && detail!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceAlt,
                              borderRadius: BorderRadius.circular(AppRadius.input),
                            ),
                            child: SelectableText(
                              detail!,
                              textAlign: TextAlign.center,
                              style: AppTheme.body(const TextStyle(fontSize: 14, color: AppColors.inkMuted)),
                            ),
                          ),
                        ],
                        const SizedBox(height: 28),
                        ElevatedButton.icon(
                          onPressed: onAction,
                          icon: const Icon(Icons.home_rounded, size: 20),
                          label: Text(actionLabel),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
