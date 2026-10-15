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
    if (_sendingData) return;
    if (!(formKey.currentState?.validate() ?? false)) return;

    if (_sessionAccessCodeController.text.trim().isEmpty) {
      TebMessage.error(context, message: 'Ops, você não informou o código de acesso da sessão');
      return;
    }

    setState(() => _sendingData = true);
    try {
      final sessionController = SessionController();
      final customReturn = await sessionController.getCurrentSessionByAccessCode(
        accessCode: _sessionAccessCodeController.text,
      );

      if (!mounted) return;

      if (customReturn.returnType == TebReturnType.error) {
        TebMessage.error(context, message: customReturn.message);
        return;
      }

      LocalDataController().saveSession(session: sessionController.currentSession);

      Navigator.of(context).popAndPushNamed(
        Routes.johariScreen,
        arguments: {'session': sessionController.currentSession, 'mobile': widget.mobile},
      );
    } finally {
      if (mounted) setState(() => _sendingData = false);
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
            'Informe abaixo o código de acesso<br>para sua sessão',
            textType: TextType.html,
            fontSize: 16,
            fontColor: Theme.of(context).canvasColor,
          ),

          ConstrainedBox(
            constraints: BoxConstraints.tightFor(height: 72, width: 250),
            child: TebTextEdit(
              labelText: 'Código de acesso',
              fillColor: Theme.of(context).canvasColor,
              controller: _sessionAccessCodeController,
              textInputAction: TextInputAction.send,
            ),
          ),
          _sendingData
              ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: CircularProgressIndicator(color: Theme.of(context).canvasColor),
              )
              : TebButton(label: 'Entrar', textStyle: TextStyle(color: Theme.of(context).canvasColor), onPressed: _submit),
        ],
      ),
    );

    var textWidget = TebText(
      'Utilize a opção ao lado para entrar em sua sessão de feedback',
      textType: TextType.html,
      fontSize: 20,
      fontColor: Theme.of(context).canvasColor,
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
