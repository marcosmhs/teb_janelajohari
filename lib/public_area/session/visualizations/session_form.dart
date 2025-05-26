// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:teb_janelajohari/main/widgets/area_title_widget.dart';
import 'package:teb_janelajohari/main/widgets/site_title_widget.dart';
import 'package:teb_janelajohari/public_area/session_feedbacks/session_feedbacks.dart';
import 'package:teb_janelajohari/public_area/session/session.dart';
import 'package:teb_janelajohari/public_area/session/session_controller.dart';
import 'package:teb_janelajohari/routes.dart';
import 'package:teb_package/messaging/teb_custom_message.dart';
import 'package:teb_package/screen_elements/teb_custom_scaffold.dart';
import 'package:teb_package/util/teb_return.dart';
import 'package:teb_package/util/teb_uid_generator.dart';
import 'package:teb_package/visual_elements/teb_buttons_line.dart';
import 'package:teb_package/visual_elements/teb_text.dart';
import 'package:teb_package/visual_elements/teb_text_form_field.dart';

class SessionForm extends StatefulWidget {
  const SessionForm({super.key});

  @override
  State<SessionForm> createState() => _SessionFormState();
}

class _SessionFormState extends State<SessionForm> {
  final TextEditingController _nameController = TextEditingController(text: 'teste');
  final TextEditingController _accessCodeController = TextEditingController();
  final TextEditingController _feedbackUrlController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _initializing = true;
  Session _session = Session();
  bool _savingData = false;
  bool _newSession = false;
  bool _mobile = false;

  //List<String> _localBasePositiveAdjectives = [];
  //List<String> _localBaseConstructiveAdjectives = [];

