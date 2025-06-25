import 'package:flutter/material.dart';
import 'package:teb_janelajohari/main/widgets/area_title_widget.dart';
import 'package:teb_janelajohari/routes.dart';
import 'package:teb_package/control_widgets/teb_buttons_line.dart';
import 'package:teb_package/control_widgets/teb_text.dart';

class NewSessionWidget extends StatelessWidget {
  final Size size;
  final bool mobile;
  const NewSessionWidget({super.key, required this.size, required this.mobile});

  @override
  Widget build(BuildContext context) {
    var buttonWidget = TebButton(
      label: 'Clique aqui para criar sua própria sessão',
      size: Size(350, 50),
      textStyle: TextStyle(fontSize: 14),
      onPressed: () => Navigator.of(context).pushNamed(Routes.sessionForm, arguments: {'mobile': mobile}),
    );
    var textWidget = TebText(
      'Utilize esta opção para criar uma sessão própria, onde <b>você fará sua autoavaliação</b> e depois irá pedir a colegas de seu contribuam com <b>feedbacks utilizando os mesmos atributos</b>.',
      textType: TextType.html,
      textSize: 20,
      textColor: Theme.of(context).canvasColor,
    );

    return Column(
      children: [
        AreaTitleWidget(size: size, mobile: mobile, title: 'Criar uma sessão própria'),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(color: Colors.amber.shade600, borderRadius: BorderRadius.circular(12.0)),
          child:
              mobile
                  ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [buttonWidget, const SizedBox(height: 30), textWidget],
                  )
                  : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [buttonWidget, const SizedBox(width: 30), Expanded(child: textWidget)],
                  ),
        ),
      ],
    );
  }
}
