// ============================================================================
// MODELO: PERSONAL (POO INMUTABLE)
// ============================================================================

class Personal {
  final int? id;
  final String nombre;
  final String ficha;
  final String area;
  final String turno;
  final String nivel;
  final bool activo;
  final String fechaAlta;
  final String ultimaActualizacion;

  const Personal({
    this.id,
    required this.nombre,
    required this.ficha,
    required this.area,
    required this.turno,
    this.nivel = 'Nivel 2',
    this.activo = true,
    this.fechaAlta = '',
    this.ultimaActualizacion = 'Hoy',
  });

  Personal copiarCon({
    int? id,
    String? nombre,
    String? ficha,
    String? area,
    String? turno,
    String? nivel,
    bool? activo,
    String? fechaAlta,
    String? ultimaActualizacion,
  }) {
    return Personal(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      ficha: ficha ?? this.ficha,
      area: area ?? this.area,
      turno: turno ?? this.turno,
      nivel: nivel ?? this.nivel,
      activo: activo ?? this.activo,
      fechaAlta: fechaAlta ?? this.fechaAlta,
      ultimaActualizacion: ultimaActualizacion ?? this.ultimaActualizacion,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nombre': nombre,
      'ficha': ficha,
      'area': area,
      'turno': turno,
      'nivel': nivel,
      'activo': activo ? 1 : 0,
      'fecha_alta': fechaAlta,
      'ultima_actualizacion': ultimaActualizacion,
    };
  }

  factory Personal.fromMap(Map<String, dynamic> mapa) {
    return Personal(
      id: mapa['id'] as int?,
      nombre: mapa['nombre'] as String? ?? '',
      ficha: mapa['ficha'] as String? ?? '',
      area: mapa['area'] as String? ?? '',
      turno: mapa['turno'] as String? ?? 'Matutino',
      nivel: mapa['nivel'] as String? ?? 'Nivel 2',
      activo: (mapa['activo'] as int? ?? 1) == 1,
      fechaAlta: mapa['fecha_alta'] as String? ?? '',
      ultimaActualizacion: mapa['ultima_actualizacion'] as String? ?? 'Hoy',
    );
  }

  @override
  String toString() => 'Personal(id: $id, ficha: $ficha, nombre: $nombre, area: $area, activo: $activo)';
}
