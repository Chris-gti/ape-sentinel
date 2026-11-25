// ============================================================================
// MODELO: PERMISO DE TRABAJO (POO INMUTABLE)
// ============================================================================

class PermisoTrabajo {
  final int? id;
  final String codigo;
  final String plantaZona;
  final String tipoTrabajo;
  final String nivelSeguridad;
  final String estado;
  final String descripcion;
  final String responsable;
  final int cantidadMaxima;

  const PermisoTrabajo({
    this.id,
    required this.codigo,
    required this.plantaZona,
    required this.tipoTrabajo,
    required this.nivelSeguridad,
    this.estado = 'Pendiente',
    this.descripcion = '',
    required this.responsable,
    required this.cantidadMaxima,
  });

  PermisoTrabajo copiarCon({
    int? id,
    String? codigo,
    String? plantaZona,
    String? tipoTrabajo,
    String? nivelSeguridad,
    String? estado,
    String? descripcion,
    String? responsable,
    int? cantidadMaxima,
  }) {
    return PermisoTrabajo(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      plantaZona: plantaZona ?? this.plantaZona,
      tipoTrabajo: tipoTrabajo ?? this.tipoTrabajo,
      nivelSeguridad: nivelSeguridad ?? this.nivelSeguridad,
      estado: estado ?? this.estado,
      descripcion: descripcion ?? this.descripcion,
      responsable: responsable ?? this.responsable,
      cantidadMaxima: cantidadMaxima ?? this.cantidadMaxima,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'codigo': codigo,
      'planta_zona': plantaZona,
      'tipo_trabajo': tipoTrabajo,
      'nivel_seguridad': nivelSeguridad,
      'estado': estado,
      'descripcion': descripcion,
      'responsable': responsable,
      'cantidad_maxima': cantidadMaxima,
    };
  }

  factory PermisoTrabajo.fromMap(Map<String, dynamic> mapa) {
    return PermisoTrabajo(
      id: mapa['id'] as int?,
      codigo: mapa['codigo'] as String? ?? '',
      plantaZona: mapa['planta_zona'] as String? ?? '',
      tipoTrabajo: mapa['tipo_trabajo'] as String? ?? 'Mantenimiento',
      nivelSeguridad: mapa['nivel_seguridad'] as String? ?? 'Nivel 2',
      estado: mapa['estado'] as String? ?? 'Pendiente',
      descripcion: mapa['descripcion'] as String? ?? '',
      responsable: mapa['responsable'] as String? ?? '',
      cantidadMaxima: mapa['cantidad_maxima'] as int? ?? 1,
    );
  }

  @override
  String toString() => 'PermisoTrabajo(id: $id, codigo: $codigo, planta: $plantaZona, estado: $estado)';
}
