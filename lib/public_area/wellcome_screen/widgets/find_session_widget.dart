// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:teb_janelajohari/local_data_controller.dart';
import 'package:teb_janelajohari/main/widgets/area_title_widget.dart';
import 'package:teb_janelajohari/public_area/session/session_controller.dart';
import 'package:teb_janelajohari/routes.dart';
import 'package:teb_package/messaging/teb_custom_message.dart';
import 'package:teb_package/util/teb_return.dart';
import 'package:teb_package/visual_elements/teb_buttons_line.dart';
import 'package:teb_package/visual_elements/teb_text.dart';
import 'package:teb_package/visual_elements/teb_text_form_field.dart';

class FindSessionWidget extends StatelessWidget {
  final Size size;
  final bool mobile;
  const FindSessionWidget({super.key, required this.size, required this.mobile});

  Future<void> _findSession({required BuildContext context, required String accessCode}) async {
    if (accessCode.isEmpty) {
      TebCustomMessage.error(context, message: 'Ops, você não informou o código de acesso da sessão');
      return;
    }

    var sessionController = SessionController();

    var customReturn = await sessionController.getCurrentSessionByAccessCode(accessCode: accessCode);

    if (customReturn.returnType == TebReturnType.error) {
      TebCustomMessage.error(context, message: customReturn.message);
      return;
    }
    LocalDataController().saveSession(session: sessionController.currentSession);

    Navigator.of(context).popAndPushNamed(Routes.johariScreen, arguments: {'session': sessionController.currentSession, 'mobile': mobile});
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController sessionAccessCodeController = TextEditingController();

    var inputWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TebText('Informe abaixo o código do convite\npara a sessão individual', textColor: Theme.of(context).canvasColor),
        ConstrainedBox(
          constraints: BoxConstraints.tightFor(height: 72, width: 250),
          child: TebTextEdit(
            context: context,
            labelText: 'Código do convite para a sessão',
            fillColor: Theme.of(context).canvasColor,
            controller: sessionAccessCodeController,
          ),
        ),
        TebButton(
          label: 'Entrar',
          textStyle: TextStyle(color: Theme.of(context).canvasColor),
          onPressed: () => _findSession(context: context, accessCode: sessionAccessCodeController.text),
        ),
      ],
    );
    var tebTextWidget = TebText(
      'Utilize a opção ao lado para entrar em uma sessão de feedback de um colega e dar seu feedback',
      textSize: Theme.of(context).textTheme.titleLarge!.fontSize,
      textColor: Theme.of(context).canvasColor,
    );
    return Column(
      children: [
        AreaTitleWidget(size: size, title: 'Dar feedback para um colega', mobile: mobile),
        Container(
          //height: 300,
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(color: Colors.teal.shade400, borderRadius: BorderRadius.circular(12.0)),
          child:
              mobile
                  ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [inputWidget, const SizedBox(height: 30), tebTextWidget],
                  )
                  : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [inputWidget, const SizedBox(width: 30), Expanded(child: tebTextWidget)],
                  ),
        ),
      ],
    );
  }
}
