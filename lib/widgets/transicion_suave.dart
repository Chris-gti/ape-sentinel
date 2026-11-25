import 'package:flutter/material.dart';

// ============================================================================
// TRANSICIÓN DE PÁGINA SUAVE (POO Y EXPERIENCIA VISUAL)
// ============================================================================

class TransicionSuave<T> extends PageRouteBuilder<T> {
  final Widget pantalla;

  TransicionSuave({Widget? pantalla, Widget? child})
      : pantalla = pantalla ?? child!,
        super(
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 250),
          pageBuilder: (_, _, _) => pantalla ?? child!,
          transitionsBuilder: (_, animation, _, hijo) {
            final curva = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            );
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.06, 0),
                end: Offset.zero,
              ).animate(curva),
              child: FadeTransition(
                opacity: curva,
                child: hijo,
              ),
            );
          },
        );
}
