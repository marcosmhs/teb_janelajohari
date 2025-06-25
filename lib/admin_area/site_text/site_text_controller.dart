//import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:teb_janelajohari/admin_area/site_text/site_text.dart';
import 'package:teb_package/control_widgets/teb_text.dart';
import 'package:teb_package/util/teb_return.dart';
import 'package:teb_package/util/teb_uid_generator.dart';

class SiteTextController with ChangeNotifier {
  SiteTextController();

  late final List<SiteText> _siteTextList = [];

  List<SiteText> get siteTextList => _siteTextList;

  static Future<List<SiteText>> getSiteTextList({required String page}) async {
    return await SiteTextController.getSiteTextFromPage(page: page);
  }

  static SiteText getSiteTextFromList({
    required List<SiteText> siteTextList,
    String page = '',
    required String local,
    Map<String, String>? replaceStringList,
  }) {
    var siteText = siteTextList.where((e) => e.local == local && (page == '' || e.page == page)).firstOrNull ?? SiteText();

    if (siteText.id.isNotEmpty) {
      var text = siteText.text;
      if (replaceStringList != null && replaceStringList.isNotEmpty) {
        replaceStringList.forEach((key, value) => text = text.replaceAll(key, value));
      }
      siteText.setText(text);
    }

    return siteText;
  }

  static Widget getHTMLFromList({
    required List<SiteText> siteTextList,
    String page = '',
    required String local,
    Map<String, String>? replaceStringList,
  }) {
    var siteText = siteTextList.where((e) => e.local == local && (page == '' || e.page == page)).firstOrNull ?? SiteText();
    var html = siteText.html;
    if (replaceStringList != null && replaceStringList.isNotEmpty) {
      replaceStringList.forEach((key, value) => html = html.replaceAll(key, value));
    }
    return Padding(
      padding: EdgeInsets.only(
        left: siteText.paddingLeft,
        right: siteText.paddingRight,
        top: siteText.paddingTop,
        bottom: siteText.paddingBotton,
      ),
      child: Html(data: html),
    );
  }

  static Widget getHTMLFromItem({required SiteText siteText}) {
    return Padding(
      padding: EdgeInsets.only(
        left: siteText.paddingLeft,
        right: siteText.paddingRight,
        top: siteText.paddingTop,
        bottom: siteText.paddingBotton,
      ),
      child: Html(data: siteText.html),
    );
  }

  Future<void> fillSiteTextList({required String page}) async {
    _siteTextList.addAll(await getSiteTextFromPage(page: page));
  }

  TebText getTebTextWidget({required String local, String defaultText = '', double defaultSize = 12}) {
    var siteText = _siteTextList.singleWhere((s) => s.local == local, orElse: () => SiteText());
    return TebText(
      siteText.id.isNotEmpty ? siteText.text : defaultText,
      textSize: siteText.id.isNotEmpty ? siteText.size : defaultSize,
      textWeight: siteText.id.isNotEmpty ? siteText.fontWeight : null,
      padding: EdgeInsets.only(
        left: siteText.paddingLeft,
        right: siteText.paddingRight,
        top: siteText.paddingTop,
        bottom: siteText.paddingBotton,
      ),
    );
  }

  static Future<List<String>> getSiteTextPageList() async {
    var dataRef = await FirebaseFirestore.instance.collection(SiteText.colletcionName).get();

    final dataList = dataRef.docs.map((doc) => doc.data()).toList();

    final List<String> r = [];

    for (var infoText in dataList) {
      var siteText = SiteText.fromMap(infoText);
      if (!r.contains(siteText.page)) {
        r.add(siteText.page);
      }
    }

    r.sort((a, b) => a.compareTo(b));

    return r;
  }

  static Future<List<SiteText>> getSiteTextFromPage({String page = ''}) async {
    var dataRef =
        page.isNotEmpty
            ? await FirebaseFirestore.instance.collection(SiteText.colletcionName).where("page", isEqualTo: page).get()
            : await FirebaseFirestore.instance.collection(SiteText.colletcionName).get();

    final dataList = dataRef.docs.map((doc) => doc.data()).toList();

    final List<SiteText> r = [];
    for (var infoText in dataList) {
      r.add(SiteText.fromMap(infoText));
    }

    r.sort((a, b) => a.page.compareTo(b.page) != 0 ? a.page.compareTo(b.page) : a.local.compareTo(b.local));

    return r;
  }

  static Future<String> get getSiteTextStringList async {
    var dataRef = await FirebaseFirestore.instance.collection(SiteText.colletcionName).get();

    final dataList = dataRef.docs.map((doc) => doc.data()).toList();

    final List<SiteText> r = [];
    for (var infoText in dataList) {
      r.add(SiteText.fromMap(infoText));
    }

    r.sort((a, b) => a.page.compareTo(b.page) != 0 ? a.page.compareTo(b.page) : a.local.compareTo(b.local));

    var str = '';
    for (var i in r) {
      str =
          '$str\n'
          '${i.page} - ${i.local}\n'
          '${i.size}\n'
          '${i.fontWeight.toString()}\n'
          '${i.color.toString()} - ${i.color.toARGB32()}\n'
          'L: ${i.paddingLeft}, R: ${i.paddingRight}, T: ${i.paddingTop}, B: ${i.paddingBotton}\n'
          '${i.text}\n\n';
    }

    return str;
  }

  Future<TebReturn> save({required List<SiteText> siteTextList}) async {
    try {
      for (var siteText in siteTextList) {
        if (siteText.status == SiteTextStatus.delete) {
          await FirebaseFirestore.instance.collection(SiteText.colletcionName).doc(siteText.id).delete();
        } else {
          if (siteText.id.isEmpty) siteText.id = TebUidGenerator.firestoreUid;

          await FirebaseFirestore.instance.collection(SiteText.colletcionName).doc(siteText.id).set(siteText.toMap);
        }
      }

      return TebReturn.sucess;
    } catch (e) {
      return TebReturn.error(e.toString());
    }
  }
}
