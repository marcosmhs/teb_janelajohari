// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:teb_janelajohari/admin_area/site_text/site_text.dart';
import 'package:teb_janelajohari/admin_area/site_text/site_text_controller.dart';
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
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _accessCodeController = TextEditingController();
  final TextEditingController _feedbackUrlController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _initializing = true;
  Session _session = Session();
  bool _savingData = false;
  bool _newSession = false;
  bool _mobile = false;

  List<SiteText> _siteTextList = [];

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
                width: 600,
                child: Row(
                  children: [
                    Icon(FontAwesomeIcons.circleExclamation, size: 50, color: Colors.redAccent),
                    Expanded(
                      child: TebText(
                        'Lembre-se de salvar os dados de acesso e convite para feedback\n\n\n'
                        'Seu código de acesso será necessário para acessar seus feedbacks posteriormente',
                        padding: EdgeInsets.only(left: 20),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TebButton(
                  label: 'Copiar seu código de acesso',
                  buttonType: TebButtonType.outlinedButton,
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _accessCodeController.text));
                    TebCustomMessage.sucess(context, message: 'Código copiado para sua área de transferência!');
                  },
                ),
                TebButton(
                  label: 'Entendido',
                  onPressed: () {
                    Navigator.of(ctx).pop(true);
                  },
                ),
              ],
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

  Widget _adjectiveController({required String title, required List<String> adjectivesList, bool isPositive = true}) {
    var rowButtonsLine = Row(
      children: [
        TebButton(
          label: 'Selecionar Todos',
          buttonType: TebButtonType.outlinedButton,
          onPressed: () {
            setState(() {
              if (isPositive) {
                _session.positiveAdjectives.addAll(adjectivesList);
              } else {
                _session.constructiveAdjectives.addAll(adjectivesList);
              }
            });
          },
        ),
        TebButton(
          label: 'Desmarcar Todos',
          buttonType: TebButtonType.outlinedButton,
          padding: const EdgeInsets.only(left: 8),
          onPressed: () {
            setState(() {
              if (isPositive) {
                _session.positiveAdjectives.removeWhere((adjective) => adjectivesList.contains(adjective));
              } else {
                _session.constructiveAdjectives.removeWhere((adjective) => adjectivesList.contains(adjective));
              }
            });
          },
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_mobile)
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_mobile)
                TebText(
                  title,
                  textSize: Theme.of(context).textTheme.titleLarge!.fontSize,
                  textWeight: Theme.of(context).textTheme.titleLarge!.fontWeight,
                  textColor: Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.only(bottom: 10),
                ),
              rowButtonsLine,
            ],
          ),
        if (!_mobile)
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TebText(
                title,
                textSize: Theme.of(context).textTheme.titleLarge!.fontSize,
                textWeight: Theme.of(context).textTheme.titleLarge!.fontWeight,
                textColor: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.only(right: 20),
              ),
              rowButtonsLine,
            ],
          ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children:
                adjectivesList.map((adjective) {
                  return FilterChip(
                    label: Text(adjective),
                    selectedColor: isPositive ? Colors.blueAccent.withAlpha(100) : Colors.deepPurpleAccent.withAlpha(100),

                    selected:
                        isPositive
                            ? _session.positiveAdjectives.contains(adjective)
                            : _session.constructiveAdjectives.contains(adjective),
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          if (isPositive) {
                            _session.positiveAdjectives.add(adjective);
                          } else {
                            _session.constructiveAdjectives.add(adjective);
                          }
                        } else {
                          if (isPositive) {
                            _session.positiveAdjectives.remove(adjective);
                          } else {
                            _session.constructiveAdjectives.remove(adjective);
                          }
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
      SiteTextController.getSiteTextList(page: 'session_form').then((value) {
        setState(() => _siteTextList = value);
      });
    }

    return TebCustomScaffold(
      responsive: false,
      showAppBar: false,
      fixedWidth: MediaQuery.of(context).size.width * 0.9,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SiteTitleWidget(mobile: _mobile),
                const SizedBox(height: 20),
                AreaTitleWidget(
                  title: '',
                  size: MediaQuery.of(context).size,
                  mobile: _mobile,
                  siteTextPage: 'session_form',
                  siteTextLocal: 'new_session_text',
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 5),
                  child: SiteTextController.getHTML(siteTextList: _siteTextList, local: 'what_is_a_session'),
                ),

                // name
                TebTextEdit(
                  context: context,
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

                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 5),
                  child: SiteTextController.getHTML(siteTextList: _siteTextList, local: 'access_code'),
                ),

                // Code
                TebTextEdit(
                  context: context,
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

                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 5),
                  child: SiteTextController.getHTML(siteTextList: _siteTextList, local: 'feedback_link'),
                ),

                // Code
                TebTextEdit(
                  context: context,
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

                Padding(
                  padding: const EdgeInsets.only(bottom: 16, top: 16),
                  child: SiteTextController.getHTML(siteTextList: _siteTextList, local: 'adjective_list_text'),
                ),

                // Adjectives List
                _adjectiveController(title: 'Adjetivos Positivos:', adjectivesList: Session.basePositiveAdjectives),

                const SizedBox(height: 20),
                _adjectiveController(
                  title: 'Adjetivos/Atitudes Construtivos:',
                  adjectivesList: Session.baseConstructiveAdjectives,
                  isPositive: false,
                ),

                // Butons
                TebButtonsLine(
                  padding: const EdgeInsets.only(top: 30),
                  buttons: [
                    TebButton(label: 'Cancelar', onPressed: () => Navigator.of(context).pop()),
                    TebButton(label: 'Continuar', onPressed: _submit),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
