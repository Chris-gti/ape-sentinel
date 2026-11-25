import 'package:flutter_test/flutter_test.dart';
import 'package:ape_sentinel/modelos/usuario.dart';
import 'package:ape_sentinel/modelos/personal.dart';
import 'package:ape_sentinel/modelos/planta_zona.dart';
import 'package:ape_sentinel/modelos/permiso_trabajo.dart';
import 'package:ape_sentinel/modelos/dispositivo_acceso.dart';
import 'package:ape_sentinel/modelos/metodo_acceso.dart';
import 'package:ape_sentinel/modelos/evento_bitacora.dart';

void main() {
  group('Pruebas unitarias de Modelos POO ApeSentinel', () {
    test('Serialización y deserialización de Usuario', () {
      const usuario = Usuario(
        id: 1,
        ficha: '849201',
        contrasena: 'admin123',
        nombre: 'Admin',
        rol: 'Super Administrador',
        activo: true,
      );

      final mapa = usuario.toMap();
      expect(mapa['ficha'], '849201');
      expect(mapa['activo'], 1);

      final reconstruido = Usuario.fromMap(mapa);
      expect(reconstruido.id, 1);
      expect(reconstruido.ficha, '849201');
      expect(reconstruido.activo, isTrue);
    });

    test('Serialización y deserialización de Personal', () {
      const personal = Personal(
        id: 10,
        nombre: 'Carlos Mendoza',
        ficha: '849201',
        area: 'Supervisión',
        turno: 'Matutino',
        nivel: 'Nivel 4',
        activo: true,
      );

      final mapa = personal.toMap();
      expect(mapa['nombre'], 'Carlos Mendoza');
      expect(mapa['activo'], 1);

      final reconstruido = Personal.fromMap(mapa);
      expect(reconstruido.ficha, '849201');
      expect(reconstruido.area, 'Supervisión');
      expect(reconstruido.activo, isTrue);
    });

    test('Serialización y deserialización de PlantaZona', () {
      const planta = PlantaZona(
        id: 2,
        nombre: 'Planta Norte 01',
        tipo: 'Operativa',
        nivel: 'Nivel 2',
        estado: 'Activa',
        capacidadMaxima: 120,
      );

      final mapa = planta.toMap();
      expect(mapa['capacidad_maxima'], 120);

      final reconstruido = PlantaZona.fromMap(mapa);
      expect(reconstruido.nombre, 'Planta Norte 01');
      expect(reconstruido.capacidadMaxima, 120);
    });

    test('Serialización y deserialización de PermisoTrabajo', () {
      const permiso = PermisoTrabajo(
        id: 3,
        codigo: 'PT-081',
        plantaZona: 'Planta Norte 01',
        tipoTrabajo: 'Altura',
        nivelSeguridad: 'Nivel 3',
        estado: 'Aprobado',
        responsable: 'Javier Ruiz',
        cantidadMaxima: 4,
      );

      final mapa = permiso.toMap();
      expect(mapa['codigo'], 'PT-081');

      final reconstruido = PermisoTrabajo.fromMap(mapa);
      expect(reconstruido.codigo, 'PT-081');
      expect(reconstruido.responsable, 'Javier Ruiz');
    });

    test('Serialización y deserialización de DispositivoAcceso', () {
      const dispositivo = DispositivoAcceso(
        id: 5,
        marca: 'HID Global',
        tipo: 'Torniquete',
        ubicacion: 'Acceso Principal',
        serie: 'T-01',
        enLinea: true,
      );

      final mapa = dispositivo.toMap();
      expect(mapa['en_linea'], 1);

      final reconstruido = DispositivoAcceso.fromMap(mapa);
      expect(reconstruido.serie, 'T-01');
      expect(reconstruido.enLinea, isTrue);
    });

    test('Serialización y deserialización de MetodoAcceso', () {
      const metodo = MetodoAcceso(
        id: 4,
        nombre: 'Reconocimiento Facial 3D',
        tipo: 'Biométrico',
        activo: true,
      );

      final mapa = metodo.toMap();
      expect(mapa['activo'], 1);

      final reconstruido = MetodoAcceso.fromMap(mapa);
      expect(reconstruido.nombre, 'Reconocimiento Facial 3D');
      expect(reconstruido.activo, isTrue);
    });

    test('Serialización y deserialización de EventoBitacora', () {
      const evento = EventoBitacora(
        id: 8,
        fechaHora: '10:34:12',
        persona: 'Carlos Mendoza Ramos',
        tipo: 'ENTRADA',
        zona: 'Torniquete T-01',
      );

      final mapa = evento.toMap();
      expect(mapa['tipo'], 'ENTRADA');

      final reconstruido = EventoBitacora.fromMap(mapa);
      expect(reconstruido.persona, 'Carlos Mendoza Ramos');
      expect(reconstruido.tipo, 'ENTRADA');
    });
  });
}
