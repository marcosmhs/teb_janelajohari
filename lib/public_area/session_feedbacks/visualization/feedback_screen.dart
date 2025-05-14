// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:teb_janelajohari/local_data_controller.dart';
import 'package:teb_janelajohari/main/widgets/area_title_widget.dart';
import 'package:teb_janelajohari/main/widgets/contact_area.dart';
import 'package:teb_janelajohari/public_area/invalid_access_screen.dart';
import 'package:teb_janelajohari/public_area/session_feedbacks/session_feedbacks_controller.dart';
import 'package:teb_janelajohari/main/widgets/title_bar_widget.dart';
import 'package:teb_janelajohari/public_area/session_feedbacks/session_feedbacks.dart';
import 'package:teb_janelajohari/public_area/session/session.dart';
import 'package:teb_janelajohari/routes.dart';
import 'package:teb_package/messaging/teb_custom_message.dart';
import 'package:teb_package/screen_elements/teb_custom_scaffold.dart';
import 'package:teb_package/util/teb_return.dart';

import 'package:teb_package/visual_elements/teb_buttons_line.dart';
import 'package:teb_package/visual_elements/teb_text.dart';
import 'package:teb_package/visual_elements/teb_text_form_field.dart';

class FeedbackScreen extends StatefulWidget {
  final Session? session;
  final FeedbackType? feedbackType;
  final bool? mobile;
  const FeedbackScreen({super.key, this.session, this.feedbackType, this.mobile});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  var _initializing = true;
  var _session = Session();
  var _sessionFeedbacks = SessionFeedbacks();
  var _mobile = false;
  final TextEditingController _commentsController = TextEditingController();

