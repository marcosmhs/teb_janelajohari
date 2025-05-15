import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:teb_janelajohari/public_area/session/session.dart';
import 'package:teb_janelajohari/public_area/session_feedbacks/session_feedbacks.dart';
import 'package:teb_package/util/teb_return.dart';
import 'package:teb_package/util/teb_uid_generator.dart';

class SessionFeedbackController with ChangeNotifier {
  SessionFeedbackController();

  Future<TebCustomReturn> save({required SessionFeedbacks sessionFeedbacks, required String sessionId}) async {
    try {
      if (sessionFeedbacks.id.isEmpty) {
        sessionFeedbacks.id = TebUidGenerator.firestoreUid;
        sessionFeedbacks.sessionId = sessionId;
      }

      await FirebaseFirestore.instance
          .collection(Session.colletcionName)
          .doc(sessionId)
          .collection(SessionFeedbacks.colletcionName)
          .doc(sessionFeedbacks.id)
          .set(sessionFeedbacks.toMap);

      return TebCustomReturn.sucess;
    } catch (e) {
      return TebCustomReturn.error(e.toString());
    }
  }

  Future<List<SessionFeedbacks>> getSessionFeedbacks({required String sessionId, FeedbackType? feedbackType}) async {
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

  Future<Map<String, Map<String, dynamic>>> getAllAreasFeedback({required String sessionId}) async {
    try {
      var selfFeedback = await getSessionFeedbacks(sessionId: sessionId, feedbackType: FeedbackType.self);
      var othersFeedbacks = await getSessionFeedbacks(sessionId: sessionId, feedbackType: FeedbackType.others);

      var selfPositiveAdjectives = selfFeedback.expand((feedback) => feedback.positiveAdjectives).toSet();
      var selfConstructiveAdjectives = selfFeedback.expand((feedback) => feedback.constructiveAdjectives).toSet();

      var otherPositiveAdjectives = othersFeedbacks.expand((feedback) => feedback.positiveAdjectives).toSet();
      var otherConstructiveAdjectives = othersFeedbacks.expand((feedback) => feedback.constructiveAdjectives).toSet();

      List<String> othersFeedbackComments =
          othersFeedbacks.where((e) => e.comments.isNotEmpty).map((feedback) => feedback.comments).toList();

      // Open Area
      List<String> openPositiveAdjectives = selfPositiveAdjectives.where((adj) => otherPositiveAdjectives.contains(adj)).toList();
      List<String> openConstructiveAdjectives =
          selfConstructiveAdjectives.where((adj) => otherConstructiveAdjectives.contains(adj)).toList();

      // Blind Area
      List<String> blindPositiveAdjectives =
          otherPositiveAdjectives.where((adj) => !selfPositiveAdjectives.contains(adj)).toList();
      List<String> blindConstructiveAdjectives =
          otherConstructiveAdjectives.where((adj) => !selfConstructiveAdjectives.contains(adj)).toList();

      // Hidden Area
      List<String> hiddenPositiveAdjectives =
          selfPositiveAdjectives.where((adj) => !otherPositiveAdjectives.contains(adj)).toList();
      List<String> hiddenConstructiveAdjectives =
          selfConstructiveAdjectives.where((adj) => !otherConstructiveAdjectives.contains(adj)).toList();

      // Sort all lists alphabetically

      return {
        'selfFeedback': {
          'positiveAdjectives': selfPositiveAdjectives.toList(),
          'constructiveAdjectives': selfConstructiveAdjectives.toList(),
        },
        'othersFeedback': {
          'count': othersFeedbacks.length,
          'positiveAdjectives': otherPositiveAdjectives.toList(),
          'constructiveAdjectives': otherConstructiveAdjectives.toList(),
          'comments': othersFeedbackComments.toList(),
        },
        'openArea': {'positiveAdjectives': openPositiveAdjectives, 'constructiveAdjectives': openConstructiveAdjectives},
        'blindArea': {'positiveAdjectives': blindPositiveAdjectives, 'constructiveAdjectives': blindConstructiveAdjectives},
        'hiddenArea': {'positiveAdjectives': hiddenPositiveAdjectives, 'constructiveAdjectives': hiddenConstructiveAdjectives},
      };
    } catch (e) {
      return {
        'selfFeedback': {'positiveAdjectives': [], 'constructiveAdjectives': []},
        'othersFeedback': {'positiveAdjectives': [], 'constructiveAdjectives': [], 'comments': []},
        'openArea': {'positiveAdjectives': [], 'constructiveAdjectives': []},
        'blindArea': {'positiveAdjectives': [], 'constructiveAdjectives': []},
        'hiddenArea': {'positiveAdjectives': [], 'constructiveAdjectives': []},
      };
    }
  }

  Future<Map<String, dynamic>> stats({required List<String> sessionIdList}) async {
    List<SessionFeedbacks> sessionFeedbacksList = [];
    for (var sessionid in sessionIdList) {
      var sessionFeedbacks = await getSessionFeedbacks(sessionId: sessionid);
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
