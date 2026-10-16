// ignore_for_file: use_build_context_synchronously

import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';

import 'package:teb_janelajohari/local_data_controller.dart';
import 'package:teb_janelajohari/main/widgets/johari_logo.dart';
import 'package:teb_janelajohari/public_area/invalid_access_screen.dart';
import 'package:teb_janelajohari/public_area/session/session_controller.dart';
import 'package:teb_janelajohari/public_area/session_feedbacks/session_feedbacks_controller.dart';
import 'package:teb_janelajohari/public_area/session_feedbacks/session_feedbacks.dart';
import 'package:teb_janelajohari/public_area/session/session.dart';
import 'package:teb_janelajohari/routes.dart';
import 'package:teb_janelajohari/theme/app_theme.dart';
import 'package:teb_package/messaging/teb_message.dart';
import 'package:teb_package/util/teb_return.dart';

class FeedbackScreen extends StatefulWidget {
  final Session? session;
  final FeedbackType? feedbackType;
  final bool? mobile;
  final String? sessionFeedbackId;
  const FeedbackScreen({super.key, this.session, this.feedbackType, this.mobile, this.sessionFeedbackId});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  var _initializing = true;
  var _session = Session();
  var _sessionFeedbacks = SessionFeedbacks();
  var _mobile = false;

  var _hasOthersFeedback = false;
  var _savingCustomAdjective = false;

  final TextEditingController _commentsController = TextEditingController();
  final TextEditingController _customController = TextEditingController();
  bool _customIsPositive = true;

  bool get _isSelf => _sessionFeedbacks.feedbackType == FeedbackType.self;

  bool _isSelected(String adjective) =>
      _sessionFeedbacks.positiveAdjectives.contains(adjective) || _sessionFeedbacks.constructiveAdjectives.contains(adjective);

  void _toggle(String adjective, bool isPositive) {
    final selected = _isSelected(adjective);
    if (!selected && _sessionFeedbacks.totalAdjectivesLengh >= 10) {
      TebMessage.error(context, message: 'Selecione no máximo 10 adjetivos!');
      return;
    }
    setState(() {
      if (selected) {
        _sessionFeedbacks.removeAdjective(adjective: adjective, isPositive: isPositive);
      } else {
        _sessionFeedbacks.addAdjective(adjective: adjective, isPositive: isPositive);
      }
    });
  }

  void _addCustom() {
    final text = _customController.text.trim();
    if (text.isEmpty) {
      TebMessage.error(context, message: 'Você não informou o adjetivo');
      return;
    }
    if (_savingCustomAdjective) return;
    _savingCustomAdjective = true;
    try {
      final list = _customIsPositive ? _session.positiveAdjectives : _session.constructiveAdjectives;
      final exists = list.any((e) => removeDiacritics(e.toUpperCase().trim()) == removeDiacritics(text.toUpperCase().trim()));
      if (exists) {
        TebMessage.error(context, message: 'Já existe um adjetivo com este nome');
        return;
      }
      final word = text[0].toUpperCase() + text.substring(1);
      if (_customIsPositive) {
        _session.positiveAdjectives.add(word);
      } else {
        _session.constructiveAdjectives.add(word);
      }
      SessionController().save(session: _session).then((_) => setState(() => _customController.clear()));
    } finally {
      _savingCustomAdjective = false;
    }
  }

