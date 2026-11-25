// ============================================================================
// MODELO: PLANTA / ZONA (POO INMUTABLE)
// ============================================================================

class PlantaZona {
  final int? id;
  final String nombre;
  final String tipo;
  final String nivel;
  final String estado;
  final String descripcion;
  final int capacidadMaxima;

  const PlantaZona({
    this.id,
    required this.nombre,
    required this.tipo,
    required this.nivel,
    this.estado = 'Activa',
    this.descripcion = '',
    required this.capacidadMaxima,
  });

  PlantaZona copiarCon({
    int? id,
    String? nombre,
    String? tipo,
    String? nivel,
    String? estado,
    String? descripcion,
    int? capacidadMaxima,
  }) {
    return PlantaZona(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      tipo: tipo ?? this.tipo,
      nivel: nivel ?? this.nivel,
      estado: estado ?? this.estado,
      descripcion: descripcion ?? this.descripcion,
      capacidadMaxima: capacidadMaxima ?? this.capacidadMaxima,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nombre': nombre,
      'tipo': tipo,
      'nivel': nivel,
      'estado': estado,
      'descripcion': descripcion,
      'capacidad_maxima': capacidadMaxima,
    };
  }

  factory PlantaZona.fromMap(Map<String, dynamic> mapa) {
    return PlantaZona(
      id: mapa['id'] as int?,
      nombre: mapa['nombre'] as String? ?? '',
      tipo: mapa['tipo'] as String? ?? 'Operativa',
      nivel: mapa['nivel'] as String? ?? 'Nivel 2',
      estado: mapa['estado'] as String? ?? 'Activa',
      descripcion: mapa['descripcion'] as String? ?? '',
      capacidadMaxima: mapa['capacidad_maxima'] as int? ?? 0,
    );
  }

  @override
  String toString() => 'PlantaZona(id: $id, nombre: $nombre, tipo: $tipo, nivel: $nivel, estado: $estado)';
}
