import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// ============================================================================
// GESTOR DE BASE DE DATOS SQLITE (PATRÓN SINGLETON - INICIO LIMPIO DESDE 0)
// ============================================================================

class BaseDatos {
  static final BaseDatos instancia = BaseDatos._interno();
  static Database? _baseDatos;

  BaseDatos._interno();

  Future<Database> get baseDatos async {
    if (_baseDatos != null) return _baseDatos!;
    _baseDatos = await _inicializarBaseDatos();
    return _baseDatos!;
  }

  Future<Database> _inicializarBaseDatos() async {
    // Soporte para entornos de escritorio (Windows / Linux)
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final rutaBasesDatos = await getDatabasesPath();
    final rutaCompleta = p.join(rutaBasesDatos, 'ape_sentinel.db');

    return await openDatabase(
      rutaCompleta,
      version: 2,
      onCreate: _crearTablas,
      onUpgrade: _actualizarBaseDatos,
    );
  }

  Future<void> _crearTablas(Database db, int version) async {
    // 1. Tabla Usuarios
    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ficha TEXT UNIQUE NOT NULL,
        contrasena TEXT NOT NULL,
        nombre TEXT NOT NULL,
        rol TEXT NOT NULL,
        activo INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // 2. Tabla Personal
    await db.execute('''
      CREATE TABLE personal (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        ficha TEXT UNIQUE NOT NULL,
        area TEXT NOT NULL,
        turno TEXT NOT NULL,
        nivel TEXT NOT NULL,
        activo INTEGER NOT NULL DEFAULT 1,
        fecha_alta TEXT NOT NULL,
        ultima_actualizacion TEXT NOT NULL
      )
    ''');

    // 3. Tabla Plantas / Zonas
    await db.execute('''
      CREATE TABLE plantas_zonas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        tipo TEXT NOT NULL,
        nivel TEXT NOT NULL,
        estado TEXT NOT NULL,
        descripcion TEXT,
        capacidad_maxima INTEGER NOT NULL
      )
    ''');

    // 4. Tabla Permisos de Trabajo
    await db.execute('''
      CREATE TABLE permisos_trabajo (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        codigo TEXT UNIQUE NOT NULL,
        planta_zona TEXT NOT NULL,
        tipo_trabajo TEXT NOT NULL,
        nivel_seguridad TEXT NOT NULL,
        estado TEXT NOT NULL,
        descripcion TEXT,
        responsable TEXT NOT NULL,
        cantidad_maxima INTEGER NOT NULL
      )
    ''');

    // 5. Tabla Dispositivos de Acceso
    await db.execute('''
      CREATE TABLE dispositivos_acceso (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        marca TEXT NOT NULL,
        tipo TEXT NOT NULL,
        ubicacion TEXT NOT NULL,
        estado TEXT NOT NULL,
        serie TEXT NOT NULL,
        firmware TEXT NOT NULL,
        en_linea INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // 6. Tabla Métodos de Acceso
    await db.execute('''
      CREATE TABLE metodos_acceso (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        tipo TEXT NOT NULL,
        descripcion TEXT,
        estado TEXT NOT NULL,
        activo INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // 7. Tabla Eventos de Bitácora
    await db.execute('''
      CREATE TABLE eventos_bitacora (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fecha_hora TEXT NOT NULL,
        persona TEXT NOT NULL,
        tipo TEXT NOT NULL,
        zona TEXT NOT NULL
      )
    ''');
    // Sin datos semilla (seed): La aplicación inicia 100% limpia desde 0
  }

  Future<void> _actualizarBaseDatos(Database db, int versionAnterior, int versionNueva) async {
    // Al pasar de v1 (con demo seed) a v2 (limpio), se purgan todas las tablas
    if (versionAnterior < 2) {
      await _eliminarTablas(db);
      await _crearTablas(db, versionNueva);
    }
  }

  Future<void> _eliminarTablas(Database db) async {
    final tablas = [
      'eventos_bitacora',
      'metodos_acceso',
      'dispositivos_acceso',
      'permisos_trabajo',
      'plantas_zonas',
      'personal',
      'usuarios',
    ];
    for (final tabla in tablas) {
      await db.execute('DROP TABLE IF EXISTS $tabla');
    }
  }

  /// Permite reiniciar la base de datos limpiando todas las tablas
  Future<void> reiniciarBaseDatos() async {
    final db = await baseDatos;
    await _eliminarTablas(db);
    await _crearTablas(db, 2);
  }

  Future<void> cerrar() async {
    final db = _baseDatos;
    if (db != null) {
      await db.close();
      _baseDatos = null;
    }
  }
}
