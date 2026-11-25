import 'package:flutter/material.dart';
import '../datos/repositorios/evento_bitacora_repositorio.dart';
import '../datos/repositorios/personal_repositorio.dart';
import '../datos/repositorios/planta_zona_repositorio.dart';
import '../modelos/evento_bitacora.dart';
import '../tema/colores.dart';
import '../widgets/barra_navegacion.dart';
import '../widgets/barra_superior.dart';
import '../widgets/componentes_formulario.dart';
import '../widgets/transicion_suave.dart';
import 'bitacora_pantalla.dart';
import 'dispositivos_acceso_pantalla.dart';
import 'login_pantalla.dart';
import 'metodos_acceso_pantalla.dart';
import 'permisos_trabajo_pantalla.dart';
import 'personal_pantalla.dart';
import 'plantas_zonas_pantalla.dart';

// ============================================================================
// PANTALLA: PANEL DE CONTROL (DASHBOARD DINÁMICO CON SQLITE)
// ============================================================================

class PanelControlPantalla extends StatefulWidget {
  const PanelControlPantalla({super.key});

  @override
  State<PanelControlPantalla> createState() => _PanelControlPantallaState();
}

class _PanelControlPantallaState extends State<PanelControlPantalla> {
  final _plantaZonaRepositorio = PlantaZonaRepositorio();
  final _personalRepositorio = PersonalRepositorio();
  final _bitacoraRepositorio = EventoBitacoraRepositorio();

