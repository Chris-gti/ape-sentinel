import 'package:sqflite/sqflite.dart';
import '../../modelos/metodo_acceso.dart';
import '../base_datos.dart';

// ============================================================================
// REPOSITORIO: MÉTODOS DE ACCESO (PRINCIPIO DE RESPONSABILIDAD ÚNICA)
// ============================================================================

class MetodoAccesoRepositorio {
  final BaseDatos _baseDatos;

  MetodoAccesoRepositorio({BaseDatos? baseDatos})
      : _baseDatos = baseDatos ?? BaseDatos.instancia;

  Future<Database> get _db async => await _baseDatos.baseDatos;

  Future<List<MetodoAcceso>> obtenerTodos() async {
    final db = await _db;
    final resultados = await db.query('metodos_acceso', orderBy: 'id DESC');
    return resultados.map((e) => MetodoAcceso.fromMap(e)).toList();
  }

  Future<MetodoAcceso?> obtenerPorId(int id) async {
    final db = await _db;
    final resultados = await db.query(
      'metodos_acceso',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (resultados.isEmpty) return null;
    return MetodoAcceso.fromMap(resultados.first);
  }

  Future<int> crear(MetodoAcceso metodo) async {
    final db = await _db;
    return await db.insert(
      'metodos_acceso',
      metodo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> actualizar(MetodoAcceso metodo) async {
    if (metodo.id == null) return 0;
    final db = await _db;
    return await db.update(
      'metodos_acceso',
      metodo.toMap(),
      where: 'id = ?',
      whereArgs: [metodo.id],
    );
  }

  Future<int> cambiarEstado(int id, bool activo) async {
    final db = await _db;
    return await db.update(
      'metodos_acceso',
      {
        'activo': activo ? 1 : 0,
        'estado': activo ? 'Activo' : 'Inactivo',
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> eliminar(int id) async {
    final db = await _db;
    return await db.delete(
      'metodos_acceso',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
