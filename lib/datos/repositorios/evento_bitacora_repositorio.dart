import 'package:sqflite/sqflite.dart';
import '../../modelos/evento_bitacora.dart';
import '../base_datos.dart';

// ============================================================================
// REPOSITORIO: EVENTOS DE BITÁCORA (PRINCIPIO DE RESPONSABILIDAD ÚNICA)
// ============================================================================

class EventoBitacoraRepositorio {
  final BaseDatos _baseDatos;

  EventoBitacoraRepositorio({BaseDatos? baseDatos})
      : _baseDatos = baseDatos ?? BaseDatos.instancia;

  Future<Database> get _db async => await _baseDatos.baseDatos;

  Future<List<EventoBitacora>> obtenerTodos({String? filtroTipo}) async {
    final db = await _db;
    List<Map<String, dynamic>> resultados;

    if (filtroTipo != null && filtroTipo.isNotEmpty && filtroTipo != 'TODOS') {
      resultados = await db.query(
        'eventos_bitacora',
        where: 'tipo = ?',
        whereArgs: [filtroTipo],
        orderBy: 'id DESC',
      );
    } else {
      resultados = await db.query(
        'eventos_bitacora',
        orderBy: 'id DESC',
      );
    }

    return resultados.map((e) => EventoBitacora.fromMap(e)).toList();
  }

  Future<List<EventoBitacora>> obtenerRecientes(int limite) async {
    final db = await _db;
    final resultados = await db.query(
      'eventos_bitacora',
      orderBy: 'id DESC',
      limit: limite,
    );
    return resultados.map((e) => EventoBitacora.fromMap(e)).toList();
  }

  Future<int> contarPorTipo(String tipo) async {
    final db = await _db;
    final resultado = await db.rawQuery(
      'SELECT COUNT(*) FROM eventos_bitacora WHERE tipo = ?',
      [tipo],
    );
    return Sqflite.firstIntValue(resultado) ?? 0;
  }

  Future<int> crear(EventoBitacora evento) async {
    final db = await _db;
    return await db.insert(
      'eventos_bitacora',
      evento.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> eliminar(int id) async {
    final db = await _db;
    return await db.delete(
      'eventos_bitacora',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
