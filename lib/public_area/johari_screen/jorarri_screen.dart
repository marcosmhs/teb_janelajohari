// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:teb_janelajohari/main/widgets/area_title_widget.dart';
import 'package:teb_janelajohari/main/widgets/contact_area.dart';
import 'package:teb_janelajohari/public_area/invalid_access_screen.dart';
import 'package:teb_janelajohari/public_area/session_feedbacks/session_feedbacks.dart';
import 'package:teb_janelajohari/public_area/session_feedbacks/session_feedbacks_controller.dart';
import 'package:teb_janelajohari/main/widgets/title_bar_widget.dart';
import 'package:teb_janelajohari/public_area/session/session.dart';
import 'package:teb_janelajohari/local_data_controller.dart';
import 'package:teb_janelajohari/routes.dart';
import 'package:teb_package/control_widgets/teb_buttons_line.dart';
import 'package:teb_package/control_widgets/teb_text.dart';
import 'package:teb_package/messaging/teb_message.dart';
import 'package:teb_package/screen_widgets/teb_scaffold.dart';


class JohariScreen extends StatefulWidget {
  final Session? session;
  final bool? mobile;
  const JohariScreen({super.key, this.session, this.mobile});

  @override
  State<JohariScreen> createState() => _MainScreen();
}

class _MainScreen extends State<JohariScreen> with TickerProviderStateMixin {
  var _session = Session();
  var _initializing = true;
  var _mobile = false;
  var _showOthersFeedbackOrderedByAdjectiveName = true;

  final ExpansibleController  expansionTileControllerFeedbacks = ExpansibleController ();
  final ExpansibleController  expansionTileControllerJohariScreen = ExpansibleController ();
  final ExpansibleController  expansionTileControllerAiPrompt = ExpansibleController ();

