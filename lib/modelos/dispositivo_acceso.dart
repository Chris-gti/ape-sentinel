// ============================================================================
// MODELO: DISPOSITIVO DE ACCESO (POO INMUTABLE)
// ============================================================================

class DispositivoAcceso {
  final int? id;
  final String marca;
  final String tipo;
  final String ubicacion;
  final String estado;
  final String serie;
  final String firmware;
  final bool enLinea;

  const DispositivoAcceso({
    this.id,
    required this.marca,
    required this.tipo,
    required this.ubicacion,
    this.estado = 'Activo',
    required this.serie,
    this.firmware = 'v1.0.0',
    this.enLinea = true,
  });

  DispositivoAcceso copiarCon({
    int? id,
    String? marca,
    String? tipo,
    String? ubicacion,
    String? estado,
    String? serie,
    String? firmware,
    bool? enLinea,
  }) {
    return DispositivoAcceso(
      id: id ?? this.id,
      marca: marca ?? this.marca,
      tipo: tipo ?? this.tipo,
      ubicacion: ubicacion ?? this.ubicacion,
      estado: estado ?? this.estado,
      serie: serie ?? this.serie,
      firmware: firmware ?? this.firmware,
      enLinea: enLinea ?? this.enLinea,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'marca': marca,
      'tipo': tipo,
      'ubicacion': ubicacion,
      'estado': estado,
      'serie': serie,
      'firmware': firmware,
      'en_linea': enLinea ? 1 : 0,
    };
  }

  factory DispositivoAcceso.fromMap(Map<String, dynamic> mapa) {
    return DispositivoAcceso(
      id: mapa['id'] as int?,
      marca: mapa['marca'] as String? ?? '',
      tipo: mapa['tipo'] as String? ?? 'Lector RFID',
      ubicacion: mapa['ubicacion'] as String? ?? '',
      estado: mapa['estado'] as String? ?? 'Activo',
      serie: mapa['serie'] as String? ?? '',
      firmware: mapa['firmware'] as String? ?? 'v1.0.0',
      enLinea: (mapa['en_linea'] as int? ?? 1) == 1,
    );
  }

  @override
  String toString() => 'DispositivoAcceso(id: $id, marca: $marca, serie: $serie, enLinea: $enLinea)';
}
