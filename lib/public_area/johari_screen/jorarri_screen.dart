import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:teb_janelajohari/local_data_controller.dart';
import 'package:teb_janelajohari/main/widgets/johari_logo.dart';
import 'package:teb_janelajohari/public_area/invalid_access_screen.dart';
import 'package:teb_janelajohari/public_area/session_feedbacks/session_feedbacks_controller.dart';
import 'package:teb_janelajohari/public_area/session_feedbacks/session_feedbacks.dart';
import 'package:teb_janelajohari/public_area/session/session.dart';
import 'package:teb_janelajohari/routes.dart';
import 'package:teb_janelajohari/theme/app_theme.dart';
import 'package:teb_package/messaging/teb_message.dart';

class JohariScreen extends StatefulWidget {
  final Session? session;
  final bool? mobile;
  const JohariScreen({super.key, this.session, this.mobile});

  @override
  State<JohariScreen> createState() => _JohariScreenState();
}

class _JohariScreenState extends State<JohariScreen> {
  var _session = Session();
  var _initializing = true;
  var _mobile = false;

  List<String> _list(Map<String, dynamic> area, String key) => List<String>.from(area[key] ?? const <String>[]);

  void _copy(String value, String message) {
    Clipboard.setData(ClipboardData(text: value));
    TebMessage.success(context, message: message);
  }

