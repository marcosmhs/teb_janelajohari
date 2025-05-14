//import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teb_janelajohari/public_area/session/session.dart';
import 'package:teb_janelajohari/local_data_controller.dart';
import 'package:teb_package/util/teb_return.dart';
import 'package:teb_package/util/teb_uid_generator.dart';
import 'package:flutter/foundation.dart';

class SessionController with ChangeNotifier {
  late Session _currentSession;

  SessionController() {
    _currentSession = Session();
  }

  Session get currentSession => Session.fromMap(_currentSession.toMap);

  Future<Map<String, dynamic>> get stats async {
    try {
      var sessions = <Session>[];

      var querySnapshot = await FirebaseFirestore.instance.collection(Session.colletcionName).get();

      if (querySnapshot.docs.isNotEmpty) {
        sessions = querySnapshot.docs.map((doc) => Session.fromDocument(doc)).toList();
      }

      var sessionIds = sessions.map((session) => session.id).toList();

      var lastSession = sessions
          .where((e) => e.createDate != null)
          .reduce((a, b) => a.createDate!.isAfter(b.createDate!) ? a : b);
      return {'sessionsCount': sessions.length, 'lastSession': lastSession.createDate, 'sessionsIdList': sessionIds};
    } catch (e) {
      return {'positiveAdjectives': ''};
    }
  }

  Future<TebCustomReturn> save({required Session session}) async {
    try {
      if (session.id.isEmpty) {
        session.id = TebUidGenerator.firestoreUid;
        session.createDate = DateTime.now();
      }

      await FirebaseFirestore.instance.collection(Session.colletcionName).doc(session.id).set(session.toMap);

      _currentSession = session;

      return TebCustomReturn.sucess;
    } catch (e) {
      return TebCustomReturn.error(e.toString());
    }
  }

  Future<TebCustomReturn> getCurrentSessionByAccessCode({required String accessCode}) async {
    try {
      var sessionQuery =
          await FirebaseFirestore.instance.collection(Session.colletcionName).where("accessCode", isEqualTo: accessCode).get();

      final dataList = sessionQuery.docs.map((doc) => doc.data()).toList();

      if (dataList.isEmpty) return TebCustomReturn.error('Não foi encontrada uma sessão com este código');
      if (dataList.length > 1) return TebCustomReturn.error('Foi encontrada mais de uma sessão com este código');

      _currentSession = Session.fromMap(dataList.first);

      var localDataController = LocalDataController();
      localDataController.saveSession(session: _currentSession);

      return TebCustomReturn.sucess;
    } catch (e) {
      return TebCustomReturn.error('Erro! ${e.toString()}');
    }
  }

  Future<TebCustomReturn> getCurrentSessionByFeedbackCode({required String feedbackCode}) async {
    try {
      var sessionQuery =
          await FirebaseFirestore.instance
              .collection(Session.colletcionName)
              .where("feedbackCode", isEqualTo: feedbackCode)
              .get();

      final dataList = sessionQuery.docs.map((doc) => doc.data()).toList();

      if (dataList.isEmpty) return TebCustomReturn.error('Não foi encontrada uma sessão com este código');
      if (dataList.length > 1) return TebCustomReturn.error('Foi encontrada mais de uma sessão com este código');

      _currentSession = Session.fromMap(dataList.first);

      var localDataController = LocalDataController();
      localDataController.saveSession(session: _currentSession);

      return TebCustomReturn.sucess;
    } catch (e) {
      return TebCustomReturn.error('Erro! ${e.toString()}');
    }
  }

  Future<TebCustomReturn> delete({required Session session}) async {
    try {
      await FirebaseFirestore.instance.collection(Session.colletcionName).doc(session.id).delete();

      notifyListeners();
      return TebCustomReturn.sucess;
    } catch (e) {
      return TebCustomReturn.error(e.toString());
    }
  }
}
