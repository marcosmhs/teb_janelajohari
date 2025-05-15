// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
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

import 'package:teb_package/messaging/teb_custom_dialog.dart';
import 'package:teb_package/messaging/teb_custom_message.dart';
import 'package:teb_package/screen_elements/teb_custom_scaffold.dart';
import 'package:teb_package/visual_elements/teb_buttons_line.dart';
import 'package:teb_package/visual_elements/teb_text.dart';

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

  final ExpansionTileController expansionTileControllerFeedbacks = ExpansionTileController();
  final ExpansionTileController expansionTileControllerJohariScreen = ExpansionTileController();
  final ExpansionTileController expansionTileControllerAiPrompt = ExpansionTileController();

  void _confirmExit() {
    TebCustomDialog(context: context)
        .confirmationDialog(
          message:
              'Tem certeza que deseja encerrar esta sessão?\n\nCertifique-se de que salvou seu código de acesso (${_session.accessCode}) para acessá-la novamente no futuro.',
        )
        .then((response) {
          if (response == true) {
            LocalDataController().clearSessionData();
            Navigator.of(context).popAndPushNamed(Routes.landingScreen, arguments: {'ignoreQueryParameters': true});
          }
        });
  }

  Widget _adjectiveController({
    required String title,
    String subtitle = '',
    required List<String> adjectives,
    bool isPositive = true,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        TebText(title, textSize: 24, textWeight: FontWeight.w700, padding: const EdgeInsets.only(top: 18)),
        if (subtitle.isNotEmpty)
          TebText(
            subtitle,
            textSize: Theme.of(context).textTheme.titleMedium!.fontSize,
            textWeight: Theme.of(context).textTheme.bodyLarge!.fontWeight,
            padding: const EdgeInsets.symmetric(vertical: 8),
          ),
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
    required String subtitle,
    required Color color,
    IconData? icon,
    List<String>? positiveAdjectives,
    List<String>? constructiveAdjectives,
    List<String>? othersComments,
    int? othersFeedbackCount,
    bool selfFeedbackArea = false,
  }) {
    if ((othersComments ?? []).isNotEmpty) {
      othersComments!.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TebText(title, textSize: 30, textColor: Colors.black, padding: EdgeInsets.only(top: 10, bottom: 10, right: 10)),
              if (selfFeedbackArea)
                TebButton(
                  label: 'Alterar',
                  buttonType: TebButtonType.outlinedButton,
                  onPressed: () async {
                    var sessionFeedbacks = await SessionFeedbackController().getSessionSelfFeedbackBySessionId(
                      sessionId: _session.id,
                    );
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
              //if (icon != null) Icon(icon, size: 30),
            ],
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12.0)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (subtitle.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        if (icon != null) Padding(padding: const EdgeInsets.only(right: 20), child: Icon(icon, size: 30)),
                        Expanded(child: Html(data: "<span style='font-size: 16px'> $subtitle </span>")),
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
                    adjectives: (positiveAdjectives ?? [])..sort(),
                    color: color,
                  ),
                if ((constructiveAdjectives ?? []).isNotEmpty)
                  _adjectiveController(
                    title: 'Construtivos',
                    subtitle: 'Atitudes e comportamentos com oportunidades para desenvolvimento',
                    adjectives: (constructiveAdjectives ?? [])..sort(),
                    isPositive: false,
                    color: color,
                  ),
                if ((othersComments ?? []).isNotEmpty)
                  TebText(
                    'Abaixo está uma lista de comentários deixado pelas pessoas que contribuiram com seu feedback',
                    textSize: 20,
                    textWeight: FontWeight.w700,
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

  String _getCommentsListText(List<String>? list) {
    return list == null
        ? ''
        : list.isEmpty
        ? ''
        : list.map((item) => '     "$item"\n').join();
  }

  String _getIAText(Map<String, Map<String, dynamic>> feedbacks) {
    return 'Você é um analista de desenvolvimento humano e comportamento. Quero que analise os resultados de uma dinâmica da Janela de Johari, considerando os adjetivos que surgiram nas três áreas (aberta, cega e oculta).\n\n'
        'Seu objetivo é:\n'
        ' - Fazer um resumo sobre como a pessoa é percebida por si mesma e pelos outros.\n'
        ' - Identificar possíveis lacunas de autoconhecimento ou oportunidades de crescimento.\n'
        ' - Sugerir planos de ação práticos para desenvolvimento pessoal e profissional reduzindo a área cega ao mesmo tempo que ajuda a expandir a área aberta.\n\n'
        'Aqui estão os resultados:\n'
        ' - Comentários deixados pelas pessoas que contribuíram com feedbacks:\n'
        '${_getCommentsListText(feedbacks['othersFeedback']!['comments'])}\n'
        ' - Área Aberta (conhecida por si e pelos outros):\n'
        '     adjetivos positivos: ${_getAdjectivesListText(feedbacks['openArea']!['positiveAdjectives'])}\n'
        '     construtivos: ${_getAdjectivesListText(feedbacks['openArea']!['constructiveAdjectives'])}\n\n'
        ' - Área Cega (percebida pelos outros, mas não por si)\n'
        '     adjetivos positivos: ${_getAdjectivesListText(feedbacks['blindArea']!['positiveAdjectives'])}\n'
        '     construtivos: ${_getAdjectivesListText(feedbacks['blindArea']!['constructiveAdjectives'])}\n\n'
        ' - Área Oculta (conhecida por si, mas não revelada aos outros)\n'
        '     adjetivos positivos: ${_getAdjectivesListText(feedbacks['hiddenArea']!['positiveAdjectives'])}\n'
        '     construtivos: ${_getAdjectivesListText(feedbacks['hiddenArea']!['constructiveAdjectives'])}\n\n'
        'Com base nesses dados, elabore um texto com:\n'
        ' - Um resumo da autoimagem da pessoa comparada à imagem que os outros têm dela.\n'
        ' - Interpretações sobre o que isso pode significar em seu contexto profissional ou pessoal.\n'
        ' - Sugestões práticas de desenvolvimento (ex: conversas de feedback, coaching, novos comportamentos, etc.).';
  }

  Widget _expandedTileArea({
    required Size size,
    required bool mobile,
    required String title,
    required String subTitle,
    required ExpansionTileController controller,
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
      subtitle: TebText(
        subTitle,
        textSize: Theme.of(context).textTheme.titleLarge!.fontSize,
        textColor: Colors.black,
        padding: EdgeInsets.symmetric(vertical: 12),
      ),
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

    return FutureBuilder(
      future: SessionFeedbackController().getAllAreasFeedback(sessionId: _session.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        } else {
          final feedbacks = snapshot.data as Map<String, Map<String, dynamic>>;

          final List<String> positiveAdjectives = [];
          final List<String> constructiveAdjectives = [];

          positiveAdjectives.addAll(feedbacks['openArea']!['positiveAdjectives']!);
          constructiveAdjectives.addAll(feedbacks['openArea']!['constructiveAdjectives']!);

          return TebCustomScaffold(
            // appbar
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
                      if (!_mobile)
                        InkWell(
                          child: Icon(FontAwesomeIcons.arrowsRotate, size: 30, color: Colors.black87),
                          onTap: () => setState(() {}),
                        ),
                    ],
                  ),

                  const SizedBox(height: 30),
                  if (_mobile)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        children: [
                          Expanded(child: Text('')),
                          InkWell(
                            child: Icon(FontAwesomeIcons.arrowsRotate, size: 20, color: Colors.black87),
                            onTap: () => setState(() {}),
                          ),
                        ],
                      ),
                    ),
                  // --------------------------------
                  // Feedbacks
                  // --------------------------------
                  _expandedTileArea(
                    size: size,
                    mobile: _mobile,
                    title: 'Feedbacks',
                    subTitle: 'Resumo de seu feedback pessoal e da percepção de seus colegas',
                    controller: expansionTileControllerFeedbacks,
                    children: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _windowArea(
                          title: 'Seu feedback',
                          subtitle: 'Lista de adjetivos selecionados por você',
                          color: SessionFeedbacks.selfFeedbackAreaColor,
                          positiveAdjectives: feedbacks['selfFeedback']!['positiveAdjectives'],
                          constructiveAdjectives: feedbacks['selfFeedback']!['constructiveAdjectives'],
                          selfFeedbackArea: true,
                          icon: FontAwesomeIcons.imagePortrait,
                        ),
                        const SizedBox(height: 20),
                        _windowArea(
                          title: 'Feedback de seus colegas',
                          subtitle: 'Lista unificada de todos os adjetivos indicados por seus colegas',
                          color: SessionFeedbacks.othersFeedbackAreaColor,
                          positiveAdjectives: feedbacks['othersFeedback']!['positiveAdjectives'],
                          constructiveAdjectives: feedbacks['othersFeedback']!['constructiveAdjectives'],
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
                    subTitle: 'Abaixo estão as áreas de sua janela',
                    controller: expansionTileControllerJohariScreen,
                    children: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _windowArea(
                          title: 'Área Aberta',
                          subtitle:
                              'A área aberta, também conhecida como "Eu Aberto", representa <b>tudo o que você conhece sobre si mesmo(a) e '
                              'que é também conhecido pelos outros</b>. É a zona de transparência e confiança, onde características e comportamentos '
                              'são compartilhados livremente e há uma compreensão mútua entre você e todos a sua volta.',
                          color: SessionFeedbacks.openAreaColor,
                          positiveAdjectives: feedbacks['openArea']!['positiveAdjectives'],
                          constructiveAdjectives: feedbacks['openArea']!['constructiveAdjectives'],
                          icon: FontAwesomeIcons.eye,
                        ),
                        const SizedBox(height: 20),
                        _windowArea(
                          title: 'Área Cega',
                          subtitle:
                              'Esta área apresenta todos os <b>comportamentos e características percebidos pelos pelos outros, mas não por você</b>. Nesta área '
                              'estão as oportunidades para rever comportamentos ou atitudes que podem impactar negativamente as pessoas a sua volta.',
                          color: SessionFeedbacks.blindAreaColor,
                          positiveAdjectives: feedbacks['blindArea']!['positiveAdjectives'],
                          constructiveAdjectives: feedbacks['blindArea']!['constructiveAdjectives'],
                          icon: FontAwesomeIcons.eyeSlash,
                        ),
                        const SizedBox(height: 20),
                        _windowArea(
                          title: 'Área Oculta',
                          subtitle:
                              'Nesta área estão as características, comportamentos, pensamentos e sentimentos <b>conhecida por nós, mas não pelos outros.</b>',
                          color: SessionFeedbacks.hiddenAreaColor,
                          positiveAdjectives: feedbacks['hiddenArea']!['positiveAdjectives'],
                          constructiveAdjectives: feedbacks['hiddenArea']!['constructiveAdjectives'],
                          icon: FontAwesomeIcons.doorClosed,
                        ),
                        const SizedBox(height: 20),
                        _windowArea(
                          title: 'Área Desconhecida',
                          subtitle:
                              'Esta é uma área conceitual onde está tudo o que é desconhecida por nós e pelos outros. Representa o potencial que ainda não foi explorado ou descoberto. Por isso não é possível determinar quais características estão presentes nela à partir desta dinâmica.',
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
                    subTitle:
                        'Utilize o texto abaixo como uma proposta para enviar para uma IA de sua escolha para lhe ajudar como um plano '
                        'de desenvolvimento para sua carreira. Este prompt pode ser alterado de acordo com suas necessidades.',
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
                              TebCustomMessage.sucess(context, message: 'Texto copiado para sua área de transferência!');
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
        }
      },
    );
  }
}
