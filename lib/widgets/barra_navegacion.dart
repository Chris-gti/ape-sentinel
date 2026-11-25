import 'package:flutter/material.dart';
import '../tema/colores.dart';

// ============================================================================
// BARRA DE NAVEGACIÓN INFERIOR
// ============================================================================

class BarraNavegacion extends StatelessWidget {
  final int indiceActual;
  final ValueChanged<int> alSeleccionar;

  const BarraNavegacion({
    super.key,
    required this.indiceActual,
    required this.alSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: indiceActual,
      backgroundColor: kColorBarraNavegacion,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: kColorNaranja,
      unselectedItemColor: Colors.white38,
      selectedFontSize: 10,
      unselectedFontSize: 10,
      onTap: alSeleccionar,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_outline),
          label: 'Personas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list_alt_outlined),
          label: 'Bitácora',
        ),
      ],
    );
  }
}
