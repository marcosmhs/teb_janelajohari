// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:teb_janelajohari/main/widgets/johari_logo.dart';
import 'package:teb_janelajohari/public_area/session_feedbacks/session_feedbacks.dart';
import 'package:teb_janelajohari/public_area/session/session.dart';
import 'package:teb_janelajohari/public_area/session/session_controller.dart';
import 'package:teb_janelajohari/routes.dart';
import 'package:teb_janelajohari/theme/app_theme.dart';
import 'package:teb_package/messaging/teb_message.dart';
import 'package:teb_package/util/teb_return.dart';
import 'package:teb_package/util/teb_uid_generator.dart';

class SessionForm extends StatefulWidget {
  const SessionForm({super.key});

  @override
  State<SessionForm> createState() => _SessionFormState();
}

class _SessionFormState extends State<SessionForm> {
  final TextEditingController _nameController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _initializing = true;
  Session _session = Session();
  bool _savingData = false;
  bool _newSession = false;
  bool _mobile = false;
  bool _savedAck = false;

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_savedAck) {
      TebMessage.error(context, message: 'Confirme que já salvou seu código de acesso para continuar');
      return;
    }
    if (_savingData) return;
    setState(() => _savingData = true);
    try {
      _formKey.currentState?.save();
      final controller = SessionController();
      final result = await controller.save(session: _session);
      if (!mounted) return;
      if (result.returnType != TebReturn.success.returnType) {
        TebMessage.error(context, message: result.message);
        return;
      }
      TebMessage.success(context, message: _newSession ? 'Sessão criada!' : 'Sessão alterada');
      if (_newSession) {
        Navigator.of(context).popAndPushNamed(
          Routes.feedbackScreen,
          arguments: {'session': controller.currentSession, 'feedbackType': FeedbackType.self, 'mobile': _mobile},
        );
      } else {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) setState(() => _savingData = false);
    }
  }

  void _copy(String value, String message) {
    Clipboard.setData(ClipboardData(text: value));
    TebMessage.success(context, message: message);
  }

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;
      _session = arguments['session'] ?? Session();
      _mobile = arguments['mobile'] ?? false;
      _newSession = _session.id.isEmpty;
      if (_newSession) {
        _session.accessCode = TebUidGenerator.invitationCode;
        _session.feedbackCode = TebUidGenerator.invitationCode;
      }
      _nameController.text = _session.name;
      _initializing = false;
    }

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Column(
        children: [
          _header(),
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(_mobile ? 20 : 32, 40, _mobile ? 20 : 32, 80),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _stepper(),
                          const SizedBox(height: 32),
                          Text(
                            'Vamos abrir a sua janela',
                            style: AppTheme.display(TextStyle(fontSize: _mobile ? 36 : 48, color: AppColors.ink, height: 1.05, letterSpacing: -0.5)),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Diga como quer ser chamado(a). Em seguida você recebe um código pessoal e um link para pedir feedback.',
                            style: AppTheme.body(const TextStyle(fontSize: 18, color: AppColors.inkSoft, height: 1.5)),
                          ),
                          const SizedBox(height: 32),
                          _card(),
                          const SizedBox(height: 24),
                          _actions(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cream,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: _mobile ? 20 : 48, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const JohariLogo(),
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Voltar ao início')),
          ],
        ),
      ),
    );
  }

  Widget _stepper() {
    final steps = ['Sessão', 'Autoavaliação', 'Compartilhar', 'Resultados'];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(steps.length, (i) {
        final active = i == 0;
        return Container(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
          decoration: BoxDecoration(
            color: active ? AppColors.ink : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: active ? null : Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: active ? AppColors.gold : const Color(0xFFF1EEE8),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text('${i + 1}', style: AppTheme.body(const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ink))),
              ),
              const SizedBox(width: 8),
              Text(
                steps[i],
                style: AppTheme.body(TextStyle(fontSize: 14, fontWeight: active ? FontWeight.w700 : FontWeight.w600, color: active ? Colors.white : AppColors.inkMuted)),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _card() {
    return Container(
      padding: EdgeInsets.all(_mobile ? 24 : 40),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.cardLarge),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Seu nome'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(hintText: 'Como os colegas te conhecem'),
            textCapitalization: TextCapitalization.words,
            onSaved: (v) => _session.name = v ?? '',
            validator: (v) => (v ?? '').trim().isEmpty ? 'Informe seu nome para que as pessoas possam te reconhecer' : null,
          ),
          const SizedBox(height: 6),
          _hint('Seus colegas verão este nome no pedido de feedback.'),
          const SizedBox(height: 24),

          _label('Seu código de acesso'),
          const SizedBox(height: 8),
          _readonlyField(
            value: _session.accessCode,
            mono: true,
            valueColor: AppColors.amberDark,
            borderColor: const Color(0xFFC9A27C),
            dashed: true,
            fill: const Color(0xFFFBF4EC),
            onCopy: () => _copy(_session.accessCode, 'Código copiado para sua área de transferência!'),
            copyLabel: 'Copiar código',
            copyFilled: false,
          ),
          const SizedBox(height: 24),

          _label('Link para pedir feedback'),
          const SizedBox(height: 8),
          _readonlyField(
            value: _session.sessionFeedbackUrl,
            mono: false,
            valueColor: AppColors.inkSoft,
            borderColor: AppColors.border,
            dashed: false,
            fill: const Color(0xFFF4F1EB),
            onCopy: () => _copy(_session.sessionFeedbackUrl, 'Link copiado para sua área de transferência!'),
            copyLabel: 'Copiar link',
            copyFilled: true,
          ),
          const SizedBox(height: 6),
          _hint('Envie para quem convive com você. Você pode compartilhar depois também.'),
          const SizedBox(height: 24),

          _saveReminder(),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(text, style: AppTheme.body(const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink)));
  Widget _hint(String text) => Text(text, style: AppTheme.body(const TextStyle(fontSize: 14, color: AppColors.inkMuted)));

  Widget _readonlyField({
    required String value,
    required bool mono,
    required Color valueColor,
    required Color borderColor,
    required bool dashed,
    required Color fill,
    required VoidCallback onCopy,
    required String copyLabel,
    required bool copyFilled,
  }) {
    final field = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(AppRadius.input),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontFamily: mono ? 'monospace' : null,
          fontSize: mono ? 24 : 15,
          fontWeight: mono ? FontWeight.w700 : FontWeight.w500,
          letterSpacing: mono ? 2 : 0,
          color: valueColor,
        ),
      ),
    );

    final copyBtn = copyFilled
        ? ElevatedButton.icon(onPressed: onCopy, icon: const Icon(Icons.link, size: 18), label: Text(copyLabel))
        : OutlinedButton.icon(onPressed: onCopy, icon: const Icon(Icons.copy, size: 18), label: Text(copyLabel));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [field, const SizedBox(height: 10), Align(alignment: Alignment.centerLeft, child: copyBtn)],
    );
  }

  Widget _saveReminder() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.amberSoft, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: AppTheme.body(const TextStyle(fontSize: 15, color: Color(0xFF5A3C1F), height: 1.5)),
              children: const [
                TextSpan(text: 'Guarde este código. ', style: TextStyle(fontWeight: FontWeight.w700)),
                TextSpan(text: 'Não há login: ele é a única forma de voltar aos seus resultados.'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => setState(() => _savedAck = !_savedAck),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Checkbox(
                    value: _savedAck,
                    onChanged: (v) => setState(() => _savedAck = v ?? false),
                    activeColor: AppColors.amber,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  const SizedBox(width: 8),
                  Text('Já salvei meu código', style: AppTheme.body(const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF5A3C1F)))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
        const SizedBox(width: 12),
        _savingData
            ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5)))
            : ElevatedButton.icon(
                onPressed: _savedAck ? _submit : null,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.amber, disabledBackgroundColor: AppColors.border),
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: const Text('Continuar para a autoavaliação'),
              ),
      ],
    );
  }
}
