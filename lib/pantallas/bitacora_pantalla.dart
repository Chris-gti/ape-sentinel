import 'package:flutter/material.dart';
import '../datos/repositorios/evento_bitacora_repositorio.dart';
import '../modelos/evento_bitacora.dart';
import '../tema/colores.dart';
import '../widgets/barra_navegacion.dart';
import '../widgets/barra_superior.dart';
import '../widgets/componentes_formulario.dart';
import '../widgets/transicion_suave.dart';
import 'panel_control_pantalla.dart';
import 'personal_pantalla.dart';

// ============================================================================
// PANTALLA: BITÁCORA / LOGS DE AUDITORÍA (CRUD Y FILTROS CON SQLITE)
// ============================================================================

class BitacoraPantalla extends StatefulWidget {
  const BitacoraPantalla({super.key});

  @override
  State<BitacoraPantalla> createState() => _BitacoraPantallaState();
}

class _BitacoraPantallaState extends State<BitacoraPantalla> {
  final _bitacoraRepositorio = EventoBitacoraRepositorio();

  List<EventoBitacora> _listaEventos = [];
  bool _estaCargando = true;
  String _filtroTipo = 'TODOS';

  @override
  void initState() {
    super.initState();
    _cargarEventos();
  }

  Future<void> _cargarEventos() async {
    setState(() => _estaCargando = true);
    try {
      final eventos = await _bitacoraRepositorio.obtenerTodos(
        filtroTipo: _filtroTipo,
      );
      if (!mounted) return;
      setState(() {
        _listaEventos = eventos;
        _estaCargando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _estaCargando = false);
    }
  }

  void _cambiarFiltro(String nuevoFiltro) {
    if (_filtroTipo == nuevoFiltro) return;
    setState(() => _filtroTipo = nuevoFiltro);
    _cargarEventos();
  }

  void _mostrarModalRegistroManual() {
    final controladorPersona = TextEditingController();
    final controladorZona = TextEditingController();
    final claveModal = GlobalKey<FormState>();
    String tipoSeleccionado = 'ENTRADA';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF161616),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModal) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Form(
            key: claveModal,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                tarjetaFormulario(
                  titulo: 'REGISTRO MANUAL DE EVENTO',
                  hijos: [
                    etiquetaCampo('NOMBRE / OPERADOR'),
                    campoTexto(
                      controlador: controladorPersona,
                      pista: 'Ej. Fernando Castillo',
                      icono: Icons.person_outline,
                      validador: (v) => (v == null || v.trim().isEmpty)
                          ? 'Ingrese el nombre del operador'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    etiquetaCampo('ZONA / COMPUERTA'),
                    campoTexto(
                      controlador: controladorZona,
                      pista: 'Ej. Torniquete Norte 02',
                      icono: Icons.door_front_door_outlined,
                      validador: (v) => (v == null || v.trim().isEmpty)
                          ? 'Ingrese la ubicación o compuerta'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    etiquetaCampo('TIPO DE EVENTO'),
                    campoDesplegable(
                      valor: tipoSeleccionado,
                      elementos: const ['ENTRADA', 'SALIDA', 'DENEGADO'],
                      alCambiar: (v) {
                        if (v != null) {
                          setModal(() => tipoSeleccionado = v);
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                    botonPrimario(
                      'ASENTAR EN BITÁCORA',
                      icono: Icons.post_add,
                      alPresionar: () async {
                        if (!claveModal.currentState!.validate()) return;
                        final ahora = DateTime.now();
                        final horaFormateada =
                            '${ahora.hour.toString().padLeft(2, '0')}:${ahora.minute.toString().padLeft(2, '0')}:${ahora.second.toString().padLeft(2, '0')}';

                        final nuevoEvento = EventoBitacora(
                          fechaHora: horaFormateada,
                          persona: controladorPersona.text.trim(),
                          tipo: tipoSeleccionado,
                          zona: controladorZona.text.trim(),
                        );

                        await _bitacoraRepositorio.crear(nuevoEvento);
                        if (!ctx.mounted) return;
                        Navigator.pop(ctx);
                        _cargarEventos();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).whenComplete(() {
      controladorPersona.dispose();
      controladorZona.dispose();
    });
  }

  Future<void> _confirmarEliminacion(EventoBitacora e) async {
    if (e.id == null) return;
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
          '¿Desea purgar este evento de bitácora (${e.persona} - ${e.tipo})?',
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
      await _bitacoraRepositorio.eliminar(e.id!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Evento eliminado de la bitácora.')),
      );
      _cargarEventos();
    }
  }

  void _cambiarPestana(int indice) {
    if (indice == 2) return;
    Widget pantallaDestino;
    if (indice == 0) {
      pantallaDestino = const PanelControlPantalla();
    } else {
      pantallaDestino = const PersonalPantalla();
    }
    Navigator.pushReplacement(
      context,
      TransicionSuave(pantalla: pantallaDestino),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BarraSuperior(
        titulo: 'REGISTRO DE ENTRADA / SALIDA',
        subtitulo: 'Bitácora de auditoría en tiempo real',
        acciones: [
          IconButton(
            icon: const Icon(Icons.post_add, size: 18, color: Colors.white70),
            onPressed: _mostrarModalRegistroManual,
          ),
        ],
      ),
      bottomNavigationBar: BarraNavegacion(
        indiceActual: 2,
        alSeleccionar: _cambiarPestana,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          physics: const BouncingScrollPhysics(),
          children: [
            // Barra de Filtros Rápidos (TODOS, ENTRADA, SALIDA, DENEGADO)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _chipFiltro('TODOS', Icons.all_inclusive),
                  const SizedBox(width: 8),
                  _chipFiltro('ENTRADA', Icons.login, color: kColorVerde),
                  const SizedBox(width: 8),
                  _chipFiltro('SALIDA', Icons.logout,
                      color: kColorNaranjaClaro),
                  const SizedBox(width: 8),
                  _chipFiltro('DENEGADO', Icons.block, color: kColorRojo),
                ],
              ),
            ),
            const SizedBox(height: 14),

            encabezadoSeccion(
              'EVENTOS AUDITADOS (${_listaEventos.length})',
              accionDerecha: SizedBox(
                height: 28,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kColorNaranja,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  icon: const Icon(Icons.post_add, size: 14, color: Colors.white),
                  label: const Text(
                    'MANUAL',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: _mostrarModalRegistroManual,
                ),
              ),
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
            else if (_listaEventos.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: kColorTarjeta,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: kColorBordeTarjeta),
                ),
                child: Center(
                  child: Text(
                    _filtroTipo == 'TODOS'
                        ? 'No hay registros en la bitácora.'
                        : 'No hay eventos de tipo "$_filtroTipo".',
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ),
              )
            else
              ..._listaEventos.map(_tarjetaEvento),
          ],
        ),
      ),
    );
  }

  Widget _chipFiltro(String tipo, IconData icono, {Color? color}) {
    final seleccionado = _filtroTipo == tipo;
    final colorEfectivo = color ?? kColorNaranja;

    return InkWell(
      onTap: () => _cambiarFiltro(tipo),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: seleccionado
              ? colorEfectivo.withValues(alpha: 0.25)
              : kColorTarjeta,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: seleccionado ? colorEfectivo : kColorBordeTarjeta,
            width: seleccionado ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icono,
              size: 13,
              color: seleccionado ? colorEfectivo : Colors.white60,
            ),
            const SizedBox(width: 5),
            Text(
              tipo,
              style: TextStyle(
                color: seleccionado ? Colors.white : Colors.white60,
                fontSize: 10,
                fontWeight:
                    seleccionado ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tarjetaEvento(EventoBitacora log) {
    Color color = kColorVerde;
    IconData icono = Icons.login;

    if (log.tipo == 'SALIDA') {
      color = kColorNaranjaClaro;
      icono = Icons.logout;
    } else if (log.tipo == 'DENEGADO') {
      color = kColorRojo;
      icono = Icons.block;
    }

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
          Icon(icono, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.persona,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${log.zona} · ${log.fechaHora}',
                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                ),
              ],
            ),
          ),
          Text(
            log.tipo,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline,
                color: Colors.white24, size: 16),
            onPressed: () => _confirmarEliminacion(log),
          ),
        ],
      ),
    );
  }
}
