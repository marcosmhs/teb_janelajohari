import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tokens de cor do redesign da Janela de Johari.
///
/// A paleta é construída sobre os quatro quadrantes: teal (Aberto / cor
/// primária), azul (Cego), âmbar (Oculto / ações) e roxo (Desconhecido),
/// sobre um fundo creme com cartões brancos.
class AppColors {
  // Base / neutros
  static const Color cream = Color(0xFFFAF8F4); // fundo
  static const Color surface = Color(0xFFFFFFFF); // cartões
  static const Color surfaceAlt = Color(0xFFF4F1EB); // blocos neutros
  static const Color border = Color(0xFFE4E0D8);
  static const Color chipBorder = Color(0xFFD9D4CA);
  static const Color inputBorder = Color(0xFFCFC9BE);

  // Texto
  static const Color ink = Color(0xFF1C2733); // texto principal / painel escuro
  static const Color inkSoft = Color(0xFF48535F); // secundário
  static const Color inkMuted = Color(0xFF5A6470); // terciário

  // Teal — Aberto / primária
  static const Color teal = Color(0xFF1F7A72);
  static const Color tealDark = Color(0xFF165A54);
  static const Color tealSoft = Color(0xFFE3F1EF);
  static const Color tealInk = Color(0xFF2C4A47);
  static const Color tealOnDark = Color(0xFF9FD3CC);

  // Azul — Cego
  static const Color blue = Color(0xFF2F5E9E);
  static const Color blueDark = Color(0xFF244A7D);
  static const Color blueSoft = Color(0xFFE4ECF6);

  // Âmbar — Oculto / ações secundárias
  static const Color amber = Color(0xFFA65A16);
  static const Color amberDark = Color(0xFF874810);
  static const Color amberSoft = Color(0xFFF8EBDD);
  static const Color gold = Color(0xFFF0B067); // CTA de destaque

  // Roxo — Desconhecido
  static const Color purple = Color(0xFF6B4E9B);
  static const Color purpleDark = Color(0xFF563D80);
  static const Color purpleSoft = Color(0xFFEEE8F5);

  // Painel escuro (IA, podcast, "por que usar")
  static const Color panel = Color(0xFF1C2733);
  static const Color panelSoft = Color(0xFF26333F);
  static const Color onPanel = Color(0xFFC9D1D9);

  static const Color error = Color(0xFFB3261E);
}

/// Raios de canto padronizados.
class AppRadius {
  static const double card = 24;
  static const double cardLarge = 28;
  static const double input = 14;
  static const double pill = 999;
}

class AppTheme {
  /// Fonte de títulos/display (grotesca).
  static TextStyle display(TextStyle? base) =>
      GoogleFonts.bricolageGrotesque(textStyle: base, fontWeight: FontWeight.w700);

  /// Fonte de corpo.
  static TextStyle body(TextStyle? base) => GoogleFonts.figtree(textStyle: base);

  static ThemeData get light {
    const colorScheme = ColorScheme.light(
      primary: AppColors.teal,
      onPrimary: Colors.white,
      secondary: AppColors.amber,
      onSecondary: Colors.white,
      tertiary: AppColors.gold,
      onTertiary: AppColors.ink,
      surface: AppColors.surface,
      onSurface: AppColors.ink,
      error: AppColors.error,
      onError: Colors.white,
    );

    final baseText = ThemeData.light().textTheme;
    final figtree = GoogleFonts.figtreeTextTheme(baseText).apply(
      bodyColor: AppColors.ink,
      displayColor: AppColors.ink,
    );

    // Títulos com Bricolage Grotesque.
    final textTheme = figtree.copyWith(
      displayLarge: AppTheme.display(figtree.displayLarge),
      displayMedium: AppTheme.display(figtree.displayMedium),
      displaySmall: AppTheme.display(figtree.displaySmall),
      headlineLarge: AppTheme.display(figtree.headlineLarge),
      headlineMedium: AppTheme.display(figtree.headlineMedium),
      headlineSmall: AppTheme.display(figtree.headlineSmall),
      titleLarge: AppTheme.display(figtree.titleLarge),
    );

    return ThemeData(
      useMaterial3: false,
      scaffoldBackgroundColor: AppColors.cream,
      canvasColor: AppColors.surface,
      primaryColor: AppColors.teal,
      colorScheme: colorScheme,
      textTheme: textTheme,
      fontFamily: GoogleFonts.figtree().fontFamily,
      cardColor: AppColors.surface,
      dividerColor: AppColors.border,
      iconTheme: const IconThemeData(color: AppColors.ink),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.cream,
        foregroundColor: AppColors.ink,
        elevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.teal,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.figtree(fontWeight: FontWeight.w700, fontSize: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          side: const BorderSide(color: AppColors.inputBorder, width: 1.5),
          textStyle: GoogleFonts.figtree(fontWeight: FontWeight.w700, fontSize: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.teal,
          textStyle: GoogleFonts.figtree(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(color: AppColors.inkMuted),
        labelStyle: const TextStyle(color: AppColors.inkSoft, fontWeight: FontWeight.w600),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.inputBorder, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.teal, width: 1.5),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.inputBorder, width: 1.5),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }
}
