import 'package:flutter/material.dart';
import 'package:teb_janelajohari/public_area/session/session.dart';

import 'package:teb_package/teb_package.dart';

class LocalDataController with ChangeNotifier {
  var _session = Session();
  Map<String, dynamic> _othersSessionFeedbackIdList = {};

  Session get localSession => Session.fromMap(_session.toMap);
  Map<String, dynamic> get othersSessionFeedbackIdList => _othersSessionFeedbackIdList;

  Future<void> chechLocalData() async {
    try {
      var sessionMap = await TebLocalStorage.readMap(key: 'session');

      if (sessionMap.isNotEmpty) _session = Session.fromMap(sessionMap);

      _othersSessionFeedbackIdList = await TebLocalStorage.getItemsFromList(key: 'othersSessionFeedbackIdList');
    } catch (e) {
      clearSessionData();
    }
  }

  void saveSession({required Session session}) {
    clearSessionData();
    TebLocalStorage.saveMap(key: 'session', map: session.toMap);
  }

  void saveOthersSessionFeedback({required String feedbackCode, required String sessionFeedbackId}) {
    TebLocalStorage.addItemToList(key: 'othersSessionFeedbackIdList', itemKey: feedbackCode, itemValue: sessionFeedbackId);
  }

  void clearSessionData() async {
    TebLocalStorage.removeValue(key: 'session');
  }
}
