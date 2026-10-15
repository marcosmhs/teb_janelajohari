//import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:teb_janelajohari/public_area/session/session.dart';
import 'package:teb_janelajohari/local_data_controller.dart';
import 'package:teb_package/util/teb_return.dart';
import 'package:teb_package/util/teb_uid_generator.dart';
import 'package:flutter/foundation.dart';

class SessionController with ChangeNotifier {
  late Session _currentSession;
  late Map<String, dynamic> _givenFeedbackCodeList;

  SessionController() {
    _currentSession = Session();
    _givenFeedbackCodeList = {};
  }

  Session get currentSession => Session.fromMap(_currentSession.toMap);
  Map<String, dynamic> get givenFeedbackCodeList => _givenFeedbackCodeList;

  Future<Map<String, dynamic>> get stats async {
    try {
      var sessions = <Session>[];

      var querySnapshot = await FirebaseFirestore.instance.collection(Session.collectionName).get();

      if (querySnapshot.docs.isNotEmpty) {
        sessions = querySnapshot.docs.map((doc) => Session.fromDocument(doc)).toList();
      }

      var sessionIds = sessions.map((session) => session.id).toList();

      final datedSessions = sessions.where((e) => e.createDate != null).toList();
      DateTime? lastSessionDate;
      if (datedSessions.isNotEmpty) {
        lastSessionDate = datedSessions
            .reduce((a, b) => a.createDate!.isAfter(b.createDate!) ? a : b)
            .createDate;
      }

      return {'sessionsCount': sessions.length, 'lastSession': lastSessionDate, 'sessionsIdList': sessionIds};
    } catch (e) {
      return {'sessionsCount': 0, 'lastSession': null, 'sessionsIdList': <String>[]};
    }
  }

  Future<TebReturn> save({required Session session}) async {
    try {
      if (session.id.isEmpty) {
        session.id = TebUidGenerator.firestoreUid;
        session.createDate = DateTime.now();
        // O código cifrado é derivado automaticamente em Session.toMap.

        if (session.positiveAdjectives.isNotEmpty) {
          session.positiveAdjectives = session.positiveAdjectives.toSet().toList();
        }
        if (session.constructiveAdjectives.isNotEmpty) {
          session.constructiveAdjectives = session.constructiveAdjectives.toSet().toList();
        }
      }

      await FirebaseFirestore.instance.collection(Session.collectionName).doc(session.id).set(session.toMap);

      _currentSession = session;
      LocalDataController().saveSession(session: session);

      return TebReturn.success;
    } catch (e) {
      return TebReturn.error(e.toString());
    }
  }

  //F6IB8F9Y
  Future<TebReturn> getCurrentSessionByAccessCode({required String accessCode}) async {
    try {
      final collection = FirebaseFirestore.instance.collection(Session.collectionName);

      // 1) Índice de busca atual (determinístico, não reversível).
      var sessionQuery = await collection.where("accessCodeHash", isEqualTo: Session.accessCodeHashOf(accessCode)).get();
      var dataList = sessionQuery.docs.map((doc) => doc.data()).toList();

      // 2) Sessões ainda não migradas: formato antigo determinístico.
      if (dataList.isEmpty) {
        sessionQuery = await collection
            .where("encryptedAccessCode", isEqualTo: Session.legacyEncryptedAccessCodeOf(accessCode))
            .get();
        dataList = sessionQuery.docs.map((doc) => doc.data()).toList();
      }

      // 3) Sessões bem antigas: código em texto puro.
      if (dataList.isEmpty) {
        sessionQuery = await collection.where("accessCode", isEqualTo: accessCode.trim()).get();
        dataList = sessionQuery.docs.map((doc) => doc.data()).toList();
      }

      if (dataList.isEmpty) return TebReturn.error('Não foi encontrada uma sessão com este código');
      if (dataList.length > 1) {
        return TebReturn.error('Foi encontrada mais de uma sessão com este código, por isso não é possível continuar.');
      }

      _currentSession = Session.fromMap(dataList.first);

      var localDataController = LocalDataController();
      localDataController.saveSession(session: _currentSession);

      return TebReturn.success;
    } catch (e) {
      return TebReturn.error('Erro! ${e.toString()}');
    }
  }

  Future<TebReturn> getCurrentSessionByFeedbackCode({required String feedbackCode}) async {
    try {
      var sessionQuery =
          await FirebaseFirestore.instance
              .collection(Session.collectionName)
              .where("feedbackCode", isEqualTo: feedbackCode)
              .get();

      final dataList = sessionQuery.docs.map((doc) => doc.data()).toList();

      if (dataList.isEmpty) return TebReturn.error('Não foi encontrada uma sessão com este código');
      if (dataList.length > 1) return TebReturn.error('Foi encontrada mais de uma sessão com este código');

      _currentSession = Session.fromMap(dataList.first);

      var localDataController = LocalDataController();
      await localDataController.chechLocalData();

      _givenFeedbackCodeList = localDataController.othersSessionFeedbackIdList;

      return TebReturn.success;
    } catch (e) {
      return TebReturn.error('Erro! ${e.toString()}');
    }
  }

  Future<TebReturn> delete({required Session session}) async {
    try {
      await FirebaseFirestore.instance.collection(Session.collectionName).doc(session.id).delete();

      notifyListeners();
      return TebReturn.success;
    } catch (e) {
      return TebReturn.error(e.toString());
    }
  }

  /// Converte, de uma só vez, as sessões gravadas no formato antigo (código
  /// determinístico / texto puro) para o formato atual, gravando o
  /// `accessCodeHash` de busca e o `encryptedAccessCode` aleatório.
  ///
  /// Idempotente: ignora documentos que já possuem `accessCodeHash`. Execute
  /// uma única vez após o deploy (ex.: a partir da área administrativa).
  Future<TebReturn> migrateAccessCodes() async {
    try {
      final collection = FirebaseFirestore.instance.collection(Session.collectionName);
      final snapshot = await collection.get();

      final batch = FirebaseFirestore.instance.batch();
      var migrated = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        if ((data['accessCodeHash'] ?? '').toString().isNotEmpty) continue;

        // fromMap decifra o formato antigo; toMap regrava já no formato novo.
        batch.set(doc.reference, Session.fromMap(data).toMap);
        migrated++;
      }

      if (migrated > 0) await batch.commit();

      return TebReturn.success;
    } catch (e) {
      return TebReturn.error(e.toString());
    }
  }
}
