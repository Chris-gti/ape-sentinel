import 'package:flutter/material.dart';
import 'datos/base_datos.dart';
import 'pantallas/login_pantalla.dart';
import 'tema/colores.dart';

// ============================================================================
// APESENTINEL - PUNTO DE ENTRADA PRINCIPAL
// ============================================================================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialización de la base de datos SQLite y precarga de tablas/seed
  await BaseDatos.instancia.baseDatos;

  runApp(const ApeSentinelApp());
}

class ApeSentinelApp extends StatelessWidget {
  const ApeSentinelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ApeSentinel',
      debugShowCheckedModeBanner: false,
      theme: construirTemaApeSentinel(),
      home: const LoginPantalla(),
    );
  }
}
