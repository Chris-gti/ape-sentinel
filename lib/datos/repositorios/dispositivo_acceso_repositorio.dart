import 'package:sqflite/sqflite.dart';
import '../../modelos/dispositivo_acceso.dart';
import '../base_datos.dart';

// ============================================================================
// REPOSITORIO: DISPOSITIVOS DE ACCESO (PRINCIPIO DE RESPONSABILIDAD ÚNICA)
// ============================================================================

class DispositivoAccesoRepositorio {
  final BaseDatos _baseDatos;

  DispositivoAccesoRepositorio({BaseDatos? baseDatos})
      : _baseDatos = baseDatos ?? BaseDatos.instancia;

  Future<Database> get _db async => await _baseDatos.baseDatos;

  Future<List<DispositivoAcceso>> obtenerTodos() async {
    final db = await _db;
    final resultados = await db.query('dispositivos_acceso', orderBy: 'id DESC');
    return resultados.map((e) => DispositivoAcceso.fromMap(e)).toList();
  }

  Future<DispositivoAcceso?> obtenerPorId(int id) async {
    final db = await _db;
    final resultados = await db.query(
      'dispositivos_acceso',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (resultados.isEmpty) return null;
    return DispositivoAcceso.fromMap(resultados.first);
  }

  Future<int> crear(DispositivoAcceso dispositivo) async {
    final db = await _db;
    return await db.insert(
      'dispositivos_acceso',
      dispositivo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> actualizar(DispositivoAcceso dispositivo) async {
    if (dispositivo.id == null) return 0;
    final db = await _db;
    return await db.update(
      'dispositivos_acceso',
      dispositivo.toMap(),
      where: 'id = ?',
      whereArgs: [dispositivo.id],
    );
  }

  Future<int> alternarConexion(int id, bool estadoActual) async {
    final db = await _db;
    return await db.update(
      'dispositivos_acceso',
      {'en_linea': estadoActual ? 0 : 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> cambiarEstado(int id, String nuevoEstado) async {
    final db = await _db;
    return await db.update(
      'dispositivos_acceso',
      {'estado': nuevoEstado},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> eliminar(int id) async {
    final db = await _db;
    return await db.delete(
      'dispositivos_acceso',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
