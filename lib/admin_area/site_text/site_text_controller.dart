//import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:teb_janelajohari/admin_area/site_text/site_text.dart';
import 'package:teb_package/util/teb_return.dart';
import 'package:teb_package/util/teb_uid_generator.dart';
import 'package:teb_package/visual_elements/teb_text.dart';

class SiteTextController with ChangeNotifier {
  SiteTextController();

  late final List<SiteText> _siteTextList = [];

  List<SiteText> get siteTextList => _siteTextList;

  static Future<List<SiteText>> getSiteTextList({required String page}) async {
    return await SiteTextController().getInfoTextFromPage(page: page);
  }

  static SiteText getSiteTextFromList({required List<SiteText> siteTextList, required String page, required String local}) {
    return siteTextList.where((e) => e.page == page).where((e) => e.local == local).firstOrNull ?? SiteText();
  }

  static Widget getHTML({required List<SiteText> siteTextList, required String local}) {
    var siteText = siteTextList.where((e) => e.local == local).firstOrNull ?? SiteText();
    return Html(data: siteText.html);
  }

  Future<void> fillSiteTextList({required String page}) async {
    _siteTextList.addAll(await getInfoTextFromPage(page: page));
  }

  TebText getTebTextWidget({required String local, String defaultText = '', double defaultSize = 12}) {
    var siteText = _siteTextList.singleWhere((s) => s.local == local, orElse: () => SiteText());
    return TebText(
      siteText.id.isNotEmpty ? siteText.text : defaultText,
      textSize: siteText.id.isNotEmpty ? siteText.size : defaultSize,
      textWeight: siteText.id.isNotEmpty ? siteText.fontWeight : null,
    );
  }

  static Future<List<String>> getSiteTextPageList() async {
    var dataRef =  await FirebaseFirestore.instance.collection(SiteText.colletcionName).get();

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

  Future<List<SiteText>> getInfoTextFromPage({String page = ''}) async {
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

  Future<TebCustomReturn> save({required List<SiteText> siteTextList}) async {
    try {
      for (var siteText in siteTextList) {
        if (siteText.status == SiteTextStatus.delete) {
          await FirebaseFirestore.instance.collection(SiteText.colletcionName).doc(siteText.id).delete();
        } else {
          if (siteText.id.isEmpty) siteText.id = TebUidGenerator.firestoreUid;

          await FirebaseFirestore.instance.collection(SiteText.colletcionName).doc(siteText.id).set(siteText.toMap);
        }
      }

      return TebCustomReturn.sucess;
    } catch (e) {
      return TebCustomReturn.error(e.toString());
    }
  }
}
