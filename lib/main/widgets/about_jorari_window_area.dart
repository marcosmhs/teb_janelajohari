import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:teb_janelajohari/main/widgets/area_title_widget.dart';
import 'package:teb_janelajohari/main/widgets/carousel_widget.dart';

class AboutArea extends StatelessWidget {
  final bool mobile;
  const AboutArea({super.key, required this.mobile});

  List<Map<String, dynamic>> getInfoList() {
    return [
      {
        'title': '1. O Que é a Janela de Johari?',
        'icon': FontAwesomeIcons.brain,
        'color': Color(0xFF4A90E2),
        'text':
            "<span style='color: white; font-size: 20px'>A Janela de Johari é uma ferramenta de <b>autoconhecimento</b> "
            "e desenvolvimento interpessoal "
            "criada por Joseph Luft e Harrington Ingham. Ela ajuda as pessoas a entenderem como se"
            "percebem e como são percebidas pelos outros</span>",
      },
      {
        'title': '2. Os Quatro Quadrantes',
        'icon': FontAwesomeIcons.arrowsToCircle,
        'color': Color(0xFF50E3C2),
        'text':
            "<span style='color: white; font-size: 20px'>A matriz da Janela de Johari é dividida em quatro áreas: Aberta (conhecido por mim e "
            "pelos outros), Oculta (conhecido por mim, mas não pelos outros), Cega (conhecido pelos "
            "outros, mas não por mim) e Desconhecida (nem eu nem os outros conhecem)</span>",
      },
      {
        'title': '3. Por Que Usar a Janela de Johari?',
        'icon': FontAwesomeIcons.handshake,
        'color': Color(0xFFF5A623),
        'text':
            "<span style='color: white; font-size: 20px'>Essa ferramenta <b>promove a empatia, melhora a comunicação e fortalece relacionamentos</b>, tanto "
            "em equipes quanto em contextos pessoais. É muito usada em processos de coaching, "
            "liderança e desenvolvimento de equipes.</span>",
      },
      {
        'title': '4. Ampliando a Autoconsciência',
        'icon': FontAwesomeIcons.magnifyingGlassArrowRight,
        'color': Color(0xFFBD10E0),
        'text':
            "<span style='color: white; font-size: 20px'>Ao dar e receber feedbacks, é possível expandir a área da 'Aberta', tornando as relações mais "
            "abertas, seguras e eficazes. Isso é fundamental para ambientes colaborativos e de alta performance.</span>",
      },
      {
        'title': '5. Aplicação em Equipes',
        'icon': FontAwesomeIcons.message,
        'color': Color(0xFF7ED321),
        'text':
            "<span style='color: white; font-size: 20px'>A Janela de Johari é especialmente útil em equipes, pois revela percepções não ditas e reduz "
            "ruídos na comunicação. Estimula um ambiente mais transparente e fortalece a confiança entre os membros.</span>",
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [AreaTitleWidget(size: size, title: 'Sobre', mobile: mobile), CarouselWidget(size: size, carouselItems: getInfoList(), mobile: mobile,)],
    );
  }
}