  void _confirmExit() {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card)),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Guarde seu código de acesso', style: AppTheme.display(const TextStyle(fontSize: 24, color: AppColors.ink))),
              const SizedBox(height: 12),
              Text(
                'Seu código (${_session.accessCode}) é a única forma de voltar aos seus resultados. '
                'Copie-o antes de sair.',
                style: AppTheme.body(const TextStyle(fontSize: 15, color: AppColors.inkSoft, height: 1.5)),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.copy, size: 18),
                  label: const Text('Copiar código e sair'),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _session.accessCode));
                    Navigator.of(ctx).pop(true);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ).then((value) {
      if (value == true && mounted) {
        LocalDataController().clearSessionData();
        Navigator.of(context).popAndPushNamed(Routes.landingScreen, arguments: {'ignoreQueryParameters': true});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;
      _session = arguments['session'] ?? Session();
      _mobile = arguments['mobile'] ?? false;
      _mobile = widget.mobile ?? _mobile;
      if (widget.session != null && widget.session!.id.isNotEmpty) _session = widget.session!;
      _initializing = false;
    }

    if (_session.id.isEmpty) return const InvalidAccessScreen();

    final narrow = _mobile || MediaQuery.of(context).size.width < 900;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: StreamBuilder<QuerySnapshot>(
        stream: SessionFeedbackController().getSessionFeedbacks(sessionId: _session.id),
        builder: (context, snapshot) {
          final List<SessionFeedbacks> sessionFeedbacks = [];
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            sessionFeedbacks.addAll(snapshot.data!.docs.map((e) => SessionFeedbacks.fromDocument(e)));
          }
          final feedbacks = SessionFeedbackController.getAllAreasFeedback(feedbacks: sessionFeedbacks);

          final self = feedbacks['selfFeedback']!;
          final others = feedbacks['othersFeedback']!;
          final open = feedbacks['openArea']!;
          final blind = feedbacks['blindArea']!;
          final hidden = feedbacks['hiddenArea']!;

          final selfCount = _list(self, 'positiveAdjectives').length + _list(self, 'constructiveAdjectives').length;
          final othersCount = (others['count'] ?? 0) as int;
          final openAll = [..._list(open, 'positiveAdjectives'), ..._list(open, 'constructiveAdjectives')];
          final comments = _list(others, 'comments');

          return Column(
            children: [
              _header(),
              Expanded(
                child: SingleChildScrollView(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1240),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(narrow ? 20 : 48, 40, narrow ? 20 : 48, 80),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _greeting(othersCount, selfCount, openAll.length, narrow),
                            const SizedBox(height: 28),
                            narrow
                                ? Column(
                                    children: [
                                      _matrix(open, blind, hidden, narrow),
                                      const SizedBox(height: 24),
                                      _sidebar(feedbacks, comments),
                                    ],
                                  )
                                : Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(flex: 3, child: _matrix(open, blind, hidden, narrow)),
                                      const SizedBox(width: 28),
                                      SizedBox(width: 360, child: _sidebar(feedbacks, comments)),
                                    ],
                                  ),
                            const SizedBox(height: 40),
                            Center(
                              child: OutlinedButton.icon(
                                onPressed: _confirmExit,
                                icon: const Icon(Icons.logout, size: 18),
                                label: const Text('Deixar esta sessão'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
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
            const Flexible(child: JohariLogo()),
            Wrap(
              spacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (!_mobile)
                  RichText(
                    text: TextSpan(
                      style: AppTheme.body(const TextStyle(fontSize: 14, color: AppColors.inkSoft)),
                      children: [
                        const TextSpan(text: 'Código '),
                        TextSpan(
                          text: _session.accessCode,
                          style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.amberDark, fontFamily: 'monospace'),
                        ),
                      ],
                    ),
                  ),
                TextButton(onPressed: _confirmExit, child: const Text('Sair')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _greeting(int othersCount, int selfCount, int openCount, bool narrow) {
    Widget stat(String label, String value, {Color? bg, Color? fg}) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      constraints: const BoxConstraints(minWidth: 120),
      decoration: BoxDecoration(
        color: bg ?? AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: bg == null ? Border.all(color: AppColors.border) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTheme.body(TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: fg ?? AppColors.inkMuted)),
          ),
          const SizedBox(height: 2),
          Text(value, style: AppTheme.display(TextStyle(fontSize: 30, color: fg ?? AppColors.ink))),
        ],
      ),
    );

    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SUA JANELA',
          style: AppTheme.body(const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 1.1, color: AppColors.teal)),
        ),
        const SizedBox(height: 8),
        Text(
          'Olá, ${_session.name}. Veja como você é percebido(a).',
          style: AppTheme.display(TextStyle(fontSize: narrow ? 32 : 46, color: AppColors.ink, height: 1.05, letterSpacing: -0.5)),
        ),
      ],
    );

    final stats = Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        stat('Feedbacks recebidos', '$othersCount'),
        stat('Na sua autoavaliação', '$selfCount'),
        stat('Em comum', '$openCount', bg: AppColors.tealSoft, fg: AppColors.tealDark),
      ],
    );

    return narrow
        ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [title, const SizedBox(height: 20), stats])
        : Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: title),
              const SizedBox(width: 24),
              stats,
            ],
          );
  }

  Widget _matrix(Map<String, dynamic> open, Map<String, dynamic> blind, Map<String, dynamic> hidden, bool narrow) {
    final cells = [
      _quadrant(
        'Aberto',
        'Você sabe · Outros sabem',
        'Você e os colegas concordam.',
        AppColors.tealDark,
        AppColors.tealSoft,
        [..._list(open, 'positiveAdjectives'), ..._list(open, 'constructiveAdjectives')],
        emptyText: 'Ainda sem adjetivos em comum.',
      ),
      _quadrant(
        'Cego',
        'Você não · Outros sabem',
        'Os colegas veem e você não marcou.',
        AppColors.blueDark,
        AppColors.blueSoft,
        [..._list(blind, 'positiveAdjectives'), ..._list(blind, 'constructiveAdjectives')],
        emptyText: 'Nada aqui — por enquanto.',
      ),
      _quadrant(
        'Oculto',
        'Você sabe · Outros não',
        'Só você marcou — ainda não aparece para os outros.',
        AppColors.amberDark,
        AppColors.amberSoft,
        [..._list(hidden, 'positiveAdjectives'), ..._list(hidden, 'constructiveAdjectives')],
        emptyText: 'Nada guardado só para você.',
      ),
      _quadrantUnknown(),
    ];

    if (narrow) {
      return Column(
        children: [
          for (final c in cells)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(color: c.bg, borderRadius: BorderRadius.circular(AppRadius.card)),
              child: c.content,
            ),
        ],
      );
    }
    return Column(children: [_quadrantRow(cells[0], cells[1]), const SizedBox(height: 12), _quadrantRow(cells[2], cells[3])]);
  }

  /// Dois quadrantes lado a lado com a mesma altura. O conteúdo define a
  /// altura pelo layout normal e os fundos se esticam atrás dele — sem
  /// IntrinsicHeight, cuja medição pode divergir e gerar overflow.
  Widget _quadrantRow(({Color bg, Widget content}) left, ({Color bg, Widget content}) right) {
    Widget background(Color bg) => Expanded(
      child: DecoratedBox(
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppRadius.card)),
      ),
    );
    return Stack(
      children: [
        Positioned.fill(child: Row(children: [background(left.bg), const SizedBox(width: 12), background(right.bg)])),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: left.content),
            const SizedBox(width: 12),
            Expanded(child: right.content),
          ],
        ),
      ],
    );
  }

  ({Color bg, Widget content}) _quadrant(
    String title,
    String corner,
    String desc,
    Color color,
    Color bg,
    List<String> adjectives, {
    required String emptyText,
  }) {
    return (
      bg: bg,
      content: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.display(TextStyle(fontSize: 26, color: color))),
                Flexible(
                  child: Text(
                    corner,
                    textAlign: TextAlign.right,
                    style: AppTheme.body(TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: color)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(desc, style: AppTheme.body(TextStyle(fontSize: 14, color: color.withValues(alpha: 0.85)))),
            const SizedBox(height: 12),
            if (adjectives.isEmpty)
              Text(
                emptyText,
                style: AppTheme.body(TextStyle(fontSize: 14, color: color.withValues(alpha: 0.7), fontStyle: FontStyle.italic)),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (adjectives.toSet().toList()..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase())))
                    .map(
                      (a) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.pill)),
                        child: Text(
                          a,
                          style: AppTheme.body(TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
                        ),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  ({Color bg, Widget content}) _quadrantUnknown() {
    return (
      bg: AppColors.purpleSoft,
      content: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Desconhecido', style: AppTheme.display(const TextStyle(fontSize: 26, color: AppColors.purpleDark))),
                Text(
                  'Ninguém marcou',
                  style: AppTheme.body(const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.purpleDark)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Potenciais ainda não revelados — ou que não fazem parte de você. Costumam aparecer com novas experiências e desafios.',
              style: AppTheme.body(TextStyle(fontSize: 14, color: AppColors.purpleDark.withValues(alpha: 0.85))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sidebar(Map<String, Map<String, dynamic>> feedbacks, List<String> comments) {
    final promptText = _getIAText(feedbacks);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // IA
        Container(
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(color: AppColors.panel, borderRadius: BorderRadius.circular(AppRadius.cardLarge)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome, size: 18, color: AppColors.tealOnDark),
                  const SizedBox(width: 8),
                  Text(
                    'ANÁLISE COM IA',
                    style: AppTheme.body(
                      const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 1.1, color: AppColors.tealOnDark),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'Transforme sua janela em um plano',
                style: AppTheme.display(const TextStyle(fontSize: 24, color: Colors.white, height: 1.15)),
              ),
              const SizedBox(height: 10),
              Text(
                'Copie o prompt pronto e cole no assistente de IA que preferir.',
                style: AppTheme.body(const TextStyle(fontSize: 15, color: AppColors.onPanel)),
              ),
              const SizedBox(height: 16),
              Container(
                constraints: const BoxConstraints(maxHeight: 220),
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.panelSoft, borderRadius: BorderRadius.circular(16)),
                child: SingleChildScrollView(
                  child: Text(
                    promptText,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12.5, height: 1.5, color: Color(0xFFDCE3EA)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: AppColors.ink),
                  icon: const Icon(Icons.copy, size: 18),
                  label: const Text('Copiar prompt'),
                  onPressed: () => _copy(promptText, 'Prompt copiado para sua área de transferência!'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Share
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: AppColors.tealSoft, borderRadius: BorderRadius.circular(AppRadius.card)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quanto mais olhares, mais nítida a janela',
                style: AppTheme.body(const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.tealDark)),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.link, size: 18),
                  label: const Text('Copiar link de feedback'),
                  onPressed: () => _copy(_session.sessionFeedbackUrl, 'Link copiado para sua área de transferência!'),
                ),
              ),
            ],
          ),
        ),
        if (comments.isNotEmpty) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Comentários dos colegas (${comments.length})',
                  style: AppTheme.body(const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink)),
                ),
                const SizedBox(height: 14),
                ...comments.map(
                  (c) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: AppColors.cream, borderRadius: BorderRadius.circular(16)),
                      child: Text(c, style: AppTheme.body(const TextStyle(fontSize: 15, color: Color(0xFF33404C), height: 1.4))),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ---------------------------------------------------------------------
  // Prompt de IA (mantido do comportamento original).
  // ---------------------------------------------------------------------

  String _getAdjectivesListText(List<dynamic>? list) {
    if (list == null || list.isEmpty) return '';
    return list.map((e) => e.toString()).join(', ');
  }

  String _getIAText(Map<String, Map<String, dynamic>> feedbacks) {
    final commentsRaw = feedbacks['othersFeedback']!['comments'];
    final commentsList = (commentsRaw == null || (commentsRaw as List).isEmpty) ? '' : commentsRaw.map((item) => '   "$item"\n').join();

    var text =
        'Você é um analista de desenvolvimento humano e comportamento.\n'
        '\n'
        'Quero que analise os resultados de uma dinâmica da Janela de Johari, considerando os adjetivos que surgiram nas três áreas (aberta, cega e oculta).\n'
        '\n'
        'Seu objetivo é:\n'
        '  - Fazer um resumo sobre como a pessoa é percebida por si mesma e pelos outros.\n'
        '  - Identificar possíveis lacunas de autoconhecimento ou oportunidades de crescimento.\n'
        '  - Sugerir planos de ação práticos para desenvolvimento pessoal e profissional reduzindo a área cega ao mesmo tempo que ajuda a expandir a área aberta.\n'
        '\n'
        'Aqui estão os resultados:\n'
        ' - Área Aberta (conhecida por si e pelos outros):\n'
        '   - adjetivos positivos: #AREA_ABERTA_ADJETIVOS_POSITIVOS#\n'
        '   - construtivos: #AREA_ABERTA_ADJETIVOS_CONSTRUTIVOS#\n'
        '\n'
        ' - Área Cega (percebida pelos outros, mas não por si)\n'
        '   - adjetivos positivos: #AREA_CEGA_ADJETIVOS_POSITIVOS#\n'
        '   - construtivos: #AREA_CEGA_ADJETIVOS_CONSTRUTIVOS#\n'
        '\n'
        ' - Área Oculta (conhecida por si, mas não revelada aos outros)\n'
        '   - adjetivos positivos: #AREA_OCULTA_ADJETIVOS_POSITIVOS#\n'
        '   - construtivos: #AREA_OCULTA_ADJETIVOS_CONSTRUTIVOS#\n'
        '\n'
        ' - Comentários deixados pelas pessoas que contribuíram com feedbacks:\n'
        '#LISTA_COMENTARIOS#'
        '\n'
        'Com base nesses dados, elabore um texto com:\n'
        '  - Um resumo da autoimagem da pessoa comparada à imagem que os outros têm dela.\n'
        '  - Interpretações sobre o que isso pode significar em seu contexto profissional ou pessoal.\n'
        '  - Sugestões práticas de desenvolvimento (ex: conversas de feedback, coaching, novos comportamentos, etc.)';

    final replaceStringList = {
      '#LISTA_COMENTARIOS#': commentsList,
      '#AREA_ABERTA_ADJETIVOS_POSITIVOS#': _getAdjectivesListText(feedbacks['openArea']!['positiveAdjectives']),
      '#AREA_ABERTA_ADJETIVOS_CONSTRUTIVOS#': _getAdjectivesListText(feedbacks['openArea']!['constructiveAdjectives']),
      '#AREA_CEGA_ADJETIVOS_POSITIVOS#': _getAdjectivesListText(feedbacks['blindArea']!['positiveAdjectives']),
      '#AREA_CEGA_ADJETIVOS_CONSTRUTIVOS#': _getAdjectivesListText(feedbacks['blindArea']!['constructiveAdjectives']),
      '#AREA_OCULTA_ADJETIVOS_POSITIVOS#': _getAdjectivesListText(feedbacks['hiddenArea']!['positiveAdjectives']),
      '#AREA_OCULTA_ADJETIVOS_CONSTRUTIVOS#': _getAdjectivesListText(feedbacks['hiddenArea']!['constructiveAdjectives']),
    };

    replaceStringList.forEach((key, value) => text = text.replaceAll(key, value));
    return text;
  }
}
