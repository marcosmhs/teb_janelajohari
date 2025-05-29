import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:teb_janelajohari/local_data_controller.dart';
import 'package:teb_janelajohari/public_area/session/session.dart';
import 'package:teb_janelajohari/public_area/session_feedbacks/session_feedbacks.dart';
import 'package:teb_package/util/teb_return.dart';
import 'package:teb_package/util/teb_uid_generator.dart';

class SessionFeedbackController with ChangeNotifier {
  SessionFeedbackController();

  Future<TebCustomReturn> save({required SessionFeedbacks sessionFeedbacks, required Session session}) async {
    try {
      if (sessionFeedbacks.id.isEmpty) {
        sessionFeedbacks.id = TebUidGenerator.firestoreUid;
        sessionFeedbacks.sessionId = session.id;
      }

      await FirebaseFirestore.instance
          .collection(Session.colletcionName)
          .doc(session.id)
          .collection(SessionFeedbacks.colletcionName)
          .doc(sessionFeedbacks.id)
          .set(sessionFeedbacks.toMap);

      if (sessionFeedbacks.feedbackType == FeedbackType.others) {
        LocalDataController().saveOthersSessionFeedback(
          feedbackCode: session.feedbackCode,
          sessionFeedbackId: sessionFeedbacks.id,
        );
      }

      return TebCustomReturn.sucess;
    } catch (e) {
      return TebCustomReturn.error(e.toString());
    }
  }

  Future<List<SessionFeedbacks>> getSessionFeedbacksBySessionId({required String sessionId, FeedbackType? feedbackType}) async {
    try {
      var feedbacks = <SessionFeedbacks>[];
      var collectionRef = FirebaseFirestore.instance
          .collection(Session.colletcionName)
          .doc(sessionId)
          .collection(SessionFeedbacks.colletcionName);

      Query query = collectionRef;
      if (feedbackType != null) {
        query = query.where('feedbackType', isEqualTo: feedbackType.toString());
      }

      var querySnapshot = await query.get();

      if (querySnapshot.docs.isNotEmpty) {
        feedbacks = querySnapshot.docs.map((doc) => SessionFeedbacks.fromDocument(doc)).toList();
      }
      return [...feedbacks];
    } catch (e) {
      return [];
    }
  }

  Future<SessionFeedbacks> getSessionFeedbackBySessionFeedbackId({
    required String sessionId,
    required String sessionFeedbackId,
  }) async {
    try {
      var querySnapshot =
          await FirebaseFirestore.instance
              .collection(Session.colletcionName)
              .doc(sessionId)
              .collection(SessionFeedbacks.colletcionName)
              .doc(sessionFeedbackId)
              .get();

      if (querySnapshot.exists) return SessionFeedbacks.fromDocument(querySnapshot);

      return SessionFeedbacks();
    } catch (e) {
      return SessionFeedbacks();
    }
  }