  void _submit() async {
    if (!(_formKey.currentState?.validate() ?? true)) {
      _savingData = false;
    } else {
      showDialog<bool>(
        useSafeArea: false,
        context: context,
        builder:
            (ctx) => AlertDialog(
              content: SizedBox(
                width: _mobile ? 300 : 600,
                height: _mobile ? 350 : 300,
                child: Row(
                  children: [
                    if (!_mobile) Icon(FontAwesomeIcons.handPointUp, size: 80, color: Theme.of(context).colorScheme.tertiary),
                    if (!_mobile) const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_mobile)
                            Icon(FontAwesomeIcons.handPointUp, size: 50, color: Theme.of(context).colorScheme.tertiary),
                          if (_mobile) const SizedBox(height: 20),
                          TebText(
                            'Lembre-se de salvar os dados de acesso e convite para feedback',
                            textSize: 16,
                            textWeight: FontWeight.bold,
                            padding: const EdgeInsets.only(bottom: 10),
                          ),
                          TebText(
                            'Seu código de acesso será necessário para acessar seus feedbacks posteriormente',
                            textSize: 16,
                            padding: const EdgeInsets.only(bottom: 10),
                          ),
                          TebText(
                            'Guarde-o em um lugar de fácil acesso para que possa usá-lo novamente no futuro :)',
                            textSize: 16,
                            padding: const EdgeInsets.only(bottom: 10),
                          ),
                          TebButton(
                            buttonType: TebButtonType.outlinedButton,
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: _accessCodeController.text));
                              Navigator.of(ctx).pop(true);
                              TebCustomMessage.sucess(
                                context,
                                message: 'Código de acesso copiado para sua área de transferência!',
                              );
                            },
                            size: Size(_mobile ? 350 : 450, 70),
                            child: TebText(
                              'Clique aqui para copiar seu <b>código de acesso</b>',
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
        if (!(value ?? false)) return;

        if (_savingData) return;

        _savingData = true;

        // salva os dados
        _formKey.currentState?.save();
        var sessionController = SessionController();
        TebCustomReturn retorno;
        try {
          retorno = TebCustomReturn.sucess;
          retorno = await sessionController.save(session: _session);
          if (retorno.returnType != TebCustomReturn.sucess.returnType) {
            TebCustomMessage.error(context, message: retorno.message);
            _savingData = false;
            return;
          }

          TebCustomMessage.sucess(context, message: _newSession ? 'Sessão criada!' : 'Sessão alterada');

          if (_newSession) {
            Navigator.of(context).popAndPushNamed(
              Routes.feedbackScreen,
              arguments: {'session': sessionController.currentSession, 'feedbackType': FeedbackType.self, 'mobile': _mobile},
            );
          } else {
            Navigator.of(context).pop();
          }
        } finally {
          _savingData = false;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;
      _session = arguments['session'] ?? Session();
      _mobile = arguments['mobile'] ?? false;
      _newSession = _session.id.isEmpty;
      _session.accessCode = _newSession ? TebUidGenerator.invitationCode : _session.accessCode;
      _session.feedbackCode = _newSession ? TebUidGenerator.invitationCode : _session.feedbackCode;
      _initializing = false;
      _accessCodeController.text = _session.accessCode;
      _feedbackUrlController.text = _session.sessionFeedbackUrl;
      _nameController.text = _session.name;

      //_localBasePositiveAdjectives = List<String>.from(Session.basePositiveAdjectives);
      //_localBasePositiveAdjectives.sort();
      //_localBaseConstructiveAdjectives = List<String>.from(Session.baseConstructiveAdjectives);
      //_localBaseConstructiveAdjectives.sort();
    }

    return TebCustomScaffold(
      responsive: false,
      showAppBar: false,
      useCenter: false,
      fixedWidth: MediaQuery.of(context).size.width * 0.9,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SiteTitleWidget(mobile: _mobile),
                const SizedBox(height: 40),
                Padding(
                  padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      AreaTitleWidget(
                        title: 'Vamos iniciar uma sessão individual!',
                        size: MediaQuery.of(context).size * 0.9,
                        mobile: _mobile,
                      ),

                      TebText(
                        'Uma sessão é um espaço para você e seu time se conhecerem melhor e trabalharem juntos.',
                        textSize: 16,
                        padding: const EdgeInsets.only(top: 10, bottom: 5),
                      ),

                      // name
                      TebTextEdit(
                        context: context,
                        width: MediaQuery.of(context).size.width < 700 ? MediaQuery.of(context).size.width * 0.8 : 700,
                        controller: _nameController,
                        labelText: 'Seu nome',
                        hintText: 'Seu nome',
                        onSave: (value) => _session.name = value ?? '',
                        prefixIcon: FontAwesomeIcons.person,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          final finalValue = value ?? '';
                          if (finalValue.trim().isEmpty) return 'Informe seu nome para que as pessoas possam te reconhecer!';
                          return null;
                        },
                      ),

                      TebText(
                        'O código de de acesso é único para cada sessão e deve ser salvo para você possa acessá-la no futuro.',
                        textSize: 16,
                        padding: const EdgeInsets.only(top: 10, bottom: 5),
                      ),

                      // Code
                      TebTextEdit(
                        context: context,
                        width: MediaQuery.of(context).size.width < 700 ? MediaQuery.of(context).size.width * 0.8 : 700,
                        controller: _accessCodeController,
                        labelText: 'Código de acesso da sessão',
                        upperCase: true,
                        prefixIcon: Icons.mail_lock_sharp,
                        enabled: false,
                        padding: const EdgeInsets.only(bottom: 8),
                      ),
                      TebButton(
                        label: 'Copiar código de acesso',
                        buttonType: TebButtonType.outlinedButton,
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _accessCodeController.text));
                          TebCustomMessage.sucess(context, message: 'Código copiado para sua área de transferência!');
                        },
                      ),

                      TebText(
                        'O link abaixo deve ser compartilhado com as pessoas que você deseja obter um feedback sobre seu comportamento.',
                        textSize: 16,
                        padding: const EdgeInsets.only(top: 10, bottom: 5),
                      ),

                      // Code
                      TebTextEdit(
                        context: context,
                        width: MediaQuery.of(context).size.width < 700 ? MediaQuery.of(context).size.width * 0.8 : 700,
                        controller: _feedbackUrlController,
                        labelText: 'Link para pedido de feedback',
                        upperCase: true,
                        prefixIcon: Icons.hearing_outlined,
                        enabled: false,
                        padding: const EdgeInsets.only(bottom: 8),
                      ),
                      TebButton(
                        label: 'Copiar Link',
                        buttonType: TebButtonType.outlinedButton,
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _feedbackUrlController.text));
                          TebCustomMessage.sucess(context, message: 'Link copiado para sua área de transferência!');
                        },
                      ),
                      const SizedBox(height: 20),

                      // Butons
                      TebButtonsLine(
                        padding: const EdgeInsets.only(top: 30),
                        buttons: [
                          TebButton(
                            label: 'Cancelar',
                            onPressed: () => Navigator.of(context).pop(),
                            buttonType: TebButtonType.outlinedButton,
                          ),
                          TebButton(label: 'Continuar', onPressed: _submit),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
