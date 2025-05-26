import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:teb_package/util/teb_util.dart';

enum SiteTextStatus { created, saved, delete, updated }

class SiteText {
  static const String colletcionName = 'site_text';

  late String id;
  late SiteTextStatus status;
  late String page;
  late String local;
  late String text;
  late double size;
  late Color color;
  late bool bold;
  late double paddingLeft;
  late double paddingRight;
  late double paddingTop;
  late double paddingBotton;

  SiteText({
    this.id = '',
    this.status = SiteTextStatus.created,
    this.page = '',
    this.local = '',
    this.text = '',
    this.size = 12,
    this.color = Colors.black,
    this.bold = false,
    this.paddingLeft = 0.0,
    this.paddingRight = 0.0,
    this.paddingTop = 0.0,
    this.paddingBotton = 0.0,
  });

  void setToRemove() {
    status = SiteTextStatus.delete;
  }

  void setUpdated() {
    if (status == SiteTextStatus.saved) status = SiteTextStatus.updated;
  }

  FontWeight get fontWeight => bold ? FontWeight.bold : FontWeight.normal;

  factory SiteText.fromDocument(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return SiteText.fromMap(data);
  }

  static SiteText fromMap(Map<String, dynamic> map) {
    var u = SiteText();

    u = SiteText(
      id: map['id'] ?? '',
      status: map['id'] == '' ? SiteTextStatus.created : SiteTextStatus.saved,
      page: map['page'] ?? '',
      local: map['local'] ?? '',
      text: map['text'] ?? '',
      size: map['size'] ?? 0,
      bold: map['bold'] ?? false,
      color: map['color'] == null ? Colors.black : Color(map['color']),
      paddingLeft: map['paddingLeft'] ?? 0.0,
      paddingRight: map['paddingRight'] ?? 0.0,
      paddingTop: map['paddingTop'] ?? 0.0,
      paddingBotton: map['paddingBotton'] ?? 0.0,
    );
    return u;
  }

  Map<String, dynamic> get toMap {
    Map<String, dynamic> r = {};
    r = {
      'id': id,
      'page': page,
      'local': local,
      'text': text,
      'size': size,
      'bold': bold,
      'color': color.toARGB32(),
      'paddingLeft': paddingLeft,
      'paddingRight': paddingRight,
      'paddingTop': paddingTop,
      'paddingBotton': paddingBotton,
    };

    return r;
  }

  void setText(String value) {
    text = value;
  }

  String get html {
    return "${bold ? '<b>' : ''}<span style='color: ${TebUtil.colorToHex(color)}; font-size: ${size}px'> $text </span>${bold ? '</b>' : ''}";
  }
}