  Future<SessionFeedbacks> getSessionSelfFeedbackBySessionId({required String sessionId}) async {
    try {
      var feedbacks = <SessionFeedbacks>[];
      var querySnapshot =
          await FirebaseFirestore.instance
              .collection(Session.colletcionName)
              .doc(sessionId)
              .collection(SessionFeedbacks.colletcionName)
              .where('feedbackType', isEqualTo: FeedbackType.self.toString())
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        feedbacks = querySnapshot.docs.map((doc) => SessionFeedbacks.fromDocument(doc)).toList();
      }
      return feedbacks.first;
    } catch (e) {
      return SessionFeedbacks();
    }
  }

  Stream<QuerySnapshot<Object?>> getSessionFeedbacks({required String sessionId}) {
    return FirebaseFirestore.instance
        .collection(Session.colletcionName)
        .doc(sessionId)
        .collection(SessionFeedbacks.colletcionName)
        .snapshots();
  }

  static Map<String, Map<String, dynamic>> getAllAreasFeedback({required List<SessionFeedbacks> feedbacks}) {
    try {
      var selfFeedback = feedbacks.where((f) => f.feedbackType == FeedbackType.self);
      var othersFeedbacks = feedbacks.where((f) => f.feedbackType == FeedbackType.others);

      var selfPositiveAdjectives = selfFeedback.expand((f) => f.positiveAdjectives).toSet();
      var selfConstructiveAdjectives = selfFeedback.expand((f) => f.constructiveAdjectives).toSet();

      var otherPositiveAdjectives = othersFeedbacks.expand((f) => f.positiveAdjectives).toSet();
      var otherConstructiveAdjectives = othersFeedbacks.expand((f) => f.constructiveAdjectives).toSet();

      List<String> othersFeedbackComments = othersFeedbacks.where((e) => e.comments.isNotEmpty).map((f) => f.comments).toList();

      // Contar adjetivos positivos e construtivos dos othersFeedbacks
      Map<String, int> otherPositiveAdjectivesCount = {};
      Map<String, int> otherConstructiveAdjectivesCount = {};

      for (var feedback in othersFeedbacks) {
        for (var adj in feedback.positiveAdjectives) {
          otherPositiveAdjectivesCount[adj] = (otherPositiveAdjectivesCount[adj] ?? 0) + 1;
        }

        for (var adj in feedback.constructiveAdjectives) {
          otherConstructiveAdjectivesCount[adj] = (otherConstructiveAdjectivesCount[adj] ?? 0) + 1;
        }
      }

      // Ordenar por quantidade decrescente
      var sortedPositive = otherPositiveAdjectivesCount.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      var sortedConstructive = otherConstructiveAdjectivesCount.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

      // Open Area
      List<String> openPositiveAdjectives = selfPositiveAdjectives.where((a) => otherPositiveAdjectives.contains(a)).toList();
      List<String> openConstructiveAdjectives =
          selfConstructiveAdjectives.where((a) => otherConstructiveAdjectives.contains(a)).toList();

      // Blind Area
      List<String> blindPositiveAdjectives = otherPositiveAdjectives.where((a) => !selfPositiveAdjectives.contains(a)).toList();
      List<String> blindConstructiveAdjectives =
          otherConstructiveAdjectives.where((a) => !selfConstructiveAdjectives.contains(a)).toList();

      // Hidden Area
      List<String> hiddenPositiveAdjectives = selfPositiveAdjectives.where((a) => !otherPositiveAdjectives.contains(a)).toList();
      List<String> hiddenConstructiveAdjectives =
          selfConstructiveAdjectives.where((a) => !otherConstructiveAdjectives.contains(a)).toList();

      // Sort all lists alphabetically

      return {
        'selfFeedback': {
          'positiveAdjectives': selfPositiveAdjectives.toList()..sort(),
          'constructiveAdjectives': selfConstructiveAdjectives.toList()..sort(),
        },
        'othersFeedback': {
          'count': othersFeedbacks.length,
          'positiveAdjectives': otherPositiveAdjectives.toList()..sort(),
          'positiveAdjectivesWithCount': sortedPositive.map((e) => '${e.key} (${e.value})').toList(),
          'constructiveAdjectives': otherConstructiveAdjectives.toList()..sort(),
          'constructiveAdjectivesWithCount': sortedConstructive.map((e) => '${e.key} (${e.value})').toList(),
          'comments': othersFeedbackComments.toList()..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase())),
        },
        'openArea': {
          'positiveAdjectives': openPositiveAdjectives..sort(),
          'constructiveAdjectives': openConstructiveAdjectives..sort(),
        },
        'blindArea': {
          'positiveAdjectives': blindPositiveAdjectives..sort(),
          'constructiveAdjectives': blindConstructiveAdjectives..sort(),
        },
        'hiddenArea': {
          'positiveAdjectives': hiddenPositiveAdjectives..sort(),
          'constructiveAdjectives': hiddenConstructiveAdjectives..sort(),
        },
      };
    } catch (e) {
      return {
        'selfFeedback': {'positiveAdjectives': [], 'constructiveAdjectives': []},
        'othersFeedback': {
          'count': 0,
          'positiveAdjectives': [],
          'positiveAdjectivesWithCount': [],
          'constructiveAdjectives': [],
          'constructiveAdjectivesWithCount': [],
          'comments': [],
        },
        'openArea': {'positiveAdjectives': [], 'constructiveAdjectives': []},
        'blindArea': {'positiveAdjectives': [], 'constructiveAdjectives': []},
        'hiddenArea': {'positiveAdjectives': [], 'constructiveAdjectives': []},
      };
    }
  }

  Future<Map<String, dynamic>> stats({required List<String> sessionIdList}) async {
    List<SessionFeedbacks> sessionFeedbacksList = [];
    for (var sessionid in sessionIdList) {
      var sessionFeedbacks = await getSessionFeedbacksBySessionId(sessionId: sessionid);
      sessionFeedbacksList.addAll(sessionFeedbacks);
    }

    int totalAdjectivesCount = sessionFeedbacksList.fold(0, (total, feedback) {
      return total + feedback.positiveAdjectives.length + feedback.constructiveAdjectives.length;
    });

    int totalCommentsCount = sessionFeedbacksList.fold(0, (total, feedback) {
      return total + (feedback.comments.trim().isNotEmpty ? 1 : 0);
    });

    var lastFeedback = sessionFeedbacksList.reduce((a, b) => a.createDate.isAfter(b.createDate) ? a : b);

    Map<String, int> positiveAdjectivesCount = {};
    Map<String, int> constructiveAdjectivesCount = {};

    for (var feedback in sessionFeedbacksList) {
      for (var adjective in feedback.positiveAdjectives) {
        positiveAdjectivesCount[adjective] = (positiveAdjectivesCount[adjective] ?? 0) + 1;
      }
      for (var adjective in feedback.constructiveAdjectives) {
        constructiveAdjectivesCount[adjective] = (constructiveAdjectivesCount[adjective] ?? 0) + 1;
      }
    }

    constructiveAdjectivesCount = Map.fromEntries(
      constructiveAdjectivesCount.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );

    positiveAdjectivesCount = Map.fromEntries(
      positiveAdjectivesCount.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );

    return {
      'sessionFeedbacksCount': sessionFeedbacksList.length,
      'totalAdjectives': totalAdjectivesCount,
      'totalComments': totalCommentsCount,
      'lastFeedback': lastFeedback.createDate,
      'positiveAdjectivesCount': positiveAdjectivesCount,
      'constructiveAdjectivesCount': constructiveAdjectivesCount,
    };
  }
}
