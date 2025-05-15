// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:teb_janelajohari/public_area/johari_screen/jorarri_screen.dart';
import 'package:teb_janelajohari/public_area/session_feedbacks/session_feedbacks.dart';
import 'package:teb_janelajohari/main/visualizations/error_screen.dart';
import 'package:teb_janelajohari/public_area/wellcome_screen/wellcome_screen.dart';
import 'package:teb_janelajohari/public_area/session/session_controller.dart';
import 'package:teb_janelajohari/public_area/session_feedbacks/visualization/feedback_screen.dart';
import 'package:teb_janelajohari/local_data_controller.dart';
import 'package:teb_janelajohari/public_area/wellcome_screen/wellcome_screen_mobile.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  var _initializing = true;
  var _ignoreQueryParameters = false;

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;
      _ignoreQueryParameters = arguments['ignoreQueryParameters'] ?? false;
      _initializing = false;
    }

    var sessionFeedbackCode = '';
    var hasQueryParameters = false;

    if (!_ignoreQueryParameters) {
      final uri = Uri.base;
      if (uri.queryParameters.containsKey('session_feedback_code')) {
        sessionFeedbackCode = uri.queryParameters['session_feedback_code'] ?? '';
        hasQueryParameters = true;
      }
    }

    if (_ignoreQueryParameters || !hasQueryParameters) {
      var localDataController = LocalDataController();
      return FutureBuilder(
        future: localDataController.chechLocalData(),
        builder: (ctx, snapshot) {
          // enquanto está carregando
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
            // em caso de erro
          } else {
            if (snapshot.error != null) {
              localDataController.clearSessionData();
              return ErrorScreen(errorMessage: snapshot.error.toString());
              // ao final do processo
            } else {
              // irá avaliar se o usuário possui login ou não

              return LayoutBuilder(
                builder: (context, constraints) {
                  var mobile = constraints.maxWidth <= 1000;
                  return localDataController.localSession.id.isEmpty
                      ? mobile
                          ? const WellcomeScreenMobile()
                          : const WellcomeScreen()
                      : JohariScreen(session: localDataController.localSession, mobile: mobile);
                },
              );
            }
          }
        },
      );
    } else {
      var sessionController = SessionController();
      return FutureBuilder(
        future: sessionController.getCurrentSessionByFeedbackCode(feedbackCode: sessionFeedbackCode),
        builder: (ctx, snapshot) {
          // enquanto está carregando
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
            // em caso de erro
          } else {
            if (snapshot.error != null) {
              return ErrorScreen(errorMessage: snapshot.error.toString());
              // ao final do processo
            } else {
              // irá avaliar se o usuário possui login ou não
              if (sessionController.currentSession.id.isEmpty) {
                return const ErrorScreen(errorMessage: 'Sessão não encontrada.');
              } else {
                return LayoutBuilder(
                  builder: (context, constraints) {

                    return FeedbackScreen(
                      session: sessionController.currentSession,
                      feedbackType: FeedbackType.others,
                      mobile: constraints.maxWidth <= 1000,
                    );
                  },
                );
              }
            }
          }
        },
      );
    }
  }
}
