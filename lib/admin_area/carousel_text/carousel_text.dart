import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

//https://pub.dev/packages/flutter_html

class CarouselText {
  static const String colletcionName = 'carousel_area';

  late String id;
  late String area;
  late String local;
  late String title;
  late String text;
  late double titleSize;
  late double textSize;
  late bool bold;
  late IconData icon;
  late Color backgroundColor;

  CarouselText({
    this.id = '',
    this.area = '',
    this.local = '',
    this.title = '',
    this.titleSize = 20,
    this.text = '',
    this.textSize = 12,
    this.bold = false,
    IconData? icon,
    Color? backgroundColor,
  }) {
    this.backgroundColor = backgroundColor ?? Colors.amberAccent;
    this.icon = icon ?? FontAwesomeIcons.a;
  }

  factory CarouselText.fromDocument(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return CarouselText.fromMap(data);
  }

  static CarouselText fromMap(Map<String, dynamic> map) {
    var u = CarouselText();

    u = CarouselText(
      id: map['id'] ?? '',
      area: map['area'] ?? '',
      local: map['local'] ?? '',
      title: map['title'] ?? '',
      titleSize: map['titleSize'] ?? 0,
      text: map['text'] ?? '',
      textSize: map['textSize'] ?? 0,
      bold: map['bold'] ?? false,
      icon: map['icon'] == null ? FontAwesomeIcons.a : IconDataSolid(map['iconData']),
      backgroundColor: map['backgroundColor'] == null ? Colors.amberAccent : Color(map['backgroundColor']),
    );
    return u;
  }

  Map<String, dynamic> get toMap {
    Map<String, dynamic> r = {};
    r = {
      'id': id,
      'area': area,
      'local': local,
      'title': title,
      'titleSize': titleSize,
      'text': text,
      'textSize': textSize,
      'bold': bold.toString(),
      'icon': icon.codePoint,
      'backgroundColor': backgroundColor.toARGB32(),
    };

    return r;
  }
}
