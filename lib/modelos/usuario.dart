// ============================================================================
// MODELO: USUARIO (POO INMUTABLE)
// ============================================================================

class Usuario {
  final int? id;
  final String ficha;
  final String contrasena;
  final String nombre;
  final String rol;
  final bool activo;

  const Usuario({
    this.id,
    required this.ficha,
    required this.contrasena,
    required this.nombre,
    required this.rol,
    this.activo = true,
  });

  Usuario copiarCon({
    int? id,
    String? ficha,
    String? contrasena,
    String? nombre,
    String? rol,
    bool? activo,
  }) {
    return Usuario(
      id: id ?? this.id,
      ficha: ficha ?? this.ficha,
      contrasena: contrasena ?? this.contrasena,
      nombre: nombre ?? this.nombre,
      rol: rol ?? this.rol,
      activo: activo ?? this.activo,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'ficha': ficha,
      'contrasena': contrasena,
      'nombre': nombre,
      'rol': rol,
      'activo': activo ? 1 : 0,
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> mapa) {
    return Usuario(
      id: mapa['id'] as int?,
      ficha: mapa['ficha'] as String? ?? '',
      contrasena: mapa['contrasena'] as String? ?? '',
      nombre: mapa['nombre'] as String? ?? '',
      rol: mapa['rol'] as String? ?? 'Operador',
      activo: (mapa['activo'] as int? ?? 1) == 1,
    );
  }

  @override
  String toString() => 'Usuario(id: $id, ficha: $ficha, nombre: $nombre, rol: $rol, activo: $activo)';
}
