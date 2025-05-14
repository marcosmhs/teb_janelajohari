import 'package:flutter/material.dart';
import 'package:teb_janelajohari/main/widgets/area_title_widget.dart';
import 'package:teb_janelajohari/routes.dart';
import 'package:teb_package/visual_elements/teb_buttons_line.dart';
import 'package:teb_package/visual_elements/teb_text.dart';

class NewSessionWidget extends StatelessWidget {
  final Size size;
  final bool mobile;
  const NewSessionWidget({super.key, required this.size, required this.mobile});

  @override
  Widget build(BuildContext context) {
    var buttonWidget = TebButton(
      label: 'Criar uma sessão individual',
      size: mobile ? null : Size(260, 50),
      textStyle: TextStyle(fontSize: 14),
      onPressed: () => Navigator.of(context).pushNamed(Routes.sessionForm, arguments: {'mobile': mobile}),
    );
    var textWidget = TebText(
      'Utilize esta opção para criar uma sessão própria, onde você fará sua autoavaliação e'
      'depois irá pedir a colegas de seu time um feedback com base nos mesmos atributos.',
      textSize: Theme.of(context).textTheme.titleLarge!.fontSize,
      textColor: Theme.of(context).canvasColor,
    );
    return Column(
      children: [
        AreaTitleWidget(size: size, title: 'Criar uma sessão própria', mobile: mobile),
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