  Widget _adjectiveController({
    required String title,
    required List<String> adjectives,
    bool isPositive = true,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TebText(
          title,
          textSize: Theme.of(context).textTheme.titleLarge!.fontSize,
          textWeight: Theme.of(context).textTheme.titleLarge!.fontWeight,
          textColor: Theme.of(context).colorScheme.primary,
          padding: const EdgeInsets.only(top: 18),
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
                    selected:
                        _sessionFeedbacks.positiveAdjectives.contains(adjective) ||
                        _sessionFeedbacks.constructiveAdjectives.contains(adjective),
                    selectedColor: color.withAlpha(150),
                    backgroundColor: color.withAlpha(50),
                    onSelected: (bool selected) {
                      if (_sessionFeedbacks.totalAdjectivesLengh >= 10 && selected) {
                        TebCustomMessage.error(context, message: 'Selecione no máximo 10 adjetivos!');
                        return;
                      }
                      setState(() {
                        if (selected) {
                          _sessionFeedbacks.addAdjective(adjective: adjective, isPositive: isPositive);
                        } else {
                          _sessionFeedbacks.removeAdjective(adjective: adjective, isPositive: isPositive);
                        }
                      });
                    },
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  void _submit() async {
    if (_sessionFeedbacks.totalAdjectivesLengh < 5) {
      TebCustomMessage.error(context, message: 'Selecione entre 5 e 10 adjetivos antes de concluir');
      return;
    }

    if (_session.id.isEmpty) {
      TebCustomMessage.error(context, message: 'Estranho, sessão não encontrada!');
      return;
    }

    var sessionVotesController = SessionFeedbackController();
    TebCustomReturn retorno;

    retorno = await sessionVotesController.save(sessionFeedbacks: _sessionFeedbacks, sessionId: _session.id);
    if (retorno != TebCustomReturn.sucess) {
      TebCustomMessage.error(context, message: retorno.message);
    }

    TebCustomMessage.sucess(
      context,
      message:
          _sessionFeedbacks.feedbackType == FeedbackType.self
              ? 'Reflexão individual salva com sucesso!'
              : 'Feedback salvo com sucesso!',
    );
    if (_sessionFeedbacks.feedbackType == FeedbackType.self) {
      LocalDataController().saveSession(session: _session);
      Navigator.of(context).popAndPushNamed(Routes.landingScreen);
      TebCustomMessage.sucess(
        context,
        message:
            'Reflexão individual salva com sucesso!, agora compartilhe o link de avaliação com as pessoas que podem contribuir com seu desenvolvimento',
      );
    } else {
      TebCustomMessage(
        context: context,
        messageText: 'Feedback salvo com sucesso, que tal aproveitar este momento para iniciar uma sessão de autoavaliação',
        messageType: TebMessageType.sucess,
        modelType: TebModelType.snackbar,
        durationInSeconds: 5,
      );
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

      _initializing = false;
    }

    if (_session.id.isEmpty) {
      return InvalidAccessScreen();
    }

    var size = MediaQuery.of(context).size;

    return TebCustomScaffold(
      responsive: false,
      showAppBar: false,
      fixedWidth: size.width * 0.9,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TitleBarWidget(session: _session, context: context, feedbackType: _sessionFeedbacks.feedbackType, mobile: _mobile),
            const SizedBox(height: 20),
            AreaTitleWidget(
              size: size,
              title: _sessionFeedbacks.feedbackType == FeedbackType.self ? 'Reflexão individual' : 'Coleta de Feedback ',
              mobile: _mobile,
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: RichText(
                //textAlign: TextAlign.center,
                text: TextSpan(
                  text:
                      _sessionFeedbacks.feedbackType == FeedbackType.self
                          ? 'Selecione de 5 a 10 adjetivos da lista abaixo que acredita melhor descrevem '
                          : 'Selecione de 5 a 10 adjetivos da lista abaixo que acredite descrever bem ',
                  style: Theme.of(context).textTheme.headlineSmall,
                  children: [
                    TextSpan(
                      text: _sessionFeedbacks.feedbackType == FeedbackType.self ? 'VOCÊ' : _session.name,
                      style: TextStyle(fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary),
                    ),
                    TextSpan(
                      text:
                          _sessionFeedbacks.feedbackType == FeedbackType.self
                              ? ' no contexto do trabalho em equipe'
                              : ' no ambiente de trabalho',
                    ),
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color:
                    _sessionFeedbacks.feedbackType == FeedbackType.self
                        ? SessionFeedbacks.selfFeedbackAreaColor
                        : SessionFeedbacks.othersFeedbackAreaColor,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    child: _adjectiveController(
                      title: 'Adjetivos positivos',
                      adjectives: _session.positiveAdjectives,
                      color:
                          _sessionFeedbacks.feedbackType == FeedbackType.self
                              ? SessionFeedbacks.selfFeedbackAreaColor
                              : SessionFeedbacks.othersFeedbackAreaColor,
                    ),
                  ),
                  SizedBox(
                    child: _adjectiveController(
                      title: 'Adjetivos construtivos',
                      adjectives: _session.constructiveAdjectives,
                      isPositive: false,
                      color:
                          _sessionFeedbacks.feedbackType == FeedbackType.self
                              ? SessionFeedbacks.selfFeedbackAreaColor
                              : SessionFeedbacks.othersFeedbackAreaColor,
                    ),
                  ),

                  TebText(
                    '${_sessionFeedbacks.totalAdjectivesLengh} adjetivos selecionados',
                    style: Theme.of(context).textTheme.headlineSmall,
                    padding: const EdgeInsets.only(top: 20),
                  ),
                ],
              ),
            ),

            if (_sessionFeedbacks.feedbackType == FeedbackType.others)
              TebText(
                'Caso queira deixar algum comentário para esta pessoa, use o espaço abaixo',
                textSize: 18,
                padding: EdgeInsets.only(top: 20),
              ),

            if (_sessionFeedbacks.feedbackType == FeedbackType.others)
              TebTextEdit(
                context: context,
                controller: _commentsController,
                maxLines: 5,
                labelText: 'Comentários',
                hintText: 'Comentários',
                onSave: (value) => _sessionFeedbacks.comments = value ?? '',
                onChanged: (value) => _sessionFeedbacks.comments = value ?? '',
                prefixIcon: FontAwesomeIcons.comments,
                padding: EdgeInsets.only(bottom: 10, right: 20),
              ),

            TebButtonsLine(
              padding: const EdgeInsets.only(top: 30, bottom: 50),
              buttons: [
                TebButton(
                  label: 'Sair sem responder',
                  onPressed:
                      () =>
                          Navigator.of(context).popAndPushNamed(Routes.landingScreen, arguments: {'ignoreQueryParameters': true}),
                  buttonType: TebButtonType.outlinedButton,
                ),
                TebButton(label: 'Enviar minha resposta', onPressed: _submit),
              ],
            ),
            ContactArea(mobile: _mobile),
          ],
        ),
      ),
    );
  }
}