  void _submit() async {
    if (_sessionFeedbacks.totalAdjectivesLengh < 5) {
      TebMessage.error(context, message: 'Selecione entre 5 e 10 adjetivos antes de concluir');
      return;
    }
    if (_session.id.isEmpty) {
      TebMessage.error(context, message: 'Estranho, sessão não encontrada!');
      return;
    }

    final retorno = await SessionFeedbackController().save(sessionFeedbacks: _sessionFeedbacks, session: _session);
    if (!mounted) return;
    if (retorno.returnType != TebReturn.success.returnType) {
      TebMessage.error(context, message: retorno.message);
      return;
    }

    if (_isSelf) {
      LocalDataController().saveSession(session: _session);
      TebMessage.success(context, message: 'Reflexão individual salva! Agora compartilhe o link de feedback com seus colegas.');
      Navigator.of(context).popAndPushNamed(Routes.landingScreen);
    } else {
      TebMessage.success(context, message: 'Feedback enviado com sucesso. Obrigado por contribuir!');
      Navigator.of(context).popAndPushNamed(Routes.landingScreen, arguments: {'ignoreQueryParameters': true});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;
      _session = arguments['session'] ?? Session();
      _mobile = arguments['mobile'] ?? false;
      _mobile = widget.mobile ?? _mobile;
      _sessionFeedbacks = arguments['sessionFeedbacks'] ?? SessionFeedbacks();
      if (widget.session != null && widget.session!.id.isNotEmpty) _session = widget.session!;
      _sessionFeedbacks.feedbackType = arguments['feedbackType'] ?? widget.feedbackType ?? FeedbackType.self;

      if (_sessionFeedbacks.feedbackType == FeedbackType.self) {
        SessionFeedbackController().getSessionFeedbacksBySessionId(sessionId: _session.id, feedbackType: FeedbackType.others).then((value) {
          if (value.isNotEmpty && mounted) setState(() => _hasOthersFeedback = true);
        });
      }

      if ((widget.sessionFeedbackId ?? '') != '') {
        SessionFeedbackController().getSessionFeedbackBySessionFeedbackId(sessionId: _session.id, sessionFeedbackId: widget.sessionFeedbackId!).then((value) {
          if (!mounted) return;
          setState(() {
            _sessionFeedbacks = value;
            _commentsController.text = _sessionFeedbacks.comments;
          });
        });
      }

      _initializing = false;
    }

    if (_session.id.isEmpty) return const InvalidAccessScreen();

    final narrow = _mobile || MediaQuery.of(context).size.width < 900;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Column(
        children: [
          _header(),
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(narrow ? 20 : 48, 40, narrow ? 20 : 48, 80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _intro(),
                        const SizedBox(height: 28),
                        narrow
                            ? Column(children: [_mainColumn(), const SizedBox(height: 24), _summary()])
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(flex: 3, child: _mainColumn()),
                                  const SizedBox(width: 28),
                                  SizedBox(width: 320, child: _summary()),
                                ],
                              ),
                      ],
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
    final badge = _isSelf ? 'Etapa 2 de 4 · Autoavaliação' : 'Feedback para ${_session.name}';
    return Container(
      decoration: const BoxDecoration(color: AppColors.cream, border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: _mobile ? 20 : 48, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Flexible(child: JohariLogo()),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.pill), border: Border.all(color: AppColors.border)),
              child: Text(badge, style: AppTheme.body(const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.inkSoft))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _intro() {
    final name = _session.name;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isSelf ? 'AUTOAVALIAÇÃO' : '$name PEDIU SUA PERCEPÇÃO',
          style: AppTheme.body(const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 1.1, color: AppColors.teal)),
        ),
        const SizedBox(height: 10),
        Text(
          _isSelf ? 'Como você se vê?' : 'Como você percebe $name?',
          style: AppTheme.display(TextStyle(fontSize: _mobile ? 36 : 50, color: AppColors.ink, height: 1.05, letterSpacing: -0.5)),
        ),
        const SizedBox(height: 10),
        Text(
          _isSelf
              ? 'Toque nos adjetivos que melhor descrevem você hoje. Não há respostas certas: vale o que você sente.'
              : 'Escolha os adjetivos que você percebe em $name no dia a dia. Seja sincero e gentil — seu olhar ajuda a crescer.',
          style: AppTheme.body(const TextStyle(fontSize: 18, color: AppColors.inkSoft, height: 1.5)),
        ),
      ],
    );
  }

  Widget _mainColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _adjectiveSection(
          title: 'Pontos fortes',
          subtitle: 'Atitudes e comportamentos percebidos como positivos',
          icon: Icons.star_outline,
          accent: AppColors.teal,
          accentDark: AppColors.tealDark,
          accentSoft: AppColors.tealSoft,
          adjectives: [..._session.positiveAdjectives]..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase())),
          count: _sessionFeedbacks.positiveAdjectives.length,
          isPositive: true,
        ),
        const SizedBox(height: 24),
        _adjectiveSection(
          title: 'Pontos de desenvolvimento',
          subtitle: 'Tendências a observar — oportunidades de crescimento, não defeitos',
          icon: Icons.trending_up,
          accent: AppColors.amber,
          accentDark: AppColors.amberDark,
          accentSoft: AppColors.amberSoft,
          adjectives: [..._session.constructiveAdjectives]..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase())),
          count: _sessionFeedbacks.constructiveAdjectives.length,
          isPositive: false,
        ),
        if (_isSelf && !_hasOthersFeedback) ...[const SizedBox(height: 24), _addSection()],
        const SizedBox(height: 24),
        _comment(),
      ],
    );
  }

  Widget _adjectiveSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accent,
    required Color accentDark,
    required Color accentSoft,
    required List<String> adjectives,
    required int count,
    required bool isPositive,
  }) {
    return Container(
      padding: EdgeInsets.all(_mobile ? 22 : 32),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.cardLarge), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: accentSoft, borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, color: accent, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTheme.display(const TextStyle(fontSize: 24, color: AppColors.ink))),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTheme.body(const TextStyle(fontSize: 14, color: AppColors.inkMuted))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: accentSoft, borderRadius: BorderRadius.circular(AppRadius.pill)),
                child: Text('$count selecionados', style: AppTheme.body(TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: accentDark))),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: adjectives.map((adj) => _chip(adj, isPositive, accent)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _chip(String adjective, bool isPositive, Color accent) {
    final selected = _isSelected(adjective);
    return Material(
      color: selected ? accent : AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        onTap: () => _toggle(adjective, isPositive),
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: EdgeInsets.fromLTRB(selected ? 12 : 16, 8, 16, 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: selected ? accent : AppColors.chipBorder, width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[const Icon(Icons.check, size: 16, color: Colors.white), const SizedBox(width: 6)],
              Text(
                adjective,
                style: AppTheme.body(TextStyle(
                  fontSize: 15,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  color: selected ? Colors.white : AppColors.ink,
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _addSection() {
    Widget targetButton(String label, bool isPositive) {
      final active = _customIsPositive == isPositive;
      final color = isPositive ? AppColors.teal : AppColors.amberDark;
      return InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => setState(() => _customIsPositive = isPositive),
        child: Container(
          constraints: const BoxConstraints(minHeight: 40),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(color: active ? color : Colors.transparent, borderRadius: BorderRadius.circular(10)),
          child: Text(label, style: AppTheme.body(TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: active ? Colors.white : AppColors.ink))),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(_mobile ? 20 : 28),
      decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(AppRadius.card)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Não encontrou a palavra certa?', style: AppTheme.body(const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink))),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.chipBorder, width: 1.5)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [targetButton('Ponto forte', true), const SizedBox(width: 4), targetButton('Desenvolvimento', false)]),
              ),
              SizedBox(
                width: 240,
                child: TextField(
                  controller: _customController,
                  decoration: const InputDecoration(hintText: 'Ex.: Bem-humorado'),
                  onSubmitted: (_) => _addCustom(),
                ),
              ),
              ElevatedButton(
                onPressed: _addCustom,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.ink),
                child: const Text('Adicionar'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text('O novo adjetivo entra disponível para você e seu time. Palavras repetidas são ignoradas.',
              style: AppTheme.body(const TextStyle(fontSize: 14, color: AppColors.inkMuted))),
        ],
      ),
    );
  }

  Widget _comment() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text('Comentário ', style: AppTheme.body(const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink))),
          Text('(opcional)', style: AppTheme.body(const TextStyle(fontSize: 16, color: AppColors.inkMuted))),
        ]),
        const SizedBox(height: 8),
        TextField(
          controller: _commentsController,
          minLines: 3,
          maxLines: 6,
          onChanged: (v) => _sessionFeedbacks.comments = v,
          decoration: InputDecoration(
            hintText: _isSelf ? 'Uma anotação para você mesmo(a) revisitar depois…' : 'Algo que você queira dizer com suas palavras…',
          ),
        ),
      ],
    );
  }

  Widget _summary() {
    final chosen = [
      ..._sessionFeedbacks.positiveAdjectives.map((a) => (a, AppColors.teal)),
      ..._sessionFeedbacks.constructiveAdjectives.map((a) => (a, AppColors.amber)),
    ];
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(color: AppColors.panel, borderRadius: BorderRadius.circular(AppRadius.cardLarge)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SUA SELEÇÃO', style: AppTheme.body(const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 1.1, color: AppColors.tealOnDark))),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${_sessionFeedbacks.totalAdjectivesLengh}', style: AppTheme.display(const TextStyle(fontSize: 60, color: Colors.white, height: 1))),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text('adjetivos\nescolhidos', style: AppTheme.body(const TextStyle(fontSize: 14, color: AppColors.onPanel, height: 1.2))),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: chosen
                .map((c) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: c.$2, borderRadius: BorderRadius.circular(AppRadius.pill)),
                      child: Text(c.$1, style: AppTheme.body(const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white))),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFF3A4756)),
          const SizedBox(height: 8),
          Text(
            'Na dinâmica original escolhem-se de 5 a 10 adjetivos. Foco ajuda a leitura.',
            style: AppTheme.body(const TextStyle(fontSize: 14, color: AppColors.onPanel, height: 1.5)),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: AppColors.ink),
              icon: const Icon(Icons.arrow_forward, size: 18),
              label: Text(_isSelf ? 'Salvar e ver minha janela' : 'Enviar feedback'),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).popAndPushNamed(Routes.landingScreen, arguments: {'ignoreQueryParameters': true}),
              style: TextButton.styleFrom(foregroundColor: AppColors.onPanel),
              child: const Text('Sair sem responder'),
            ),
          ),
        ],
      ),
    );
  }
}