  int _totalPlantas = 0;
  int _totalPersonalActivo = 0;
  int _totalAlertasAcceso = 0;
  List<EventoBitacora> _ultimosEventos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _cargando = true);
    try {
      final plantas = await _plantaZonaRepositorio.contarTotal();
      final personalActivo = await _personalRepositorio.contarActivos();
      final denegados = await _bitacoraRepositorio.contarPorTipo('DENEGADO');
      final eventos = await _bitacoraRepositorio.obtenerRecientes(3);

      if (!mounted) return;
      setState(() {
        _totalPlantas = plantas;
        _totalPersonalActivo = personalActivo;
        _totalAlertasAcceso = denegados;
        _ultimosEventos = eventos;
        _cargando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _cargando = false);
    }
  }

  String _obtenerHoraActual() {
    final d = DateTime.now();
    final hora = d.hour.toString().padLeft(2, '0');
    final minuto = d.minute.toString().padLeft(2, '0');
    return 'Hoy, $hora:$minuto';
  }

  void _cambiarPestana(int indice) {
    if (indice == 0) return;
    Widget pantallaDestino;
    if (indice == 1) {
      pantallaDestino = const PersonalPantalla();
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
      appBar: BarraSuperior(
        titulo: 'PANEL DE CONTROL',
        subtitulo: _obtenerHoraActual(),
        acciones: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
              size: 18,
              color: Colors.white70,
            ),
            onPressed: _cargarDatos,
          ),
          IconButton(
            icon: const Icon(
              Icons.logout,
              size: 16,
              color: Colors.white70,
            ),
            onPressed: () => Navigator.pushReplacement(
              context,
              TransicionSuave(pantalla: const LoginPantalla()),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BarraNavegacion(
        indiceActual: 0,
        alSeleccionar: _cambiarPestana,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: kColorNaranja,
          onRefresh: _cargarDatos,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            children: [
              // 3 Métricas en tiempo real desde SQLite
              Row(
                children: [
                  Expanded(
                    child: _tarjetaMetrica(
                      valor: _cargando ? '...' : '$_totalPlantas',
                      etiqueta: 'Plantas / Zonas',
                      icono: Icons.domain,
                      colorTendencia: kColorVerde,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _tarjetaMetrica(
                      valor: _cargando ? '...' : '$_totalPersonalActivo',
                      etiqueta: 'Usuarios Activos',
                      icono: Icons.people,
                      colorTendencia: kColorVerde,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _tarjetaMetrica(
                      valor: _cargando ? '...' : '$_totalAlertasAcceso',
                      etiqueta: 'Alertas de Acceso',
                      icono: Icons.warning_amber_rounded,
                      colorTendencia: kColorNaranjaClaro,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // Últimos Eventos de Acceso (3 más recientes)
              encabezadoSeccion(
                'ÚLTIMOS EVENTOS DE ACCESO',
                accionDerecha: TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () => _cambiarPestana(2),
                  child: const Text(
                    'VER TODO',
                    style: TextStyle(
                      color: kColorNaranja,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
              if (_cargando)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: kColorNaranja,
                    ),
                  ),
                )
              else if (_ultimosEventos.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kColorTarjeta,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: kColorBordeTarjeta),
                  ),
                  child: const Center(
                    child: Text(
                      'No hay eventos recientes asentados en bitácora.',
                      style: TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                  ),
                )
              else
                ..._ultimosEventos.map(_elementoEvento),

              const SizedBox(height: 22),

              // Módulos del Sistema
              encabezadoSeccion('MÓDULOS DEL SISTEMA'),
              _elementoModulo(
                titulo: 'GESTIÓN DE PERSONAL',
                subtitulo: 'Acceso y auditoría de personal',
                icono: Icons.badge_outlined,
                alPresionar: () => _cambiarPestana(1),
              ),
              _elementoModulo(
                titulo: 'GESTIÓN DE PLANTAS / ZONAS',
                subtitulo: 'Acceso y auditoría de zonas',
                icono: Icons.domain_outlined,
                alPresionar: () async {
                  await Navigator.push(
                    context,
                    TransicionSuave(pantalla: const PlantasZonasPantalla()),
                  );
                  _cargarDatos();
                },
              ),
              _elementoModulo(
                titulo: 'PERMISOS DE TRABAJO',
                subtitulo: 'Acceso y auditoría de permisos',
                icono: Icons.assignment_outlined,
                alPresionar: () => Navigator.push(
                  context,
                  TransicionSuave(pantalla: const PermisosTrabajoPantalla()),
                ),
              ),
              _elementoModulo(
                titulo: 'DISPOSITIVOS DE ACCESO',
                subtitulo: 'Acceso y auditoría de hardware',
                icono: Icons.phonelink_setup_outlined,
                alPresionar: () => Navigator.push(
                  context,
                  TransicionSuave(pantalla: const DispositivosAccesoPantalla()),
                ),
              ),
              _elementoModulo(
                titulo: 'MÉTODOS DE ACCESO',
                subtitulo: 'Acceso y auditoría de biometría',
                icono: Icons.fingerprint,
                alPresionar: () => Navigator.push(
                  context,
                  TransicionSuave(pantalla: const MetodosAccesoPantalla()),
                ),
              ),
              _elementoModulo(
                titulo: 'REGISTRO DE ENTRADA / SALIDA',
                subtitulo: 'Acceso y auditoría de logs',
                icono: Icons.access_time_outlined,
                alPresionar: () => _cambiarPestana(2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tarjetaMetrica({
    required String valor,
    required String etiqueta,
    required IconData icono,
    required Color colorTendencia,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kColorTarjeta,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kColorBordeTarjeta),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icono, color: kColorNaranja, size: 16),
              Icon(Icons.trending_up, color: colorTendencia, size: 12),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            valor,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            etiqueta,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 9.5,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _elementoEvento(EventoBitacora evento) {
    Color color = kColorVerde;
    IconData icono = Icons.login;

    if (evento.tipo == 'SALIDA') {
      color = kColorNaranjaClaro;
      icono = Icons.logout;
    } else if (evento.tipo == 'DENEGADO') {
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
          Icon(icono, color: color, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  evento.persona,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  evento.zona,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                evento.tipo,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                evento.fechaHora,
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 9.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _elementoModulo({
    required String titulo,
    required String subtitulo,
    required IconData icono,
    required VoidCallback alPresionar,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: kColorTarjeta,
        borderRadius: BorderRadius.circular(10),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          splashColor: kColorNaranja.withValues(alpha: 0.15),
          onTap: alPresionar,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: kColorBordeTarjeta),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: kColorNaranja.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icono, color: kColorNaranja, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.7,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        subtitulo,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white38,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 11,
                  color: Colors.white24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
