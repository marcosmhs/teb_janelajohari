import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:teb_package/control_widgets/teb_text.dart';

class CarouselWidget extends StatelessWidget {
  final Size size;
  final bool mobile;
  final List<Map<String, dynamic>> items;
  const CarouselWidget({super.key, required this.size, required this.items, required this.mobile});

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        viewportFraction: mobile ? 1 : 0.6,
        height: 400,
        initialPage: 0,
        enableInfiniteScroll: false,
        scrollDirection: Axis.horizontal,
      ),
      items:
          items.map((item) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  height: 0,
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(color: item['color'], borderRadius: BorderRadius.circular(12.0)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(item['icon'], size: 40, color: Colors.white),
                      const SizedBox(height: 10),
                      TebText(item['title'], textSize: 24, textWeight: FontWeight.bold, textColor: Theme.of(context).canvasColor),
                      const SizedBox(height: 8),
                      Padding(padding: const EdgeInsets.only(top: 10), child: Html(data: item['text'])),
                    ],
                  ),
                );
              },
            );
          }).toList(),
    );
  }
}
