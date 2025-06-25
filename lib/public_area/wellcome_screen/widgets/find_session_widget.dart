// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:teb_janelajohari/local_data_controller.dart';
import 'package:teb_janelajohari/main/widgets/area_title_widget.dart';
import 'package:teb_janelajohari/public_area/session/session_controller.dart';
import 'package:teb_janelajohari/routes.dart';
import 'package:teb_package/control_widgets/teb_buttons_line.dart';
import 'package:teb_package/control_widgets/teb_text.dart';
import 'package:teb_package/control_widgets/teb_text_edit.dart';
import 'package:teb_package/messaging/teb_message.dart';
import 'package:teb_package/util/teb_return.dart';

class FindSessionWidget extends StatefulWidget {
  final Size size;
  final bool mobile;

  const FindSessionWidget({super.key, required this.size, required this.mobile});

  @override
  State<FindSessionWidget> createState() => _FindSessionWidgetState();
}

class _FindSessionWidgetState extends State<FindSessionWidget> {
  var _sendingData = false;
  final formKey = GlobalKey<FormState>();
  final TextEditingController _sessionAccessCodeController = TextEditingController();

  Future<void> _submit() async {
    if (!(formKey.currentState?.validate() ?? true)) {
      _sendingData = false;
    } else {
      if (_sendingData) return;
      _sendingData = true;
      try {
        if (_sessionAccessCodeController.text.isEmpty) {
          TebMessage.error(context, message: 'Ops, você não informou o código de acesso da sessão');
          return;
        }

        var sessionController = SessionController();

        var customReturn = await sessionController.getCurrentSessionByAccessCode(accessCode: _sessionAccessCodeController.text);

        if (customReturn.returnType == TebReturnType.error) {
          TebMessage.error(context, message: customReturn.message);
          return;
        }
        LocalDataController().saveSession(session: sessionController.currentSession);

        Navigator.of(
          context,
        ).popAndPushNamed(Routes.johariScreen, arguments: {'session': sessionController.currentSession, 'mobile': widget.mobile});
      } finally {
        _sendingData = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var inputWidget = Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TebText(
            'Informe abaixo o código do convite <br> para a sessão individual',
            textType: TextType.html,
            textSize: 16,
            textColor: Theme.of(context).canvasColor,
          ),

          ConstrainedBox(
            constraints: BoxConstraints.tightFor(height: 72, width: 250),
            child: TebTextEdit(
              context: context,
              labelText: 'Código do convite para a sessão',
              fillColor: Theme.of(context).canvasColor,
              controller: _sessionAccessCodeController,
              textInputAction: TextInputAction.send,
            ),
          ),
          TebButton(label: 'Entrar', textStyle: TextStyle(color: Theme.of(context).canvasColor), onPressed: () => _submit()),
        ],
      ),
    );

    var textWidget = TebText(
      'Utilize a opção ao lado para entrar em uma sessão de feedback de um colega e <b>dar seu feedback</b>',
      textType: TextType.html,
      textSize: 20,
      textColor: Theme.of(context).canvasColor,
    );
    return Column(
      children: [
        AreaTitleWidget(size: widget.size, mobile: widget.mobile, title: 'Dar seu feedback para um colega'),
        Container(
          //height: 300,
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(color: Colors.teal.shade400, borderRadius: BorderRadius.circular(12.0)),
          child:
              widget.mobile
                  ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [inputWidget, const SizedBox(height: 30), textWidget],
                  )
                  : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [inputWidget, const SizedBox(width: 30), Expanded(child: textWidget)],
                  ),
        ),
      ],
    );
  }
}
