import 'package:flutter/material.dart';
import 'package:teb_janelajohari/public_area/session/session.dart';

import 'package:teb_package/teb_package.dart';

class LocalDataController with ChangeNotifier {
  var _session = Session();

  Session get localSession => Session.fromMap(_session.toMap);

  Future<void> chechLocalData() async {
    try {
      var sessionMap = await TebLocalStorage.readMap(key: 'session');

      if (sessionMap.isEmpty) return;

      _session = Session.fromMap(sessionMap);
    } catch (e) {
      clearSessionData();
    }
  }

  void saveSession({required Session session}) {
    clearSessionData();
    TebLocalStorage.saveMap(key: 'session', map: session.toMap);
  }

  void clearSessionData() async {
    TebLocalStorage.removeValue(key: 'session');
  }
}
