import 'package:sqflite/sqflite.dart';
import '../../modelos/personal.dart';
import '../base_datos.dart';

// ============================================================================
// REPOSITORIO: PERSONAL (PRINCIPIO DE RESPONSABILIDAD ÚNICA)
// ============================================================================

class PersonalRepositorio {
  final BaseDatos _baseDatos;

  PersonalRepositorio({BaseDatos? baseDatos})
      : _baseDatos = baseDatos ?? BaseDatos.instancia;

  Future<Database> get _db async => await _baseDatos.baseDatos;

  Future<List<Personal>> obtenerTodos() async {
    final db = await _db;
    final resultados = await db.query('personal', orderBy: 'id DESC');
    return resultados.map((e) => Personal.fromMap(e)).toList();
  }

  Future<Personal?> obtenerPorId(int id) async {
    final db = await _db;
    final resultados = await db.query(
      'personal',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (resultados.isEmpty) return null;
    return Personal.fromMap(resultados.first);
  }

  Future<List<Personal>> buscar(String criterio) async {
    final db = await _db;
    final filtro = '%${criterio.trim()}%';
    final resultados = await db.query(
      'personal',
      where: 'nombre LIKE ? OR ficha LIKE ? OR area LIKE ?',
      whereArgs: [filtro, filtro, filtro],
      orderBy: 'id DESC',
    );
    return resultados.map((e) => Personal.fromMap(e)).toList();
  }

  Future<int> crear(Personal personal) async {
    final db = await _db;
    return await db.insert(
      'personal',
      personal.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> actualizar(Personal personal) async {
    if (personal.id == null) return 0;
    final db = await _db;
    return await db.update(
      'personal',
      personal.toMap(),
      where: 'id = ?',
      whereArgs: [personal.id],
    );
  }

  Future<int> cambiarEstado(int id, bool activo) async {
    final db = await _db;
    return await db.update(
      'personal',
      {
        'activo': activo ? 1 : 0,
        'ultima_actualizacion': 'Hoy',
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> eliminar(int id) async {
    final db = await _db;
    return await db.delete(
      'personal',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> contarActivos() async {
    final db = await _db;
    final resultado = await db.rawQuery(
      'SELECT COUNT(*) as total FROM personal WHERE activo = 1',
    );
    if (resultado.isNotEmpty) {
      return Sqflite.firstIntValue(resultado) ?? 0;
    }
    return 0;
  }
}
