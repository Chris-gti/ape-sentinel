import 'package:flutter/material.dart';
import '../datos/repositorios/personal_repositorio.dart';
import '../modelos/personal.dart';
import '../tema/colores.dart';
import '../widgets/barra_navegacion.dart';
import '../widgets/barra_superior.dart';
import '../widgets/componentes_formulario.dart';
import '../widgets/transicion_suave.dart';
import 'bitacora_pantalla.dart';
import 'panel_control_pantalla.dart';

// ============================================================================
// PANTALLA: GESTIÓN DE PERSONAL (CRUD COMPLETO Y BÚSQUEDA CON SQLITE)
// ============================================================================

class PersonalPantalla extends StatefulWidget {
  const PersonalPantalla({super.key});

  @override
  State<PersonalPantalla> createState() => _PersonalPantallaState();
}

class _PersonalPantallaState extends State<PersonalPantalla> {
  final _claveFormulario = GlobalKey<FormState>();
  final _controladorNombre = TextEditingController();
  final _controladorArea = TextEditingController();
  final _controladorBusqueda = TextEditingController();
  final _personalRepositorio = PersonalRepositorio();

  String _turnoSeleccionado = 'Matutino';
  List<Personal> _listaPersonal = [];
  bool _estaCargando = true;
  String? _filtroActivo;

