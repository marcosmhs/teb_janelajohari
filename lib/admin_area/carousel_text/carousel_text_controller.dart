//import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teb_janelajohari/admin_area/carousel_text/carousel_text.dart';
import 'package:teb_package/util/teb_return.dart';
import 'package:teb_package/util/teb_uid_generator.dart';
import 'package:flutter/foundation.dart';

class CarouselTextController with ChangeNotifier {
  CarouselTextController();

  Future<TebReturn> save({required CarouselText carouselText}) async {
    try {
      if (carouselText.id.isEmpty) {
        carouselText.id = TebUidGenerator.firestoreUid;
      }
      
      await FirebaseFirestore.instance.collection(CarouselText.colletcionName).doc(carouselText.id).set(carouselText.toMap);

      notifyListeners();
      return TebReturn.sucess;
    } catch (e) {
      return TebReturn.error(e.toString());
    }
  }

  Future<List<CarouselText>> getCarouselTextFromAreaAndLocal({required String area, local}) async {
    if (area.isEmpty) return [];

    var dataRef =
        await FirebaseFirestore.instance
            .collection(CarouselText.colletcionName)
            .where("area", isEqualTo: area)
            .where("local", isEqualTo: local)
            .get();

    final dataList = dataRef.docs.map((doc) => doc.data()).toList();

    final List<CarouselText> r = [];
    for (var infoText in dataList) {
      r.add(CarouselText.fromMap(infoText));
    }
    return r;
  }

  Future<TebReturn> delete({required CarouselText carouselText}) async {
    try {
      await FirebaseFirestore.instance.collection(CarouselText.colletcionName).doc(carouselText.id).delete();

      notifyListeners();
      return TebReturn.sucess;
    } catch (e) {
      return TebReturn.error(e.toString());
    }
  }
}
