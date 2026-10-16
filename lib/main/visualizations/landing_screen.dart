// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:teb_janelajohari/public_area/johari_screen/jorarri_screen.dart';
import 'package:teb_janelajohari/public_area/session_feedbacks/session_feedbacks.dart';
import 'package:teb_janelajohari/main/visualizations/error_screen.dart';
import 'package:teb_janelajohari/public_area/wellcome_screen/wellcome_screen.dart';
import 'package:teb_janelajohari/public_area/session/session_controller.dart';
import 'package:teb_janelajohari/public_area/session_feedbacks/visualization/feedback_screen.dart';
import 'package:teb_janelajohari/local_data_controller.dart';
import 'package:teb_janelajohari/routes.dart';
import 'package:teb_janelajohari/theme/app_theme.dart';
import 'package:teb_janelajohari/web_handoff.dart';
import 'package:teb_package/util/teb_return.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  var _initializing = true;
  var _ignoreQueryParameters = false;

  // Pedidos vindos da landing estática (ver WebHandoff).
  var _wantsCreateSession = false;
  Future<TebReturn>? _accessCodeLookup;
  final _sessionController = SessionController();

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;
      _ignoreQueryParameters = arguments['ignoreQueryParameters'] ?? false;

      if (!_ignoreQueryParameters) {
        _wantsCreateSession = WebHandoff.wantsCreateSession;
        final accessCode = WebHandoff.takeAccessCode();
        if (accessCode.isNotEmpty) {
          _accessCodeLookup = _sessionController.getCurrentSessionByAccessCode(accessCode: accessCode);
        }
        if (_wantsCreateSession || accessCode.isNotEmpty) WebHandoff.clearQuery();
      }
      _initializing = false;
    }

    if (_wantsCreateSession) {
      _wantsCreateSession = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context)
            .pushNamed(Routes.sessionForm, arguments: {'mobile': MediaQuery.of(context).size.width < 900})
            // Ao voltar do formulário, reavalia: sem sessão, volta para a landing.
            .then((_) => mounted ? setState(() {}) : null);
      });
      return _loading();
    }

    if (_accessCodeLookup != null) return _accessCodeScreen();

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
            return _loading();
            // em caso de erro
          } else {
            if (snapshot.error != null) {
              localDataController.clearSessionData();
              return ErrorScreen(errorMessage: snapshot.error.toString());
              // ao final do processo
            } else {
              if (localDataController.localSession.id.isEmpty) return _welcome();

              return LayoutBuilder(
                builder: (context, constraints) {
                  return JohariScreen(session: localDataController.localSession, mobile: constraints.maxWidth <= 1000);
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
            return _loading();
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
                      sessionFeedbackId: sessionController.givenFeedbackCodeList[sessionFeedbackCode],
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

  Widget _loading() => const Scaffold(backgroundColor: AppColors.cream, body: Center(child: CircularProgressIndicator()));

  /// Sem sessão aberta. No deploy híbrido a tela inicial é a landing
  /// estática; rodando na raiz (desenvolvimento) usa a de boas-vindas do app.
  Widget _welcome() {
    if (!WebHandoff.underApp) return const WellcomeScreen();
    // Só redireciona se esta tela estiver visível (não sob o formulário).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && (ModalRoute.of(context)?.isCurrent ?? true)) WebHandoff.goToLanding();
    });
    return _loading();
  }

  Widget _accessCodeScreen() {
    return FutureBuilder<TebReturn>(
      future: _accessCodeLookup,
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return _loading();
        if (snapshot.error != null) return ErrorScreen(errorMessage: snapshot.error.toString());

        final result = snapshot.data!;
        if (result.returnType == TebReturnType.error) return ErrorScreen(errorMessage: result.message);

        // getCurrentSessionByAccessCode já grava a sessão localmente.
        return LayoutBuilder(
          builder: (context, constraints) {
            return JohariScreen(session: _sessionController.currentSession, mobile: constraints.maxWidth <= 1000);
          },
        );
      },
    );
  }
}
