import 'package:flutter/material.dart';
import 'package:teb_package/control_widgets/teb_text.dart';

class VerticalListWidget extends StatelessWidget {
  final Size size;
  final bool mobile;
  final List<Map<String, dynamic>> items;
  const VerticalListWidget({super.key, required this.size, required this.items, required this.mobile});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          items
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(item['icon'], size: 40, color: item['color']),
                          Expanded(
                            child: TebText(
                              item['title'] ?? '',
                              textColor: item['color'],
                              textSize: 24,
                              textWeight: FontWeight.bold,
                              padding: EdgeInsets.only(left: 20),
                              textType: TextType.html,
                            ),
                          ),
                        ],
                      ),
                      TebText(item['text'] ?? '', textSize: 20, textWeight: FontWeight.normal, textType: TextType.html),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              )
              .toList(),
    );
  }
}