  void _confirmExit() {
    showDialog<bool>(
      useSafeArea: false,
      context: context,
      builder:
          (ctx) => AlertDialog(
            content: SizedBox(
              width: _mobile ? 300 : 600,
              height: _mobile ? 500 : 320,
              child: Row(
                children: [
                  if (!_mobile) Icon(FontAwesomeIcons.handPointUp, size: 80, color: Theme.of(context).colorScheme.tertiary),
                  if (!_mobile) const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_mobile) Icon(FontAwesomeIcons.handPointUp, size: 50, color: Theme.of(context).colorScheme.tertiary),
                        if (_mobile) const SizedBox(height: 20),
                        TebText(
                          'Lembre-se de salvar os dados de acesso e convite para feedback',
                          textSize: 24,
                          textType: TextType.html,
                          textWeight: FontWeight.bold,
                          padding: const EdgeInsets.only(bottom: 10),
                        ),
                        TebText(
                          'Seu código de acesso (<b>${_session.accessCode}</b>) será necessário para acessar seus feedbacks posteriormente',
                          textSize: 16,
                          textType: TextType.html,
                          padding: const EdgeInsets.only(bottom: 10),
                        ),
                        TebText(
                          'Guarde-o em um lugar de fácil acesso para que possa usá-lo novamente no futuro :)',
                          textSize: 16,
                          textType: TextType.html,
                          padding: const EdgeInsets.only(bottom: 10),
                        ),
                        TebButton(
                          buttonType: TebButtonType.outlinedButton,
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: _session.accessCode));
                            Navigator.of(ctx).pop(true);
                            TebMessage.sucess(context, message: 'Código de acesso copiado para sua área de transferência!');
                          },
                          size: Size(_mobile ? 350 : 450, 90),
                          child: TebText(
                            'Clique aqui para copiar seu <b>código de acesso</b> para a área de transferência e deixar sua sessão',
                            textSize: 16,
                            textAlign: _mobile ? TextAlign.center : null,
                            textType: TextType.html,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    ).then((value) async {
      if ((value ?? false) == true) {
        LocalDataController().clearSessionData();
        Navigator.of(context).popAndPushNamed(Routes.landingScreen, arguments: {'ignoreQueryParameters': true});
      }
    });
  }

  Widget _adjectiveController({
    required String title,
    String? subtitle,
    required List<String> adjectives,
    bool isPositive = true,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        TebText(title, textSize: 24, textWeight: FontWeight.bold),

        if (subtitle != null) TebText(subtitle, textSize: 16),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Wrap(
            spacing: 24.0,
            runSpacing: 12.0,
            children:
                adjectives.map((adjective) {
                  return FilterChip(
                    label: TebText(adjective),
                    selected: false,
                    backgroundColor: color.withAlpha(50),
                    onSelected: (bool selected) {
                      return;
                    },
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _windowArea({
    required String title,
    required String? subtitle,
    required Color color,
    IconData? icon,
    List<String>? positiveAdjectives,
    List<String>? constructiveAdjectives,
    List<String>? othersComments,
    int? othersFeedbackCount,
    bool selfFeedbackArea = false,
    bool othersFeedbackArea = false,
  }) {
    var othersFeedbackOrderWidget = Row(
      children: [
        const TebText('Ordenar por: '),
        TebButton(
          onPressed: () => setState(() => _showOthersFeedbackOrderedByAdjectiveName = true),
          buttonType: TebButtonType.outlinedButton,
          child: TebText('Adjetivo', textWeight: _showOthersFeedbackOrderedByAdjectiveName ? FontWeight.bold : FontWeight.normal),
        ),
        const SizedBox(width: 10),
        TebButton(
          onPressed: () => setState(() => _showOthersFeedbackOrderedByAdjectiveName = false),
          buttonType: TebButtonType.outlinedButton,
          child: TebText(
            'Quantidade de feedbacks',
            textWeight: _showOthersFeedbackOrderedByAdjectiveName ? FontWeight.normal : FontWeight.bold,
          ),
        ),
      ],
    );
    var titleWidget = Row(
      children: [
        TebText(title, textSize: 30, textWeight: FontWeight.bold),

        if (selfFeedbackArea)
          TebButton(
            label: 'Alterar',
            buttonType: TebButtonType.outlinedButton,
            padding: EdgeInsets.only(left: 10),
            onPressed: () async {
              var sessionFeedbacks = await SessionFeedbackController().getSessionSelfFeedbackBySessionId(sessionId: _session.id);
              Navigator.of(context).pushNamed(
                Routes.feedbackScreen,
                arguments: {
                  'session': _session,
                  'sessionFeedbacks': sessionFeedbacks,
                  'feedbackType': FeedbackType.self,
                  'mobile': _mobile,
                },
              );
            },
          ),
        if (othersFeedbackArea && !_mobile) const SizedBox(width: 10),
        if (othersFeedbackArea && !_mobile) othersFeedbackOrderWidget,
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleWidget,
          // othersFeedbackOrderWidget display in the main column when
          // is a mobile screen
          if (othersFeedbackArea && _mobile) othersFeedbackOrderWidget,
          if (othersFeedbackArea && _mobile) const SizedBox(height: 10),
          Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12.0)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        if (icon != null) Padding(padding: const EdgeInsets.only(right: 20), child: Icon(icon, size: 30)),
                        Expanded(child: TebText(subtitle, textType: TextType.html, textSize: 20)),
                      ],
                    ),
                  ),
                if (othersFeedbackCount != null)
                  TebText(
                    othersFeedbackCount == 0
                        ? 'Até agora você não recebeu feedbacks, envie seu link de feedback para seus colegas e peça para eles responderem a pesquisa.'
                        : 'Até agora você recebeu $othersFeedbackCount feedbacks',
                    textSize: 16,
                    padding: EdgeInsets.symmetric(vertical: 8),
                  ),
                if ((positiveAdjectives ?? []).isNotEmpty)
                  _adjectiveController(
                    title: 'Positivos',
                    subtitle: 'Atitudes e comportamentos percebidos como positivos',
                    adjectives: (positiveAdjectives ?? []),
                    color: color,
                  ),
                if ((constructiveAdjectives ?? []).isNotEmpty)
                  _adjectiveController(
                    title: 'Construtivos',
                    subtitle: 'Atitudes e comportamentos com oportunidades para desenvolvimento',
                    adjectives: (constructiveAdjectives ?? []),
                    isPositive: false,
                    color: color,
                  ),
                if ((othersComments ?? []).isNotEmpty)
                  TebText(
                    'Abaixo está uma lista de comentários deixado pelas pessoas que contribuiram com seu feedback',
                    textSize: 20,
                    textWeight: FontWeight.bold,
                    padding: const EdgeInsets.only(top: 18, bottom: 10),
                  ),

                if ((othersComments ?? []).isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        othersComments!.map((comment) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(FontAwesomeIcons.message),
                                Expanded(
                                  child: TebText(
                                    comment,
                                    textSize: 16,
                                    textWeight: FontWeight.w400,
                                    padding: EdgeInsets.only(left: 10),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getAdjectivesListText(List<String>? list) {
    return list == null
        ? ''
        : list.isEmpty
        ? ''
        : list.join(', ');
  }

  String _getIAText(Map<String, Map<String, dynamic>> feedbacks) {
    var commentsList =
        feedbacks['othersFeedback']!['comments'] == null
            ? ''
            : feedbacks['othersFeedback']!['comments'].isEmpty
            ? ''
            : feedbacks['othersFeedback']!['comments'].map((item) => '   "$item"\n').join();

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

    var replaceStringList = {
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

  Widget _expandedTileArea({
    required Size size,
    required bool mobile,
    required String title,
    required String? subtitle,
    required ExpansibleController  controller,
    required Widget children,
  }) {
    return ExpansionTile(
      initiallyExpanded: true,
      showTrailingIcon: mobile,
      title:
          mobile
              ? AreaTitleWidget(size: size, title: title, mobile: mobile, cropped: true)
              : Row(
                children: [
                  AreaTitleWidget(size: size, title: title, mobile: mobile, cropped: true, lineWidth: 0),
                  const Spacer(),
                  TebButton(
                    label: 'Exibir/Recolher',
                    icon: Icon(FontAwesomeIcons.eye),
                    buttonType: TebButtonType.outlinedButton,
                    onPressed: () {
                      if (controller.isExpanded) {
                        controller.collapse();
                      } else {
                        controller.expand();
                      }
                    },
                  ),
                ],
              ),
      subtitle: subtitle == null ? null : TebText(subtitle, textSize: 20),
      controller: controller,
      children: [children],
    );
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

    if (_session.id.isEmpty) {
      return InvalidAccessScreen();
    }

    var size = MediaQuery.of(context).size;

    return StreamBuilder<QuerySnapshot>(
      stream: SessionFeedbackController().getSessionFeedbacks(sessionId: _session.id),
      builder: (context, snapshot) {
        List<SessionFeedbacks> sessionFeedbacks = [];

        if ((snapshot.hasData) && (snapshot.data!.docs.isNotEmpty)) {
          sessionFeedbacks.addAll(snapshot.data!.docs.map((e) => SessionFeedbacks.fromDocument(e)).toList());
        }

        var feedbacks = SessionFeedbackController.getAllAreasFeedback(feedbacks: sessionFeedbacks);

        return TebScaffold(
          responsive: false,
          showAppBar: false,
          fixedWidth: size.width * 0.9,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TitleBarWidget(
                        session: _session,
                        context: context,
                        feedbackType: FeedbackType.self,
                        mobile: _mobile,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // --------------------------------
                // Feedbacks
                // --------------------------------
                _expandedTileArea(
                  size: size,
                  mobile: _mobile,
                  title: 'Feedbacks',
                  subtitle: 'Resumo de seu feedback pessoal e da percepção de seus colegas',
                  controller: expansionTileControllerFeedbacks,
                  children: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _windowArea(
                        title: 'Seu feedback',
                        subtitle: 'Lista de adjetivos selecionados por você',
                        selfFeedbackArea: true,
                        color: SessionFeedbacks.selfFeedbackAreaColor,
                        positiveAdjectives: feedbacks['selfFeedback']!['positiveAdjectives'],
                        constructiveAdjectives: feedbacks['selfFeedback']!['constructiveAdjectives'],
                        icon: FontAwesomeIcons.imagePortrait,
                      ),
                      const SizedBox(height: 20),
                      _windowArea(
                        title: 'Feedback de seus colegas',
                        othersFeedbackArea: true,
                        subtitle: 'Lista unificada de todos os adjetivos indicados por seus colegas',
                        color: SessionFeedbacks.othersFeedbackAreaColor,
                        positiveAdjectives:
                            _showOthersFeedbackOrderedByAdjectiveName
                                ? feedbacks['othersFeedback']!['positiveAdjectives']
                                : feedbacks['othersFeedback']!['positiveAdjectivesWithCount'],
                        constructiveAdjectives:
                            _showOthersFeedbackOrderedByAdjectiveName
                                ? feedbacks['othersFeedback']!['constructiveAdjectives']
                                : feedbacks['othersFeedback']!['constructiveAdjectivesWithCount'],
                        othersComments: feedbacks['othersFeedback']!['comments'],
                        othersFeedbackCount: feedbacks['othersFeedback']!['count'],
                        icon: FontAwesomeIcons.peopleGroup,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // --------------------------------
                // Johari Screen
                // --------------------------------
                _expandedTileArea(
                  size: size,
                  mobile: _mobile,
                  title: 'Sua Janela de Johari',
                  subtitle: 'Abaixo estão as áreas de sua janela',
                  controller: expansionTileControllerJohariScreen,
                  children: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _windowArea(
                        title: 'Área Aberta',
                        subtitle:
                            'A área aberta, também conhecida como "Eu Aberto", representa <b>tudo o que você conhece sobre '
                            'si mesmo(a) e que é também conhecido pelos outros</b>. É a zona de transparência e confiança, onde '
                            'características e comportamentos são compartilhados livremente e há uma compreensão mútua entre você '
                            'e todos a sua volta.',
                        color: SessionFeedbacks.openAreaColor,
                        positiveAdjectives: feedbacks['openArea']!['positiveAdjectives'],
                        constructiveAdjectives: feedbacks['openArea']!['constructiveAdjectives'],
                        icon: FontAwesomeIcons.eye,
                      ),
                      const SizedBox(height: 20),
                      _windowArea(
                        title: 'Área Cega',
                        subtitle:
                            'Esta área apresenta todos os <b>comportamentos e características percebidos pelos pelos outros, '
                            'mas não por você</b>. Nesta área estão as oportunidades para rever comportamentos ou atitudes que '
                            'podem impactar negativamente as pessoas a sua volta.',
                        color: SessionFeedbacks.blindAreaColor,
                        positiveAdjectives: feedbacks['blindArea']!['positiveAdjectives'],
                        constructiveAdjectives: feedbacks['blindArea']!['constructiveAdjectives'],
                        icon: FontAwesomeIcons.eyeSlash,
                      ),
                      const SizedBox(height: 20),
                      _windowArea(
                        title: 'Área Oculta',
                        subtitle:
                            'Nesta área estão as características, comportamentos, pensamentos e sentimentos <b>conhecida '
                            'por nós, mas não pelos outros.</b>',
                        color: SessionFeedbacks.hiddenAreaColor,
                        positiveAdjectives: feedbacks['hiddenArea']!['positiveAdjectives'],
                        constructiveAdjectives: feedbacks['hiddenArea']!['constructiveAdjectives'],
                        icon: FontAwesomeIcons.doorClosed,
                      ),
                      const SizedBox(height: 20),
                      _windowArea(
                        title: 'Área Desconhecida',
                        subtitle:
                            'Esta é uma área conceitual onde está tudo o que é desconhecida por nós e pelos outros. '
                            'Representa o potencial que ainda não foi explorado ou descoberto. Por isso não é possível determinar '
                            'quais características estão presentes nela à partir desta dinâmica.',
                        color: SessionFeedbacks.unknorAreaColor,
                        icon: FontAwesomeIcons.question,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // --------------------------------
                // AI Prompt
                // --------------------------------
                _expandedTileArea(
                  size: size,
                  mobile: _mobile,
                  title: 'Prompt para análise utilizando IA',
                  subtitle:
                      'Utilize o texto abaixo como uma proposta para enviar para uma IA de '
                      'sua escolha para lhe ajudar como um plano de desenvolvimento para sua carreira. '
                      'Este prompt pode ser alterado de acordo com suas necessidades.',
                  controller: expansionTileControllerAiPrompt,
                  children: Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(color: Colors.blueGrey.shade100, borderRadius: BorderRadius.circular(12.0)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20.0),
                          decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12.0)),
                          child: TebText(_getIAText(feedbacks), padding: EdgeInsets.only(bottom: 10)),
                        ),
                        TebButton(
                          padding: EdgeInsets.only(top: 20),
                          label: 'Copiar texto',
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: _getIAText(feedbacks)));
                            TebMessage.sucess(context, message: 'Texto copiado para sua área de transferência!');
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 50),
                TebButton(
                  label: 'Deixar esta sessão',
                  textStyle: TextStyle(fontSize: 18),
                  size: Size(280, 40),
                  onPressed: _confirmExit,
                  icon: Icon(FontAwesomeIcons.arrowRightToBracket, size: 30),
                ),
                const SizedBox(height: 40),
                ContactArea(mobile: _mobile),
              ],
            ),
          ),
        );
      },
    );
  }
}
