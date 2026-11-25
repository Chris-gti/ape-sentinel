// ============================================================================
// MODELO: EVENTO DE BITÁCORA (POO INMUTABLE)
// ============================================================================

class EventoBitacora {
  final int? id;
  final String fechaHora;
  final String persona;
  final String tipo;
  final String zona;

  const EventoBitacora({
    this.id,
    required this.fechaHora,
    required this.persona,
    required this.tipo,
    required this.zona,
  });

  EventoBitacora copiarCon({
    int? id,
    String? fechaHora,
    String? persona,
    String? tipo,
    String? zona,
  }) {
    return EventoBitacora(
      id: id ?? this.id,
      fechaHora: fechaHora ?? this.fechaHora,
      persona: persona ?? this.persona,
      tipo: tipo ?? this.tipo,
      zona: zona ?? this.zona,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'fecha_hora': fechaHora,
      'persona': persona,
      'tipo': tipo,
      'zona': zona,
    };
  }

  factory EventoBitacora.fromMap(Map<String, dynamic> mapa) {
    return EventoBitacora(
      id: mapa['id'] as int?,
      fechaHora: mapa['fecha_hora'] as String? ?? '',
      persona: mapa['persona'] as String? ?? '',
      tipo: mapa['tipo'] as String? ?? 'ENTRADA',
      zona: mapa['zona'] as String? ?? '',
    );
  }

  @override
  String toString() => 'EventoBitacora(id: $id, fechaHora: $fechaHora, persona: $persona, tipo: $tipo, zona: $zona)';
}
