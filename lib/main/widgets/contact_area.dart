import 'package:flutter/material.dart';
import 'package:teb_janelajohari/main/widgets/area_title_widget.dart';
import 'package:teb_janelajohari/main/widgets/social_links_area.dart';
import 'package:teb_package/util/teb_url_manager.dart';
import 'package:teb_package/visual_elements/teb_text.dart';

class ContactArea extends StatelessWidget {
  final bool mobile;
  const ContactArea({super.key, this.mobile = false});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Column(
      children: [
        SizedBox(
          height: mobile ? null : size.height * 0.3,
          width: mobile ? null : size.width - 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AreaTitleWidget(size: size, title: 'Vamos conversar', mobile: mobile),
              Wrap(
                children: [
                  Text(
                    "Caso queira entrar em contato ou só mandar um oi, minha caixa de e-mail está sempre aberta",
                    textAlign: TextAlign.center,
                    style: TextStyle(letterSpacing: 0.75, fontSize: 17.0),
                  ),
                ],
              ),
              const SizedBox(height: 32.0),
              InkWell(
                onTap: () => TebUrlManager.launchEmail(email: 'marcosmhs@live.com'),
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                  child: Container(
                    margin: const EdgeInsets.all(0.85),
                    height: 40,
                    width: size.width * (mobile ? 0.45 : 0.15),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(6.0), color: Theme.of(context).primaryColor),
                    child: TebText(
                      "Enviar um e-mail",
                      textAlign: TextAlign.center,
                      textSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
                      letterSpacing: 3,
                      textColor: Theme.of(context).cardColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        if (mobile)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
            child: SocialLinksArea(context: context, size: size, mobile: true),
          ),

        //Footer
        TebText(
          "Desenvolvido por Marcos H. Silva\n${DateTime.now().year}",
          textSize: 15.0,
          letterSpacing: 3.0,
          textWeight: FontWeight.w200,
          textAlign: TextAlign.center,
          padding: EdgeInsets.only(bottom: 20),
        ),
      ],
    );
  }
}
