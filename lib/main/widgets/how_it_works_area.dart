import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:teb_janelajohari/main/widgets/area_title_widget.dart';
import 'package:teb_janelajohari/main/widgets/carousel_widget.dart';

class HowItWorksArea extends StatelessWidget {
  final bool mobile;
  const HowItWorksArea({super.key, required this.mobile});

  List<Map<String, dynamic>> getInfoList() {
    return [
      {
        'title': '1. Escolha de Palavras ',
        'icon': FontAwesomeIcons.book,
        'color': Color(0xFF4A90E2),
        'text':
            "<span style='color: white; font-size: 20px'>Cada participante escolhe palavras de uma lista (com adjetivos ou traços de personalidade) que melhor o definem.</span>",
      },
      {
        'title': '2. Feedback dos Colegas',
        'icon': FontAwesomeIcons.peopleGroup,
        'color': Color(0xFF50E3C2),

        'text':
            "<span style='color: white; font-size: 20px'>Os demais membros do grupo também escolhem palavras que descrevem esse participante.</span>",
      },
      {
        'title': '3. Construção da Janela',
        'icon': FontAwesomeIcons.square,
        'color': Color(0xFFF5A623),
        'text':
            "<span style='color: white; font-size: 20px'>Com os resultados, monta-se a matriz, identificando o que está em cada quadrante.</span>",
      },
      {
        'title': '4. Reflexão e Diálogo',
        'icon': FontAwesomeIcons.comments,
        'color': Color(0xFFBD10E0),
        'text':
            "<span style='color: white; font-size: 20px'>O grupo conversa sobre os achados, promovendo empatia e feedback construtivo.</span>",
      },
      {
        'title': '5. Plano de Ação',
        'icon': FontAwesomeIcons.bookAtlas,
        'color': Color(0xFF7ED321),
        'text':
            "<span style='color: white; font-size: 20px'>Os participantes definem ações para ampliar a area 'Aberta' e reduzir as áreas 'Cega' e 'Oculta'.</span>",
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AreaTitleWidget(
          size: size,
          title: mobile ? 'Como Aplicar' : 'Como Aplicar a Dinâmica',
          lineWidth: size.width * 0.05,
          mobile: mobile,
        ),
        CarouselWidget(size: size, carouselItems: getInfoList(), mobile: mobile),
      ],
    );
  }
}

class AreaTitle {}
