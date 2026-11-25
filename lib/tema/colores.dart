import 'package:flutter/material.dart';

// ============================================================================
// CONSTANTES DE COLORES Y TEMA - APESENTINEL
// ============================================================================

const Color kColorNaranja = Color(0xFFFF5500);
const Color kColorFondo = Color(0xFF0A0A0A);
const Color kColorTarjeta = Color(0xFF141414);
const Color kColorBordeTarjeta = Color(0xFF222222);
const Color kColorVerde = Color(0xFF4CAF50);
const Color kColorRojo = Colors.redAccent;
const Color kColorNaranjaClaro = Colors.orangeAccent;
const Color kColorSecundario = Color(0xFFFF7733);
const Color kColorBarraNavegacion = Color(0xFF0F0F0F);

ThemeData construirTemaApeSentinel() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: kColorFondo,
    primaryColor: kColorNaranja,
    colorScheme: const ColorScheme.dark(
      primary: kColorNaranja,
      secondary: kColorSecundario,
      surface: kColorTarjeta,
    ),
    fontFamily: 'Roboto',
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
    ),
  );
}
