import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:teb_janelajohari/local_data_controller.dart';
import 'package:teb_janelajohari/main/widgets/johari_logo.dart';
import 'package:teb_janelajohari/main/widgets/podcast_widget.dart';
import 'package:teb_janelajohari/public_area/session/session_controller.dart';
import 'package:teb_janelajohari/routes.dart';
import 'package:teb_janelajohari/theme/app_theme.dart';
import 'package:teb_package/messaging/teb_message.dart';
import 'package:teb_package/util/teb_return.dart';

/// Tela inicial (landing) — redesenho da Janela de Johari.
class WellcomeScreen extends StatefulWidget {
  const WellcomeScreen({super.key});

  @override
  State<WellcomeScreen> createState() => _WellcomeScreenState();
}

class _WellcomeScreenState extends State<WellcomeScreen> {
  static const double _maxWidth = 1180;

  final _scrollController = ScrollController();
  final _comecarKey = GlobalKey();
  final _oQueEKey = GlobalKey();
  final _comoFuncionaKey = GlobalKey();

  final _codeController = TextEditingController();
  bool _entering = false;

  @override
  void dispose() {
    _scrollController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 450), curve: Curves.easeInOut);
    }
  }

  void _createSession(bool narrow) {
    Navigator.of(context).pushNamed(Routes.sessionForm, arguments: {'mobile': narrow});
  }

  Future<void> _enterWithCode(bool narrow) async {
    if (_entering) return;
    if (_codeController.text.trim().isEmpty) {
      TebMessage.error(context, message: 'Informe o código de acesso da sua sessão');
      return;
    }
    setState(() => _entering = true);
    try {
      final controller = SessionController();
      final result = await controller.getCurrentSessionByAccessCode(accessCode: _codeController.text);
      if (!mounted) return;
      if (result.returnType == TebReturnType.error) {
        TebMessage.error(context, message: result.message);
        return;
      }
      LocalDataController().saveSession(session: controller.currentSession);
      Navigator.of(context).popAndPushNamed(
        Routes.johariScreen,
        arguments: {'session': controller.currentSession, 'mobile': narrow},
      );
    } finally {
      if (mounted) setState(() => _entering = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 900;
          return SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                _header(narrow),
                _bounded(_hero(narrow), narrow),
                _bounded(KeyedSubtree(key: _comecarKey, child: _comecar(narrow)), narrow, top: 8, bottom: 72),
                Container(
                  key: _oQueEKey,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(top: BorderSide(color: AppColors.border), bottom: BorderSide(color: AppColors.border)),
                  ),
                  child: _bounded(_oQueE(narrow), narrow, top: 72, bottom: 72),
                ),
                _bounded(KeyedSubtree(key: _comoFuncionaKey, child: _comoFunciona(narrow)), narrow, top: 72, bottom: 72),
                Container(width: double.infinity, color: AppColors.panel, child: _bounded(_porQue(narrow), narrow, top: 72, bottom: 72)),
                _bounded(_contato(narrow), narrow, top: 64, bottom: 40),
                _footer(narrow),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---- layout helpers ---------------------------------------------------

  Widget _bounded(Widget child, bool narrow, {double top = 0, double bottom = 0}) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxWidth),
        child: Padding(
          padding: EdgeInsets.fromLTRB(narrow ? 20 : 48, top, narrow ? 20 : 48, bottom),
          child: child,
        ),
      ),
    );
  }

  TextStyle _eyebrow(Color color) =>
      AppTheme.body(TextStyle(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: color));

  Widget _display(String text, {required double size, Color color = AppColors.ink, double height = 1.08}) =>
      Text(text, style: AppTheme.display(TextStyle(fontSize: size, color: color, height: height, letterSpacing: -0.5)));

  // ---- header -----------------------------------------------------------

  Widget _header(bool narrow) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cream,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxWidth),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: narrow ? 20 : 48, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Flexible(child: JohariLogo()),
                if (!narrow)
                  Row(
                    children: [
                      _navLink('O que é', () => _scrollTo(_oQueEKey)),
                      _navLink('Como funciona', () => _scrollTo(_comoFuncionaKey)),
                      _navLink('Dar feedback', () => _scrollTo(_comecarKey)),
                      const SizedBox(width: 8),
                      _pill('Criar sessão', AppColors.panel, Colors.white, () => _createSession(narrow)),
                    ],
                  )
                else
                  _pill('Criar', AppColors.panel, Colors.white, () => _createSession(narrow)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navLink(String label, VoidCallback onTap) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(foregroundColor: AppColors.ink),
      child: Text(label, style: AppTheme.body(const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.ink))),
    );
  }

  Widget _pill(String label, Color bg, Color fg, VoidCallback onTap, {IconData? icon}) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: AppTheme.body(TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: fg))),
              if (icon != null) ...[const SizedBox(width: 8), Icon(icon, size: 18, color: fg)],
            ],
          ),
        ),
      ),
    );
  }

  // ---- hero -------------------------------------------------------------

  Widget _hero(bool narrow) {
    final texts = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Autoconhecimento · Feedback · Equipes', style: _eyebrow(AppColors.teal)),
        const SizedBox(height: 16),
        _display('Como você se vê.\nComo os outros veem você.', size: narrow ? 40 : 60, height: 1.03),
        const SizedBox(height: 20),
        Text(
          'A Janela de Johari cruza a sua autopercepção com o olhar de quem convive com você. '
          'Descubra pontos em comum, surpresas e caminhos para crescer — com leveza e segurança.',
          style: AppTheme.body(const TextStyle(fontSize: 19, color: AppColors.inkSoft, height: 1.5)),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _pill('Criar minha sessão', AppColors.amber, Colors.white, () => _createSession(narrow), icon: Icons.arrow_forward),
            _pill('Tenho um código', AppColors.surface, AppColors.ink, () => _scrollTo(_comecarKey)),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.verified_user_outlined, size: 18, color: AppColors.teal),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Sem cadastro: você acessa com um código, seus colegas com um link.',
                style: AppTheme.body(const TextStyle(fontSize: 14, color: AppColors.inkMuted)),
              ),
            ),
          ],
        ),
      ],
    );

    final matrix = _heroMatrix();

    return Padding(
      padding: EdgeInsets.only(top: narrow ? 40 : 80, bottom: 16),
      child: narrow
          ? Column(children: [texts, const SizedBox(height: 40), matrix])
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: texts),
                const SizedBox(width: 56),
                Expanded(child: matrix),
              ],
            ),
    );
  }

  Widget _heroMatrix() {
    Widget quadrant(String title, String desc, Color titleColor, Color bg, List<String> tags) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(18)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _display(title, size: 22, color: titleColor),
            const SizedBox(height: 6),
            Text(desc, style: AppTheme.body(TextStyle(fontSize: 13.5, color: titleColor.withValues(alpha: 0.85)))),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: tags
                  .map((t) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.pill)),
                        child: Text(t, style: AppTheme.body(TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: titleColor))),
                      ))
                  .toList(),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.cardLarge),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: quadrant('Aberto', 'O que você e os outros enxergam.', AppColors.tealDark, AppColors.tealSoft, ['Organizado', 'Honesto'])),
              const SizedBox(width: 10),
              Expanded(child: quadrant('Cego', 'O que os outros percebem e você ainda não.', AppColors.blueDark, AppColors.blueSoft, ['Empático'])),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: quadrant('Oculto', 'O que você sabe e ainda não mostrou.', AppColors.amberDark, AppColors.amberSoft, ['Criativo'])),
              const SizedBox(width: 10),
              Expanded(child: quadrant('Desconhecido', 'O que ninguém percebeu — ainda.', AppColors.purpleDark, AppColors.purpleSoft, ['a descobrir'])),
            ],
          ),
        ],
      ),
    );
  }

  // ---- começar (criar / código) ----------------------------------------

  Widget _comecar(bool narrow) {
    final criar = Container(
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(color: AppColors.amberSoft, borderRadius: BorderRadius.circular(AppRadius.cardLarge)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _iconBadge(Icons.add, AppColors.amber),
          const SizedBox(height: 16),
          _display('Criar sua sessão', size: 32),
          const SizedBox(height: 12),
          Text(
            'Você escolhe os adjetivos que te definem e recebe um link para enviar a colegas, líderes ou amigos. '
            'Os resultados chegam na sua janela.',
            style: AppTheme.body(const TextStyle(fontSize: 16, color: AppColors.amberDark, height: 1.5)),
          ),
          const SizedBox(height: 20),
          _pill('Criar minha sessão', AppColors.amber, Colors.white, () => _createSession(narrow), icon: Icons.arrow_forward),
        ],
      ),
    );

    final codigo = Container(
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(color: AppColors.tealSoft, borderRadius: BorderRadius.circular(AppRadius.cardLarge)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _iconBadge(Icons.chat_bubble_outline, AppColors.teal),
          const SizedBox(height: 16),
          _display('Dar feedback ou rever sua janela', size: 32),
          const SizedBox(height: 12),
          Text(
            'Recebeu um link? É só abri-lo. Tem um código de acesso? Digite abaixo para responder ou ver seus resultados.',
            style: AppTheme.body(const TextStyle(fontSize: 16, color: AppColors.tealInk, height: 1.5)),
          ),
          const SizedBox(height: 20),
          Text('Código de acesso', style: AppTheme.body(const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.tealDark))),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _codeController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(hintText: 'Ex.: K7Q4-29XM'),
                  onSubmitted: (_) => _enterWithCode(narrow),
                ),
              ),
              const SizedBox(width: 10),
              _entering
                  ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5)))
                  : _pill('Entrar', AppColors.teal, Colors.white, () => _enterWithCode(narrow)),
            ],
          ),
        ],
      ),
    );

    return narrow
        ? Column(children: [criar, const SizedBox(height: 24), codigo])
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Expanded(child: criar), const SizedBox(width: 24), Expanded(child: codigo)],
          );
  }

  Widget _iconBadge(IconData icon, Color color) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
      child: Icon(icon, color: Colors.white, size: 26),
    );
  }

  // ---- o que é ----------------------------------------------------------

  Widget _oQueE(bool narrow) {
    final intro = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('O QUE É', style: _eyebrow(AppColors.teal)),
        const SizedBox(height: 14),
        _display('Um modelo simples para enxergar o que não se vê sozinho', size: narrow ? 30 : 42),
        const SizedBox(height: 16),
        Text(
          'Criada em 1955 pelos psicólogos Joseph Luft e Harrington Ingham — o nome junta Joe e Harry —, a Janela de Johari '
          'organiza o que se sabe sobre uma pessoa em quatro áreas, cruzando dois olhares: o seu e o dos outros.',
          style: AppTheme.body(const TextStyle(fontSize: 16, color: AppColors.inkSoft, height: 1.55)),
        ),
        const SizedBox(height: 12),
        Text(
          'É usada em coaching, desenvolvimento de lideranças e times porque transforma percepções soltas em conversa: '
          'quanto maior a área Aberta, mais fáceis ficam a comunicação e a confiança.',
          style: AppTheme.body(const TextStyle(fontSize: 16, color: AppColors.inkSoft, height: 1.55)),
        ),
      ],
    );

    final cards = [
      _quadrantInfo('Aberto', AppColors.tealDark, 'Você sabe', 'Outros sabem', true, true,
          'Características que você reconhece em si e que os outros também percebem. É a base de uma comunicação aberta.'),
      _quadrantInfo('Oculto', AppColors.amberDark, 'Você sabe', 'Outros não', true, false,
          'O que você conhece sobre si, mas não mostra: sentimentos, receios, intenções. Diminui quando você se abre.'),
      _quadrantInfo('Cego', AppColors.blueDark, 'Você não', 'Outros sabem', false, true,
          'O que os outros percebem em você e você ainda não enxerga. Diminui quando você pede e acolhe feedback.'),
      _quadrantInfo('Desconhecido', AppColors.purpleDark, 'Você não', 'Outros não', false, false,
          'Talentos e comportamentos que ninguém percebeu ainda. Costumam aparecer com novas experiências e desafios.'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        narrow
            ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [intro, const SizedBox(height: 32), PodcastArea(mobile: true, size: MediaQuery.of(context).size)])
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: intro),
                  const SizedBox(width: 48),
                  Expanded(flex: 2, child: PodcastArea(mobile: false, size: MediaQuery.of(context).size)),
                ],
              ),
        const SizedBox(height: 48),
        _display('Os quatro quadrantes', size: 30),
        const SizedBox(height: 20),
        Wrap(
          spacing: 20,
          runSpacing: 20,
          children: cards.map((c) => SizedBox(width: narrow ? double.infinity : (_maxWidth - 96 - 60) / 4, child: c)).toList(),
        ),
      ],
    );
  }

  Widget _quadrantInfo(String title, Color color, String rowLabel, String colLabel, bool selfKnows, bool othersKnow, String desc) {
    Widget tag(String t, bool active, Color activeBg, Color activeFg) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
          decoration: BoxDecoration(
            color: active ? activeBg : const Color(0xFFF1EEE8),
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Text(t, style: AppTheme.body(TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: active ? activeFg : AppColors.inkMuted))),
        );

    final soft = switch (color) {
      AppColors.tealDark => AppColors.tealSoft,
      AppColors.amberDark => AppColors.amberSoft,
      AppColors.blueDark => AppColors.blueSoft,
      _ => AppColors.purpleSoft,
    };

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          JohariLogo(size: 40, showTitle: false),
          const SizedBox(height: 12),
          _display(title, size: 24, color: color),
          const SizedBox(height: 10),
          Wrap(spacing: 6, runSpacing: 6, children: [tag(rowLabel, selfKnows, soft, color), tag(colLabel, othersKnow, soft, color)]),
          const SizedBox(height: 12),
          Text(desc, style: AppTheme.body(const TextStyle(fontSize: 15, color: AppColors.inkSoft, height: 1.5))),
        ],
      ),
    );
  }

  // ---- como funciona ----------------------------------------------------

  Widget _comoFunciona(bool narrow) {
    final steps = [
      ('1', AppColors.teal, 'Escolha de palavras', 'Você seleciona os adjetivos que melhor descrevem como se vê.'),
      ('2', AppColors.blue, 'Feedback dos colegas', 'Pessoas próximas escolhem, da mesma lista, o que percebem em você.'),
      ('3', AppColors.amber, 'Construção da janela', 'As respostas se cruzam e cada adjetivo cai em um dos quatro quadrantes.'),
      ('4', AppColors.purple, 'Reflexão e diálogo', 'Compare percepções e converse sobre surpresas e pontos em comum.'),
      ('5', AppColors.ink, 'Plano de ação', 'Defina o que ampliar, revelar ou desenvolver — com apoio de um prompt de IA.'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('COMO FUNCIONA', style: _eyebrow(AppColors.teal)),
        const SizedBox(height: 14),
        _display('Cinco passos, do primeiro adjetivo ao plano de ação', size: narrow ? 30 : 42),
        const SizedBox(height: 32),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: steps
              .map((s) => SizedBox(
                    width: narrow ? double.infinity : (_maxWidth - 96 - 64) / 5,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _display(s.$1, size: 40, color: s.$2, height: 1),
                          const SizedBox(height: 10),
                          Text(s.$3, style: AppTheme.body(const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink))),
                          const SizedBox(height: 8),
                          Text(s.$4, style: AppTheme.body(const TextStyle(fontSize: 15, color: AppColors.inkSoft, height: 1.5))),
                        ],
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  // ---- por que usar (painel escuro) -------------------------------------

  Widget _porQue(bool narrow) {
    final points = [
      ('Empatia', 'Entender como você chega até os outros aproxima as relações.'),
      ('Comunicação mais clara', 'Percepções ditas em voz alta evitam ruídos e suposições.'),
      ('Confiança na equipe', 'Revela percepções não ditas e fortalece a segurança psicológica.'),
      ('Coaching e liderança', 'Um ponto de partida concreto para planos de desenvolvimento.'),
    ];

    final grid = Wrap(
      spacing: 28,
      runSpacing: 28,
      children: points
          .map((p) => SizedBox(
                width: narrow ? double.infinity : 240,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.$1, style: AppTheme.body(const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.gold))),
                    const SizedBox(height: 8),
                    Text(p.$2, style: AppTheme.body(const TextStyle(fontSize: 15, color: AppColors.onPanel, height: 1.5))),
                  ],
                ),
              ))
          .toList(),
    );

    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('POR QUE USAR', style: _eyebrow(AppColors.tealOnDark)),
        const SizedBox(height: 14),
        _display('Para pessoas, líderes e times que querem conversar melhor', size: narrow ? 28 : 38, color: Colors.white),
      ],
    );

    return narrow
        ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [title, const SizedBox(height: 32), grid])
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Expanded(flex: 2, child: title), const SizedBox(width: 48), Expanded(flex: 3, child: grid)],
          );
  }

  // ---- contato ----------------------------------------------------------

  Widget _contato(bool narrow) {
    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _display('Vamos conversar?', size: 36),
        const SizedBox(height: 10),
        Text(
          'Dúvidas, ideias ou quer usar a dinâmica com o seu time? Escreva para mim.',
          style: AppTheme.body(const TextStyle(fontSize: 16, color: AppColors.inkSoft)),
        ),
      ],
    );

    final mail = Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => launchUrl(Uri.parse('mailto:marcosmhs@live.com')),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.inputBorder, width: 1.5)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.mail_outline, color: AppColors.teal),
              const SizedBox(width: 12),
              Text('marcosmhs@live.com', style: AppTheme.body(const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink))),
            ],
          ),
        ),
      ),
    );

    return narrow
        ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [text, const SizedBox(height: 20), mail])
        : Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Expanded(child: text), const SizedBox(width: 32), mail]);
  }

  Widget _footer(bool narrow) {
    return Container(
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxWidth),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: narrow ? 20 : 48, vertical: 24),
            child: Text(
              'Desenvolvido por Marcos H. Silva · ${DateTime.now().year}',
              style: AppTheme.body(const TextStyle(fontSize: 14, color: AppColors.inkMuted)),
            ),
          ),
        ),
      ),
    );
  }
}
