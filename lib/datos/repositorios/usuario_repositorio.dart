import 'package:sqflite/sqflite.dart';
import '../../modelos/usuario.dart';
import '../base_datos.dart';

// ============================================================================
// REPOSITORIO: USUARIO (PRINCIPIO DE RESPONSABILIDAD ÚNICA)
// ============================================================================

class UsuarioRepositorio {
  final BaseDatos _baseDatos;

  UsuarioRepositorio({BaseDatos? baseDatos})
      : _baseDatos = baseDatos ?? BaseDatos.instancia;

  Future<Database> get _db async => await _baseDatos.baseDatos;

  Future<Usuario?> autenticar(String ficha, String contrasena) async {
    final db = await _db;
    final resultados = await db.query(
      'usuarios',
      where: 'ficha = ? AND contrasena = ? AND activo = 1',
      whereArgs: [ficha.trim(), contrasena.trim()],
      limit: 1,
    );

    if (resultados.isEmpty) return null;
    return Usuario.fromMap(resultados.first);
  }

  Future<Usuario?> obtenerPorFicha(String ficha) async {
    final db = await _db;
    final resultados = await db.query(
      'usuarios',
      where: 'ficha = ?',
      whereArgs: [ficha.trim()],
      limit: 1,
    );

    if (resultados.isEmpty) return null;
    return Usuario.fromMap(resultados.first);
  }

  Future<List<Usuario>> obtenerTodos() async {
    final db = await _db;
    final resultados = await db.query('usuarios', orderBy: 'id ASC');
    return resultados.map((e) => Usuario.fromMap(e)).toList();
  }

  Future<int> crear(Usuario usuario) async {
    final db = await _db;
    return await db.insert(
      'usuarios',
      usuario.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> actualizar(Usuario usuario) async {
    if (usuario.id == null) return 0;
    final db = await _db;
    return await db.update(
      'usuarios',
      usuario.toMap(),
      where: 'id = ?',
      whereArgs: [usuario.id],
    );
  }

  Future<int> eliminar(int id) async {
    final db = await _db;
    return await db.delete(
      'usuarios',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> contarUsuarios() async {
    final db = await _db;
    final resultado = await db.rawQuery('SELECT COUNT(*) FROM usuarios');
    return Sqflite.firstIntValue(resultado) ?? 0;
  }

  Future<bool> existenUsuarios() async {
    final total = await contarUsuarios();
    return total > 0;
  }
}
