import 'package:flutter/material.dart';

// ============================================================================
// BARRA SUPERIOR PERSONALIZADA (AppBar)
// ============================================================================

class BarraSuperior extends StatelessWidget implements PreferredSizeWidget {
  final String titulo;
  final String? subtitulo;
  final bool mostrarBotonAtras;
  final List<Widget>? acciones;
  final VoidCallback? alPresionarAtras;

  const BarraSuperior({
    super.key,
    required this.titulo,
    this.subtitulo,
    this.mostrarBotonAtras = false,
    this.acciones,
    this.alPresionarAtras,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: mostrarBotonAtras
          ? IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                size: 16,
                color: Colors.white70,
              ),
              onPressed: alPresionarAtras ?? () => Navigator.pop(context),
            )
          : null,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 12.5,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          if (subtitulo case final subtitulo?)
            Text(
              subtitulo,
              style: const TextStyle(
                fontSize: 9.5,
                color: Colors.white38,
              ),
            ),
        ],
      ),
      centerTitle: true,
      actions: acciones,
    );
  }
}
