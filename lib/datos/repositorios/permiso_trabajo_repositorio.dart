import 'package:sqflite/sqflite.dart';
import '../../modelos/permiso_trabajo.dart';
import '../base_datos.dart';

// ============================================================================
// REPOSITORIO: PERMISOS DE TRABAJO (PRINCIPIO DE RESPONSABILIDAD ÚNICA)
// ============================================================================

class PermisoTrabajoRepositorio {
  final BaseDatos _baseDatos;

  PermisoTrabajoRepositorio({BaseDatos? baseDatos})
      : _baseDatos = baseDatos ?? BaseDatos.instancia;

  Future<Database> get _db async => await _baseDatos.baseDatos;

  Future<List<PermisoTrabajo>> obtenerTodos() async {
    final db = await _db;
    final resultados = await db.query('permisos_trabajo', orderBy: 'id DESC');
    return resultados.map((e) => PermisoTrabajo.fromMap(e)).toList();
  }

  Future<PermisoTrabajo?> obtenerPorId(int id) async {
    final db = await _db;
    final resultados = await db.query(
      'permisos_trabajo',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (resultados.isEmpty) return null;
    return PermisoTrabajo.fromMap(resultados.first);
  }

  Future<List<PermisoTrabajo>> buscar(String criterio) async {
    final db = await _db;
    final filtro = '%${criterio.trim()}%';
    final resultados = await db.query(
      'permisos_trabajo',
      where: 'codigo LIKE ? OR planta_zona LIKE ? OR responsable LIKE ? OR tipo_trabajo LIKE ?',
      whereArgs: [filtro, filtro, filtro, filtro],
      orderBy: 'id DESC',
    );
    return resultados.map((e) => PermisoTrabajo.fromMap(e)).toList();
  }

  Future<int> crear(PermisoTrabajo permiso) async {
    final db = await _db;
    return await db.insert(
      'permisos_trabajo',
      permiso.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> actualizar(PermisoTrabajo permiso) async {
    if (permiso.id == null) return 0;
    final db = await _db;
    return await db.update(
      'permisos_trabajo',
      permiso.toMap(),
      where: 'id = ?',
      whereArgs: [permiso.id],
    );
  }

  Future<int> cambiarEstado(int id, String nuevoEstado) async {
    final db = await _db;
    return await db.update(
      'permisos_trabajo',
      {'estado': nuevoEstado},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> eliminar(int id) async {
    final db = await _db;
    return await db.delete(
      'permisos_trabajo',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> contarTotal() async {
    final db = await _db;
    final resultado = await db.rawQuery('SELECT COUNT(*) FROM permisos_trabajo');
    return Sqflite.firstIntValue(resultado) ?? 0;
  }
}
