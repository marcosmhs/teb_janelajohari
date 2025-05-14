// ignore: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:teb_janelajohari/admin_area/admin_area_screen.dart';
import 'package:teb_janelajohari/admin_area/site_text/site_text_form.dart';
import 'package:teb_janelajohari/admin_area/user/login_screen.dart';
import 'package:teb_janelajohari/admin_area/user/user_form.dart';
import 'package:teb_janelajohari/public_area/johari_screen/jorarri_screen.dart';
import 'package:teb_janelajohari/public_area/session_feedbacks/visualization/feedback_screen.dart';
import 'package:teb_janelajohari/main/visualizations/error_screen.dart';
import 'package:teb_janelajohari/main/visualizations/landing_screen.dart';
import 'package:teb_janelajohari/public_area/session/visualizations/session_form.dart';
import 'package:teb_janelajohari/routes.dart';
import 'package:teb_janelajohari/screen_not_found.dart';
import 'package:teb_package/theme/teb_theme_controller.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  var tebThemeController = TebThemeController(
    lightThemeAssetPath: 'assets/theme.json',
    useMaterial3: false,
    useDebugLog: true,
    fireStoreInstance: FirebaseFirestore.instance,
  );

  await tebThemeController.loadThemeData;

  runApp(JanelaJohari(themeData: tebThemeController.lightThemeData));
}

class JanelaJohari extends StatefulWidget {
  final ThemeData themeData;
  const JanelaJohari({super.key, required this.themeData});

  @override
  State<JanelaJohari> createState() => _Home();
}

class _Home extends State<JanelaJohari> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', ''), Locale('pt-br', '')],
      title: 'Janela de Johari',
      routes: {
        Routes.landingScreen: (ctx) => const LandingScreen(),
        Routes.sessionForm: (ctx) => const SessionForm(),
        Routes.johariScreen: (ctx) => const JohariScreen(),
        Routes.feedbackScreen: (ctx) => const FeedbackScreen(),
        Routes.errorScreen: (ctx) => const ErrorScreen(),
        Routes.siteTextForm: (ctx) => const SiteTextForm(),
        Routes.adminAreaScreen: (ctx) => const AdminAreaScreen(),
        Routes.loginScreen: (ctx) => const LoginScreen(),
        Routes.userForm: (ctx) => const UserForm(),
      },
      theme: widget.themeData,
      initialRoute: Routes.landingScreen,
      // Executado quando uma tela não é encontrada
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (_) {
            return ScreenNotFound(settings.name.toString());
          },
        );
      },
    );
  }
}
