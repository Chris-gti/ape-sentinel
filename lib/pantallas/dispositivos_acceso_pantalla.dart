import 'package:flutter/material.dart';
import '../datos/repositorios/dispositivo_acceso_repositorio.dart';
import '../modelos/dispositivo_acceso.dart';
import '../tema/colores.dart';
import '../widgets/barra_superior.dart';
import '../widgets/componentes_formulario.dart';

// ============================================================================
// PANTALLA: DISPOSITIVOS DE ACCESO (CRUD COMPLETO CON SQLITE)
// ============================================================================

class DispositivosAccesoPantalla extends StatefulWidget {
  const DispositivosAccesoPantalla({super.key});

  @override
  State<DispositivosAccesoPantalla> createState() =>
      _DispositivosAccesoPantallaState();
}

class _DispositivosAccesoPantallaState
    extends State<DispositivosAccesoPantalla> {
  final _claveFormulario = GlobalKey<FormState>();
  final _controladorMarca = TextEditingController();
  final _controladorUbicacion = TextEditingController();
  final _controladorSerie = TextEditingController();
  final _controladorFirmware = TextEditingController();
  final _dispositivoRepositorio = DispositivoAccesoRepositorio();

  String _tipoDispositivo = 'Lector RFID';
  String _estadoDispositivo = 'Activo';

  List<DispositivoAcceso> _listaDispositivos = [];
  bool _estaCargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDispositivos();
  }

  @override
  void dispose() {
    _controladorMarca.dispose();
    _controladorUbicacion.dispose();
    _controladorSerie.dispose();
    _controladorFirmware.dispose();
    super.dispose();
  }

  Future<void> _cargarDispositivos() async {
    setState(() => _estaCargando = true);
    try {
      final dispositivos = await _dispositivoRepositorio.obtenerTodos();
      if (!mounted) return;
      setState(() {
        _listaDispositivos = dispositivos;
        _estaCargando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _estaCargando = false);
    }
  }

  Future<void> _agregarDispositivo() async {
    if (!_claveFormulario.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final nuevoDispositivo = DispositivoAcceso(
      marca: _controladorMarca.text.trim(),
      tipo: _tipoDispositivo,
      ubicacion: _controladorUbicacion.text.trim().isEmpty
          ? 'Sin ubicación'
          : _controladorUbicacion.text.trim(),
      estado: _estadoDispositivo,
      serie: _controladorSerie.text.trim().isEmpty
          ? 'S/N'
          : _controladorSerie.text.trim(),
      firmware: _controladorFirmware.text.trim().isEmpty
          ? 'v1.0.0'
          : _controladorFirmware.text.trim(),
      enLinea: true,
    );

    try {
      await _dispositivoRepositorio.crear(nuevoDispositivo);
      _controladorMarca.clear();
      _controladorUbicacion.clear();
      _controladorSerie.clear();
      _controladorFirmware.clear();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: kColorVerde,
          content: Text('Dispositivo enlazado y registrado en la base de datos.'),
        ),
      );
      await _cargarDispositivos();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: kColorRojo,
          content: Text('Error al enlazar dispositivo: $e'),
        ),
      );
    }
  }

  Future<void> _alternarConexion(DispositivoAcceso d) async {
    if (d.id == null) return;
    await _dispositivoRepositorio.alternarConexion(d.id!, d.enLinea);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Dispositivo ${d.serie} ahora está ${!d.enLinea ? 'En Línea' : 'Sin Conexión'}.',
        ),
      ),
    );
    _cargarDispositivos();
  }

  Future<void> _confirmarEliminacion(DispositivoAcceso d) async {
    if (d.id == null) return;
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
          '¿Desea desvincular y eliminar el hardware "${d.marca} (${d.serie})"?',
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
      await _dispositivoRepositorio.eliminar(d.id!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dispositivo eliminado.')),
      );
      _cargarDispositivos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BarraSuperior(
        titulo: 'DISPOSITIVOS DE ACCESO',
        subtitulo: 'Control perimetral de hardware',
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
                titulo: 'FICHA DE DISPOSITIVO DE ACCESO',
                hijos: [
                  filaDosColumnas(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        etiquetaCampo('MARCA DEL DISPOSITIVO'),
                        campoTexto(
                          controlador: _controladorMarca,
                          pista: 'Ej. HID Global',
                          icono: Icons.devices_other,
                          validador: (v) => (v == null || v.trim().isEmpty)
                              ? 'Ingrese la marca'
                              : null,
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        etiquetaCampo('TIPO DE DISPOSITIVO'),
                        campoDesplegable(
                          valor: _tipoDispositivo,
                          elementos: const [
                            'Lector RFID',
                            'Torniquete',
                            'Lector Biométrico',
                            'Cerradura Electromagnética',
                          ],
                          alCambiar: (v) {
                            if (v != null) {
                              setState(() => _tipoDispositivo = v);
                            }
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
                        etiquetaCampo('UBICACIÓN FÍSICA'),
                        campoTexto(
                          controlador: _controladorUbicacion,
                          pista: 'Ej. Acceso Principal',
                          icono: Icons.place_outlined,
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        etiquetaCampo('ESTADO'),
                        campoDesplegable(
                          valor: _estadoDispositivo,
                          elementos: const [
                            'Activo',
                            'Inactivo',
                            'Mantenimiento'
                          ],
                          alCambiar: (v) {
                            if (v != null) {
                              setState(() => _estadoDispositivo = v);
                            }
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
                        etiquetaCampo('NÚMERO DE SERIE'),
                        campoTexto(
                          controlador: _controladorSerie,
                          pista: 'Ej. T-01',
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        etiquetaCampo('FIRMWARE'),
                        campoTexto(
                          controlador: _controladorFirmware,
                          pista: 'Ej. v2.4.1',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  botonPrimario(
                    'AGREGAR DISPOSITIVO',
                    icono: Icons.add_to_queue_outlined,
                    alPresionar: _agregarDispositivo,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            encabezadoSeccion(
              'DISPOSITIVOS REGISTRADOS (${_listaDispositivos.length})',
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
            else if (_listaDispositivos.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: kColorTarjeta,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: kColorBordeTarjeta),
                ),
                child: const Center(
                  child: Text(
                    'No hay dispositivos configurados en la base de datos.',
                    style: TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ),
              )
            else
              ..._listaDispositivos.map(_tarjetaDispositivo),
          ],
        ),
      ),
    );
  }

  Widget _tarjetaDispositivo(DispositivoAcceso d) {
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
          Icon(
            Icons.router,
            color: d.enLinea ? kColorVerde : kColorRojo,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${d.marca} · ${d.tipo}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${d.ubicacion} · Serie ${d.serie} (${d.firmware})',
                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => _alternarConexion(d),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: (d.enLinea ? kColorVerde : kColorRojo)
                    .withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                d.enLinea ? 'En Línea' : 'Sin Conexión',
                style: TextStyle(
                  color: d.enLinea ? kColorVerde : kColorRojo,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline,
                color: Colors.white38, size: 18),
            onPressed: () => _confirmarEliminacion(d),
          ),
        ],
      ),
    );
  }
}