  String get _fechaHoy {
    final d = DateTime.now();
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  @override
  void initState() {
    super.initState();
    _cargarPersonal();
  }

  @override
  void dispose() {
    _controladorNombre.dispose();
    _controladorArea.dispose();
    _controladorBusqueda.dispose();
    super.dispose();
  }

  Future<void> _cargarPersonal({String? busqueda}) async {
    setState(() => _estaCargando = true);
    try {
      List<Personal> lista;
      if (busqueda != null && busqueda.trim().isNotEmpty) {
        lista = await _personalRepositorio.buscar(busqueda.trim());
        _filtroActivo = busqueda.trim();
      } else {
        lista = await _personalRepositorio.obtenerTodos();
        _filtroActivo = null;
      }

      if (!mounted) return;
      setState(() {
        _listaPersonal = lista;
        _estaCargando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _estaCargando = false);
    }
  }

  Future<void> _agregarOperador() async {
    if (!_claveFormulario.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final nombre = _controladorNombre.text.trim();
    final area = _controladorArea.text.trim().isEmpty
        ? 'Sin asignar'
        : _controladorArea.text.trim();

    // Generar número de ficha correlativo comenzando en 1001
    final totalActual = await _personalRepositorio.obtenerTodos();
    final nuevaFicha = (1001 + totalActual.length).toString();

    final nuevoPersonal = Personal(
      nombre: nombre,
      ficha: nuevaFicha,
      area: area,
      turno: _turnoSeleccionado,
      nivel: 'Nivel 2',
      activo: true,
      fechaAlta: _fechaHoy,
      ultimaActualizacion: 'Hoy',
    );

    try {
      await _personalRepositorio.crear(nuevoPersonal);
      _controladorNombre.clear();
      _controladorArea.clear();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: kColorVerde,
          content: Text('Operador "$nombre" registrado con éxito (Ficha: $nuevaFicha).'),
        ),
      );
      await _cargarPersonal();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: kColorRojo,
          content: Text('Error al registrar personal: $e'),
        ),
      );
    }
  }

  void _mostrarDialogoBusqueda() {
    _controladorBusqueda.text = _filtroActivo ?? '';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kColorTarjeta,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: kColorBordeTarjeta),
        ),
        title: const Row(
          children: [
            Icon(Icons.search, color: kColorNaranja, size: 20),
            SizedBox(width: 8),
            Text(
              'CONSULTAR PERSONAL',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Ingrese el nombre, ficha o área para filtrar en SQLite:',
              style: TextStyle(color: Colors.white70, fontSize: 11),
            ),
            const SizedBox(height: 12),
            campoTexto(
              controlador: _controladorBusqueda,
              pista: 'Ej. Mendoza o 849201',
              icono: Icons.filter_alt_outlined,
            ),
          ],
        ),
        actions: [
          if (_filtroActivo != null)
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _cargarPersonal();
              },
              child: const Text('LIMPIAR FILTRO', style: TextStyle(color: Colors.white54, fontSize: 11)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCELAR', style: TextStyle(color: Colors.white54, fontSize: 11)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kColorNaranja,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            onPressed: () {
              final consulta = _controladorBusqueda.text.trim();
              Navigator.pop(ctx);
              _cargarPersonal(busqueda: consulta);
            },
            child: const Text('BUSCAR', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _alternarEstado(Personal p) async {
    if (p.id == null) return;
    final nuevoEstado = !p.activo;
    await _personalRepositorio.cambiarEstado(p.id!, nuevoEstado);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Operador marcado como ${nuevoEstado ? 'Activo' : 'Inactivo'}.'),
      ),
    );
    _cargarPersonal(busqueda: _filtroActivo);
  }

  Future<void> _confirmarEliminacion(Personal p) async {
    if (p.id == null) return;
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kColorTarjeta,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: kColorBordeTarjeta),
        ),
        title: const Text('Confirmar Eliminación', style: TextStyle(color: Colors.white, fontSize: 14)),
        content: Text(
          '¿Desea eliminar a "${p.nombre}" (Ficha ${p.ficha}) de la base de datos?',
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCELAR', style: TextStyle(color: Colors.white54, fontSize: 11)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kColorRojo),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('ELIMINAR', style: TextStyle(color: Colors.white, fontSize: 11)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await _personalRepositorio.eliminar(p.id!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro eliminado de la base de datos.')),
      );
      _cargarPersonal(busqueda: _filtroActivo);
    }
  }

  void _cambiarPestana(int indice) {
    if (indice == 1) return;
    Widget pantallaDestino;
    if (indice == 0) {
      pantallaDestino = const PanelControlPantalla();
    } else {
      pantallaDestino = const BitacoraPantalla();
    }
    Navigator.pushReplacement(
      context,
      TransicionSuave(pantalla: pantallaDestino),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BarraSuperior(
        titulo: 'GESTIÓN DE PERSONAL',
        subtitulo: 'Registro y control de operadores',
      ),
      bottomNavigationBar: BarraNavegacion(
        indiceActual: 1,
        alSeleccionar: _cambiarPestana,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          physics: const BouncingScrollPhysics(),
          children: [
            // Formulario de registro técnico
            Form(
              key: _claveFormulario,
              child: tarjetaFormulario(
                titulo: 'FICHA DE REGISTRO TÉCNICO',
                hijos: [
                  filaDosColumnas(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        etiquetaCampo('FECHA DE ALTA'),
                        campoTexto(valorInicial: _fechaHoy, soloLectura: true),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        etiquetaCampo('ÚLTIMA ACTUALIZACIÓN'),
                        campoTexto(valorInicial: 'Hoy', soloLectura: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  etiquetaCampo('NOMBRE COMPLETO'),
                  campoTexto(
                    controlador: _controladorNombre,
                    pista: 'Ej. Roberto Gómez Treviño',
                    icono: Icons.person_add_alt,
                    validador: (v) => (v == null || v.trim().isEmpty)
                        ? 'Ingrese el nombre completo'
                        : null,
                  ),
                  const SizedBox(height: 10),
                  etiquetaCampo('ÁREA / DEPARTAMENTO'),
                  campoTexto(
                    controlador: _controladorArea,
                    pista: 'Ej. Analista de Procesos',
                    icono: Icons.business_outlined,
                  ),
                  const SizedBox(height: 10),
                  etiquetaCampo('TURNO PREDETERMINADO'),
                  campoDesplegable(
                    valor: _turnoSeleccionado,
                    elementos: const ['Matutino', 'Vespertino', 'Nocturno'],
                    alCambiar: (v) {
                      if (v != null) setState(() => _turnoSeleccionado = v);
                    },
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: botonPrimario(
                          'GUARDAR',
                          icono: Icons.save_outlined,
                          alPresionar: _agregarOperador,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: botonSecundario(
                          _filtroActivo != null ? 'FILTRO ACTIVO' : 'CONSULTAR',
                          alPresionar: _mostrarDialogoBusqueda,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Encabezado con estado del filtro
            encabezadoSeccion(
              _filtroActivo != null
                  ? 'RESULTADOS PARA: "${_filtroActivo!.toUpperCase()}"'
                  : 'OPERADORES REGISTRADOS (${_listaPersonal.length})',
              accionDerecha: _filtroActivo != null
                  ? TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () => _cargarPersonal(),
                      child: const Text(
                        'RESTABLECER',
                        style: TextStyle(
                          color: kColorNaranja,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : null,
            ),

            if (_estaCargando)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(color: kColorNaranja, strokeWidth: 2),
                ),
              )
            else if (_listaPersonal.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: kColorTarjeta,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: kColorBordeTarjeta),
                ),
                child: Center(
                  child: Text(
                    _filtroActivo != null
                        ? 'No se encontraron coincidencias para la búsqueda.'
                        : 'No hay personal registrado en la base de datos.',
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ),
              )
            else
              ..._listaPersonal.map(_tarjetaPersonal),
          ],
        ),
      ),
    );
  }

  Widget _tarjetaPersonal(Personal p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: kColorTarjeta,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kColorBordeTarjeta),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: kColorNaranja.withValues(alpha: 0.15),
            child: Text(
              p.nombre.isNotEmpty ? p.nombre.substring(0, 1).toUpperCase() : '?',
              style: const TextStyle(
                color: kColorNaranja,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.nombre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Ficha ${p.ficha} · ${p.area} (${p.turno})',
                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    insigniaEstado(p.nivel, kColorNaranja),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () => _alternarEstado(p),
                      child: insigniaEstado(
                        p.activo ? 'Activo' : 'Inactivo',
                        p.activo ? kColorVerde : kColorRojo,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white38, size: 18),
            onPressed: () => _confirmarEliminacion(p),
          ),
        ],
      ),
    );
  }
}
