import 'package:flutter/material.dart';
import '../datos/repositorios/planta_zona_repositorio.dart';
import '../modelos/planta_zona.dart';
import '../tema/colores.dart';
import '../widgets/barra_superior.dart';
import '../widgets/componentes_formulario.dart';

// ============================================================================
// PANTALLA: GESTIÓN DE PLANTAS / ZONAS (CRUD COMPLETO CON SQLITE)
// ============================================================================

class PlantasZonasPantalla extends StatefulWidget {
  const PlantasZonasPantalla({super.key});

  @override
  State<PlantasZonasPantalla> createState() => _PlantasZonasPantallaState();
}

class _PlantasZonasPantallaState extends State<PlantasZonasPantalla> {
  final _claveFormulario = GlobalKey<FormState>();
  final _controladorPlanta = TextEditingController();
  final _controladorDescripcion = TextEditingController();
  final _controladorCapacidad = TextEditingController();
  final _plantaZonaRepositorio = PlantaZonaRepositorio();

  String _tipoZona = 'Operativa';
  String _nivelSeguridad = 'Nivel 2';
  String _estadoZona = 'Activa';

  List<PlantaZona> _listaPlantas = [];
  bool _estaCargando = true;

  @override
  void initState() {
    super.initState();
    _cargarPlantas();
  }

  @override
  void dispose() {
    _controladorPlanta.dispose();
    _controladorDescripcion.dispose();
    _controladorCapacidad.dispose();
    super.dispose();
  }

  Future<void> _cargarPlantas() async {
    setState(() => _estaCargando = true);
    try {
      final plantas = await _plantaZonaRepositorio.obtenerTodas();
      if (!mounted) return;
      setState(() {
        _listaPlantas = plantas;
        _estaCargando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _estaCargando = false);
    }
  }

  Future<void> _agregarPlanta() async {
    if (!_claveFormulario.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final capacidad = int.tryParse(_controladorCapacidad.text.trim()) ?? 40;
    final nuevaPlanta = PlantaZona(
      nombre: _controladorPlanta.text.trim(),
      tipo: _tipoZona,
      nivel: _nivelSeguridad,
      estado: _estadoZona,
      descripcion: _controladorDescripcion.text.trim(),
      capacidadMaxima: capacidad,
    );

    try {
      await _plantaZonaRepositorio.crear(nuevaPlanta);
      _controladorPlanta.clear();
      _controladorDescripcion.clear();
      _controladorCapacidad.clear();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: kColorVerde,
          content: Text('Planta / Zona guardada exitosamente en la base de datos.'),
        ),
      );
      await _cargarPlantas();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: kColorRojo,
          content: Text('Error al guardar planta: $e'),
        ),
      );
    }
  }

  Future<void> _cambiarEstado(PlantaZona p) async {
    if (p.id == null) return;
    final estados = ['Activa', 'Inactiva', 'Bloqueada'];
    final nuevoEstado = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        backgroundColor: kColorTarjeta,
        title: Text(
          'Cambiar estado de "${p.nombre}"',
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
        children: estados
            .map(
              (e) => SimpleDialogOption(
                onPressed: () => Navigator.pop(ctx, e),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    e,
                    style: TextStyle(
                      color: e == p.estado ? kColorNaranja : Colors.white70,
                      fontWeight: e == p.estado ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );

    if (nuevoEstado != null && nuevoEstado != p.estado) {
      await _plantaZonaRepositorio.cambiarEstado(p.id!, nuevoEstado);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Estado actualizado a "$nuevoEstado".')),
      );
      _cargarPlantas();
    }
  }

  Future<void> _confirmarEliminacion(PlantaZona p) async {
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
          '¿Desea eliminar la zona "${p.nombre}" de la base de datos?',
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
      await _plantaZonaRepositorio.eliminar(p.id!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Planta eliminada.')),
      );
      _cargarPlantas();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BarraSuperior(
        titulo: 'GESTIÓN DE PLANTAS / ZONAS',
        subtitulo: 'Configuración y control perimetral',
        mostrarBotonAtras: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          physics: const BouncingScrollPhysics(),
          children: [
            Form(
              key: _claveFormulario,
              child: tarjetaFormulario(
                titulo: 'FICHA DE PLANTA / ZONA',
                hijos: [
                  filaDosColumnas(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        etiquetaCampo('PLANTA DE ACCESO'),
                        campoTexto(
                          controlador: _controladorPlanta,
                          pista: 'Ej. Planta Norte 02',
                          icono: Icons.domain,
                          validador: (v) => (v == null || v.trim().isEmpty)
                              ? 'Ingrese el nombre de la planta'
                              : null,
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        etiquetaCampo('TIPO DE ZONA'),
                        campoDesplegable(
                          valor: _tipoZona,
                          elementos: const ['Operativa', 'Restringida', 'Crítica'],
                          alCambiar: (v) {
                            if (v != null) setState(() => _tipoZona = v);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  filaDosColumnas(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        etiquetaCampo('NIVEL DE SEGURIDAD'),
                        campoDesplegable(
                          valor: _nivelSeguridad,
                          elementos: const ['Nivel 1', 'Nivel 2', 'Nivel 3', 'Nivel 4'],
                          alCambiar: (v) {
                            if (v != null) setState(() => _nivelSeguridad = v);
                          },
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        etiquetaCampo('ESTADO'),
                        campoDesplegable(
                          valor: _estadoZona,
                          elementos: const ['Activa', 'Inactiva', 'Bloqueada'],
                          alCambiar: (v) {
                            if (v != null) setState(() => _estadoZona = v);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  etiquetaCampo('ÁREA / DESCRIPCIÓN'),
                  campoTexto(
                    controlador: _controladorDescripcion,
                    pista: 'Descripción breve de la zona',
                    maxLineas: 2,
                  ),
                  const SizedBox(height: 10),
                  etiquetaCampo('CANTIDAD MÁXIMA DE PERSONAS'),
                  campoTexto(
                    controlador: _controladorCapacidad,
                    pista: 'Ej. 40',
                    tipoTeclado: TextInputType.number,
                    validador: (v) => (v == null || v.trim().isEmpty)
                        ? 'Ingrese el aforo máximo'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  botonPrimario(
                    'AGREGAR PLANTA / ZONA',
                    icono: Icons.add_location_alt_outlined,
                    alPresionar: _agregarPlanta,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            encabezadoSeccion('PLANTAS REGISTRADAS (${_listaPlantas.length})'),
            if (_estaCargando)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(color: kColorNaranja, strokeWidth: 2),
                ),
              )
            else if (_listaPlantas.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: kColorTarjeta,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: kColorBordeTarjeta),
                ),
                child: const Center(
                  child: Text(
                    'No hay plantas ni zonas registradas.',
                    style: TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ),
              )
            else
              ..._listaPlantas.map(_tarjetaPlanta),
          ],
        ),
      ),
    );
  }

  Widget _tarjetaPlanta(PlantaZona p) {
    Color colorEstado = kColorVerde;
    if (p.estado == 'Inactiva') colorEstado = Colors.white54;
    if (p.estado == 'Bloqueada') colorEstado = kColorRojo;

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
          const Icon(Icons.domain, color: kColorNaranja, size: 18),
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
                  '${p.tipo} · ${p.nivel} · Máx ${p.capacidadMaxima} pers.',
                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                ),
                const SizedBox(height: 3),
                InkWell(
                  onTap: () => _cambiarEstado(p),
                  child: insigniaEstado(p.estado, colorEstado),
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
