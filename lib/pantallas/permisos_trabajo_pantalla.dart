import 'package:flutter/material.dart';
import '../datos/repositorios/permiso_trabajo_repositorio.dart';
import '../modelos/permiso_trabajo.dart';
import '../tema/colores.dart';
import '../widgets/barra_superior.dart';
import '../widgets/componentes_formulario.dart';

// ============================================================================
// PANTALLA: PERMISOS DE TRABAJO (CRUD COMPLETO CON SQLITE)
// ============================================================================

class PermisosTrabajoPantalla extends StatefulWidget {
  const PermisosTrabajoPantalla({super.key});

  @override
  State<PermisosTrabajoPantalla> createState() => _PermisosTrabajoPantallaState();
}

class _PermisosTrabajoPantallaState extends State<PermisosTrabajoPantalla> {
  final _claveFormulario = GlobalKey<FormState>();
  final _controladorPlanta = TextEditingController();
  final _controladorDescripcion = TextEditingController();
  final _controladorResponsable = TextEditingController();
  final _controladorCapacidad = TextEditingController();
  final _permisoRepositorio = PermisoTrabajoRepositorio();

  String _tipoTrabajo = 'Mantenimiento';
  String _nivelSeguridad = 'Nivel 3';
  String _estadoPermiso = 'Pendiente';

  List<PermisoTrabajo> _listaPermisos = [];
  bool _estaCargando = true;

  @override
  void initState() {
    super.initState();
    _cargarPermisos();
  }

  @override
  void dispose() {
    _controladorPlanta.dispose();
    _controladorDescripcion.dispose();
    _controladorResponsable.dispose();
    _controladorCapacidad.dispose();
    super.dispose();
  }

  Future<void> _cargarPermisos() async {
    setState(() => _estaCargando = true);
    try {
      final permisos = await _permisoRepositorio.obtenerTodos();
      if (!mounted) return;
      setState(() {
        _listaPermisos = permisos;
        _estaCargando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _estaCargando = false);
    }
  }

  Future<void> _agregarPermiso() async {
    if (!_claveFormulario.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final cantidad = int.tryParse(_controladorCapacidad.text.trim()) ?? 2;
    final totalActual = await _permisoRepositorio.contarTotal();
    final codigoGenerado = 'PT-${(totalActual + 1).toString().padLeft(3, '0')}';

    final nuevoPermiso = PermisoTrabajo(
      codigo: codigoGenerado,
      plantaZona: _controladorPlanta.text.trim(),
      tipoTrabajo: _tipoTrabajo,
      nivelSeguridad: _nivelSeguridad,
      estado: _estadoPermiso,
      descripcion: _controladorDescripcion.text.trim(),
      responsable: _controladorResponsable.text.trim(),
      cantidadMaxima: cantidad,
    );

    try {
      await _permisoRepositorio.crear(nuevoPermiso);
      _controladorPlanta.clear();
      _controladorDescripcion.clear();
      _controladorResponsable.clear();
      _controladorCapacidad.clear();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: kColorVerde,
          content: Text('Permiso "$codigoGenerado" emitido y registrado en SQLite.'),
        ),
      );
      await _cargarPermisos();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: kColorRojo,
          content: Text('Error al emitir permiso: $e'),
        ),
      );
    }
  }

  Future<void> _cambiarEstado(PermisoTrabajo p) async {
    if (p.id == null) return;
    final estados = ['Pendiente', 'Aprobado', 'En Revisión', 'Finalizado'];
    final nuevoEstado = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        backgroundColor: kColorTarjeta,
        title: Text(
          'Estatus de ${p.codigo}',
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
      await _permisoRepositorio.cambiarEstado(p.id!, nuevoEstado);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Estado de ${p.codigo} actualizado a "$nuevoEstado".')),
      );
      _cargarPermisos();
    }
  }

  Future<void> _confirmarEliminacion(PermisoTrabajo p) async {
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
          '¿Desea cancelar y eliminar el permiso "${p.codigo}"?',
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
      await _permisoRepositorio.eliminar(p.id!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permiso eliminado de la base de datos.')),
      );
      _cargarPermisos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BarraSuperior(
        titulo: 'PERMISOS DE TRABAJO',
        subtitulo: 'Autorizaciones y auditoría de maniobras',
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
                titulo: 'FICHA DE PERMISO / TRABAJO',
                hijos: [
                  filaDosColumnas(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        etiquetaCampo('PLANTA / ZONA'),
                        campoTexto(
                          controlador: _controladorPlanta,
                          pista: 'Ej. Planta Norte 01',
                          icono: Icons.domain,
                          validador: (v) => (v == null || v.trim().isEmpty)
                              ? 'Ingrese la planta o zona'
                              : null,
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        etiquetaCampo('TIPO DE TRABAJO'),
                        campoDesplegable(
                          valor: _tipoTrabajo,
                          elementos: const [
                            'Mantenimiento',
                            'Altura',
                            'Espacio Confinado',
                            'Soldadura',
                          ],
                          alCambiar: (v) {
                            if (v != null) setState(() => _tipoTrabajo = v);
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
                          valor: _estadoPermiso,
                          elementos: const [
                            'Pendiente',
                            'Aprobado',
                            'En Revisión',
                            'Finalizado',
                          ],
                          alCambiar: (v) {
                            if (v != null) setState(() => _estadoPermiso = v);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  etiquetaCampo('ÁREA / DESCRIPCIÓN DEL TRABAJO'),
                  campoTexto(
                    controlador: _controladorDescripcion,
                    pista: 'Descripción técnica de las labores',
                    maxLineas: 2,
                  ),
                  const SizedBox(height: 10),
                  etiquetaCampo('RESPONSABLE DEL PERMISO'),
                  campoTexto(
                    controlador: _controladorResponsable,
                    pista: 'Ej. Ing. Mateo Saldivar',
                    icono: Icons.engineering_outlined,
                    validador: (v) => (v == null || v.trim().isEmpty)
                        ? 'Ingrese el responsable'
                        : null,
                  ),
                  const SizedBox(height: 10),
                  etiquetaCampo('CANTIDAD MÁXIMA DE PERSONAS'),
                  campoTexto(
                    controlador: _controladorCapacidad,
                    pista: 'Ej. 4',
                    tipoTeclado: TextInputType.number,
                    validador: (v) => (v == null || v.trim().isEmpty)
                        ? 'Ingrese el personal autorizado'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  botonPrimario(
                    'AGREGAR PERMISO',
                    icono: Icons.note_add_outlined,
                    alPresionar: _agregarPermiso,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            encabezadoSeccion('PERMISOS ACTIVOS REGISTRADOS (${_listaPermisos.length})'),
            if (_estaCargando)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(color: kColorNaranja, strokeWidth: 2),
                ),
              )
            else if (_listaPermisos.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: kColorTarjeta,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: kColorBordeTarjeta),
                ),
                child: const Center(
                  child: Text(
                    'No hay permisos registrados en el sistema.',
                    style: TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ),
              )
            else
              ..._listaPermisos.map(_tarjetaPermiso),
          ],
        ),
      ),
    );
  }

  Widget _tarjetaPermiso(PermisoTrabajo p) {
    Color colorEstado = kColorNaranjaClaro;
    if (p.estado == 'Aprobado') colorEstado = kColorVerde;
    if (p.estado == 'Finalizado') colorEstado = Colors.white38;

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
          const Icon(Icons.assignment_outlined, color: kColorNaranja, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${p.codigo} · ${p.tipoTrabajo}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${p.plantaZona} · ${p.responsable} (Máx ${p.cantidadMaxima})',
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
