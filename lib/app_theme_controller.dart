import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:json_theme/json_theme.dart';
import 'package:teb_package/teb_package.dart';

/// Carrega temas a partir de arquivos JSON no formato do https://appainter.dev/.
///
/// Substitui o antigo `TebThemeController`, removido do teb_package a partir da
/// versão 0.2.x. Mantém o mesmo comportamento: lê o(s) asset(s) de tema e os
/// converte em [ThemeData] via `json_theme`.
class AppThemeController {
  final String? lightThemeAssetPath;
  final String? darkThemeAssetPath;
  final bool useMaterial3;
  final bool useDebugLog;
  final FirebaseFirestore? fireStoreInstance;

  ThemeData? _lightThemeData;
  ThemeData? _darkThemeData;

  ThemeData get lightThemeData => _lightThemeData ?? ThemeData.light(useMaterial3: useMaterial3);
  ThemeData get darkThemeData => _darkThemeData ?? ThemeData.dark(useMaterial3: useMaterial3);

  AppThemeController({
    this.lightThemeAssetPath,
    this.darkThemeAssetPath,
    this.useMaterial3 = true,
    this.useDebugLog = true,
    this.fireStoreInstance,
  });

  void _logError(String message) {
    if (useDebugLog && fireStoreInstance != null) {
      TebDebugLog(fireStoreInstance: fireStoreInstance!, group: 'AppThemeController', message: message);
    }
  }

  /// Lê os arquivos de tema informados na criação da classe e preenche
  /// [lightThemeData] / [darkThemeData].
  Future<TebReturn> get loadThemeData async {
    try {
      if ((lightThemeAssetPath ?? '').isNotEmpty) {
        final lightThemeStr = await rootBundle.loadString(lightThemeAssetPath!);
        final lightThemeJson = json.decode(lightThemeStr);
        _lightThemeData = ThemeDecoder.decodeThemeData(lightThemeJson, validate: true);
        if (_lightThemeData == null) {
          _lightThemeData = ThemeData.light(useMaterial3: useMaterial3);
          _logError('Erro ao ler o ${lightThemeAssetPath!}');
          return TebReturn.error('Erro ao ler o ${lightThemeAssetPath!}');
        }
      }

      if ((darkThemeAssetPath ?? '').isNotEmpty) {
        final darkThemeStr = await rootBundle.loadString(darkThemeAssetPath!);
        final darkThemeJson = json.decode(darkThemeStr);
        _darkThemeData = ThemeDecoder.decodeThemeData(darkThemeJson, validate: true);
        if (_darkThemeData == null) {
          _darkThemeData = ThemeData.dark(useMaterial3: useMaterial3);
          _logError('Erro ao ler o ${darkThemeAssetPath!}');
          return TebReturn.error('Erro ao ler o ${darkThemeAssetPath!}');
        }
      }

      return TebReturn.success;
    } catch (e) {
      _logError(e.toString());
      return TebReturn.error(e.toString());
    }
  }
}
