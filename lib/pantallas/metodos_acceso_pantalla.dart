import 'package:flutter/material.dart';
import '../datos/repositorios/metodo_acceso_repositorio.dart';
import '../modelos/metodo_acceso.dart';
import '../tema/colores.dart';
import '../widgets/barra_superior.dart';
import '../widgets/componentes_formulario.dart';

// ============================================================================
// PANTALLA: MÉTODOS DE ACCESO (CRUD COMPLETO CON SQLITE)
// ============================================================================

class MetodosAccesoPantalla extends StatefulWidget {
  const MetodosAccesoPantalla({super.key});

  @override
  State<MetodosAccesoPantalla> createState() => _MetodosAccesoPantallaState();
}

class _MetodosAccesoPantallaState extends State<MetodosAccesoPantalla> {
  final _claveFormulario = GlobalKey<FormState>();
  final _controladorNombre = TextEditingController();
  final _controladorDescripcion = TextEditingController();
  final _metodoRepositorio = MetodoAccesoRepositorio();

  String _tipoMetodo = 'Biométrico';
  String _estadoMetodo = 'Activo';

  List<MetodoAcceso> _listaMetodos = [];
  bool _estaCargando = true;

  @override
  void initState() {
    super.initState();
    _cargarMetodos();
  }

  @override
  void dispose() {
    _controladorNombre.dispose();
    _controladorDescripcion.dispose();
    super.dispose();
  }

  Future<void> _cargarMetodos() async {
    setState(() => _estaCargando = true);
    try {
      final metodos = await _metodoRepositorio.obtenerTodos();
      if (!mounted) return;
      setState(() {
        _listaMetodos = metodos;
        _estaCargando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _estaCargando = false);
    }
  }

  Future<void> _agregarMetodo() async {
    if (!_claveFormulario.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final nuevoMetodo = MetodoAcceso(
      nombre: _controladorNombre.text.trim(),
      tipo: _tipoMetodo,
      descripcion: _controladorDescripcion.text.trim().isEmpty
          ? '—'
          : _controladorDescripcion.text.trim(),
      estado: _estadoMetodo,
      activo: _estadoMetodo == 'Activo',
    );

    try {
      await _metodoRepositorio.crear(nuevoMetodo);
      _controladorNombre.clear();
      _controladorDescripcion.clear();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: kColorVerde,
          content: Text('Método de acceso habilitado y registrado en la BD.'),
        ),
      );
      await _cargarMetodos();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: kColorRojo,
          content: Text('Error al registrar método: $e'),
        ),
      );
    }
  }

  Future<void> _alternarEstado(MetodoAcceso m) async {
    if (m.id == null) return;
    final nuevoEstado = !m.activo;
    await _metodoRepositorio.cambiarEstado(m.id!, nuevoEstado);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Método "${m.nombre}" ahora está ${nuevoEstado ? 'Activo' : 'Inactivo'}.',
        ),
      ),
    );
    _cargarMetodos();
  }

  Future<void> _confirmarEliminacion(MetodoAcceso m) async {
    if (m.id == null) return;
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kColorTarjeta,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: kColorBordeTarjeta),
        ),
        title: const Text('Confirmar Eliminación',
            style: TextStyle(color: Colors.white, fontSize: 14)),
        content: Text(
          '¿Desea eliminar el método de validación "${m.nombre}"?',
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCELAR',
                style: TextStyle(color: Colors.white54, fontSize: 11)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kColorRojo),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('ELIMINAR',
                style: TextStyle(color: Colors.white, fontSize: 11)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await _metodoRepositorio.eliminar(m.id!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Método eliminado.')),
      );
      _cargarMetodos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BarraSuperior(
        titulo: 'MÉTODOS DE ACCESO',
        subtitulo: 'Biometría y credencialización',
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
                titulo: 'FICHA DE MÉTODO DE ACCESO',
                hijos: [
                  filaDosColumnas(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        etiquetaCampo('MÉTODO DE ACCESO'),
                        campoTexto(
                          controlador: _controladorNombre,
                          pista: 'Ej. Token BLE',
                          icono: Icons.fingerprint,
                          validador: (v) => (v == null || v.trim().isEmpty)
                              ? 'Ingrese el método'
                              : null,
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        etiquetaCampo('TIPO DE MÉTODO'),
                        campoDesplegable(
                          valor: _tipoMetodo,
                          elementos: const [
                            'Biométrico',
                            'Tarjeta',
                            'PIN',
                            'Otro'
                          ],
                          alCambiar: (v) {
                            if (v != null) setState(() => _tipoMetodo = v);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  etiquetaCampo('DESCRIPCIÓN'),
                  campoTexto(
                    controlador: _controladorDescripcion,
                    pista: 'Descripción operativa del método',
                    maxLineas: 2,
                  ),
                  const SizedBox(height: 10),
                  etiquetaCampo('ESTADO'),
                  campoDesplegable(
                    valor: _estadoMetodo,
                    elementos: const ['Activo', 'Inactivo'],
                    alCambiar: (v) {
                      if (v != null) setState(() => _estadoMetodo = v);
                    },
                  ),
                  const SizedBox(height: 14),
                  botonPrimario(
                    'AGREGAR MÉTODO',
                    icono: Icons.add_moderator_outlined,
                    alPresionar: _agregarMetodo,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            encabezadoSeccion(
              'MÉTODOS REGISTRADOS (${_listaMetodos.length})',
            ),
            if (_estaCargando)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(
                    color: kColorNaranja,
                    strokeWidth: 2,
                  ),
                ),
              )
            else if (_listaMetodos.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: kColorTarjeta,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: kColorBordeTarjeta),
                ),
                child: const Center(
                  child: Text(
                    'No hay métodos de acceso configurados.',
                    style: TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ),
              )
            else
              ..._listaMetodos.map(_tarjetaMetodo),
          ],
        ),
      ),
    );
  }

  Widget _tarjetaMetodo(MetodoAcceso m) {
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
          const Icon(Icons.fingerprint, color: kColorNaranja, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  m.nombre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${m.tipo} · ${m.descripcion}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => _alternarEstado(m),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: (m.activo ? kColorVerde : Colors.white24)
                    .withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                m.activo ? 'Activo' : 'Inactivo',
                style: TextStyle(
                  color: m.activo ? kColorVerde : Colors.white54,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline,
                color: Colors.white38, size: 18),
            onPressed: () => _confirmarEliminacion(m),
          ),
        ],
      ),
    );
  }
}
