// ============================================================================
// MODELO: MÉTODO DE ACCESO (POO INMUTABLE)
// ============================================================================

class MetodoAcceso {
  final int? id;
  final String nombre;
  final String tipo;
  final String descripcion;
  final String estado;
  final bool activo;

  const MetodoAcceso({
    this.id,
    required this.nombre,
    required this.tipo,
    this.descripcion = '',
    this.estado = 'Activo',
    this.activo = true,
  });

  MetodoAcceso copiarCon({
    int? id,
    String? nombre,
    String? tipo,
    String? descripcion,
    String? estado,
    bool? activo,
  }) {
    return MetodoAcceso(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      tipo: tipo ?? this.tipo,
      descripcion: descripcion ?? this.descripcion,
      estado: estado ?? this.estado,
      activo: activo ?? this.activo,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nombre': nombre,
      'tipo': tipo,
      'descripcion': descripcion,
      'estado': estado,
      'activo': activo ? 1 : 0,
    };
  }

  factory MetodoAcceso.fromMap(Map<String, dynamic> mapa) {
    return MetodoAcceso(
      id: mapa['id'] as int?,
      nombre: mapa['nombre'] as String? ?? '',
      tipo: mapa['tipo'] as String? ?? 'Biométrico',
      descripcion: mapa['descripcion'] as String? ?? '',
      estado: mapa['estado'] as String? ?? 'Activo',
      activo: (mapa['activo'] as int? ?? 1) == 1,
    );
  }

  @override
  String toString() => 'MetodoAcceso(id: $id, nombre: $nombre, tipo: $tipo, activo: $activo)';
}
