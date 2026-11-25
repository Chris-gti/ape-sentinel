import 'package:sqflite/sqflite.dart';
import '../../modelos/planta_zona.dart';
import '../base_datos.dart';

// ============================================================================
// REPOSITORIO: PLANTA / ZONA (PRINCIPIO DE RESPONSABILIDAD ÚNICA)
// ============================================================================

class PlantaZonaRepositorio {
  final BaseDatos _baseDatos;

  PlantaZonaRepositorio({BaseDatos? baseDatos})
      : _baseDatos = baseDatos ?? BaseDatos.instancia;

  Future<Database> get _db async => await _baseDatos.baseDatos;

  Future<List<PlantaZona>> obtenerTodas() async {
    final db = await _db;
    final resultados = await db.query('plantas_zonas', orderBy: 'id DESC');
    return resultados.map((e) => PlantaZona.fromMap(e)).toList();
  }

  Future<PlantaZona?> obtenerPorId(int id) async {
    final db = await _db;
    final resultados = await db.query(
      'plantas_zonas',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (resultados.isEmpty) return null;
    return PlantaZona.fromMap(resultados.first);
  }

  Future<List<PlantaZona>> buscar(String criterio) async {
    final db = await _db;
    final filtro = '%${criterio.trim()}%';
    final resultados = await db.query(
      'plantas_zonas',
      where: 'nombre LIKE ? OR tipo LIKE ? OR nivel LIKE ?',
      whereArgs: [filtro, filtro, filtro],
      orderBy: 'id DESC',
    );
    return resultados.map((e) => PlantaZona.fromMap(e)).toList();
  }

  Future<int> crear(PlantaZona plantaZona) async {
    final db = await _db;
    return await db.insert(
      'plantas_zonas',
      plantaZona.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> actualizar(PlantaZona plantaZona) async {
    if (plantaZona.id == null) return 0;
    final db = await _db;
    return await db.update(
      'plantas_zonas',
      plantaZona.toMap(),
      where: 'id = ?',
      whereArgs: [plantaZona.id],
    );
  }

  Future<int> cambiarEstado(int id, String nuevoEstado) async {
    final db = await _db;
    return await db.update(
      'plantas_zonas',
      {'estado': nuevoEstado},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> eliminar(int id) async {
    final db = await _db;
    return await db.delete(
      'plantas_zonas',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> contarTotal() async {
    final db = await _db;
    final resultado = await db.rawQuery('SELECT COUNT(*) FROM plantas_zonas');
    return Sqflite.firstIntValue(resultado) ?? 0;
  }
}
