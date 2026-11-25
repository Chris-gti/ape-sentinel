import 'package:flutter/material.dart';
import '../datos/repositorios/usuario_repositorio.dart';
import '../modelos/usuario.dart';
import '../tema/colores.dart';
import '../widgets/componentes_formulario.dart';
import '../widgets/transicion_suave.dart';
import 'panel_control_pantalla.dart';

// ============================================================================
// PANTALLA: INICIO DE SESIÓN / REGISTRO DEL PRIMER USUARIO
// ============================================================================

class LoginPantalla extends StatefulWidget {
  const LoginPantalla({super.key});

  @override
  State<LoginPantalla> createState() => _LoginPantallaState();
}

class _LoginPantallaState extends State<LoginPantalla> {
  final _claveFormulario = GlobalKey<FormState>();
  final _controladorNombre = TextEditingController();
  final _controladorFicha = TextEditingController();
  final _controladorContrasena = TextEditingController();
  final _controladorConfirmarContrasena = TextEditingController();
  final _usuarioRepositorio = UsuarioRepositorio();

  bool _ocultarContrasena = true;
  bool _ocultarConfirmar = true;
  bool _estaCargando = false;
  bool _modoPrimerUsuario = true; // Inicia de 0 por defecto como nuevo primer usuario

  @override
  void initState() {
    super.initState();
    _verificarUsuariosRegistrados();
  }

  @override
  void dispose() {
    _controladorNombre.dispose();
    _controladorFicha.dispose();
    _controladorContrasena.dispose();
    _controladorConfirmarContrasena.dispose();
    super.dispose();
  }

  Future<void> _verificarUsuariosRegistrados() async {
    try {
      final existen = await _usuarioRepositorio.existenUsuarios();
      if (!mounted) return;
      setState(() {
        _modoPrimerUsuario = !existen;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _modoPrimerUsuario = true;
      });
    }
  }

  Future<void> _iniciarSesion() async {
    if (!_claveFormulario.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    setState(() => _estaCargando = true);

    try {
      final usuario = await _usuarioRepositorio.autenticar(
        _controladorFicha.text,
        _controladorContrasena.text,
      );

      if (!mounted) return;

      if (usuario != null) {
        Navigator.pushReplacement(
          context,
          TransicionSuave(pantalla: const PanelControlPantalla()),
        );
      } else {
        setState(() => _estaCargando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: kColorRojo,
            content: Text(
              'Credenciales inválidas o usuario inactivo. Verifique su ficha y contraseña.',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _estaCargando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: kColorRojo,
          content: Text('Error al conectar con la base de datos: $e'),
        ),
      );
    }
  }

  Future<void> _registrarPrimerUsuario() async {
    if (!_claveFormulario.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    setState(() => _estaCargando = true);

    try {
      final nuevoAdministrador = Usuario(
        nombre: _controladorNombre.text.trim(),
        ficha: _controladorFicha.text.trim(),
        contrasena: _controladorContrasena.text.trim(),
        rol: 'Super Administrador',
        activo: true,
      );

      await _usuarioRepositorio.crear(nuevoAdministrador);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: kColorVerde,
          content: Text(
            '¡Administrador "${nuevoAdministrador.nombre}" registrado con éxito! Bienvenido al sistema.',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      );

      Navigator.pushReplacement(
        context,
        TransicionSuave(pantalla: const PanelControlPantalla()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _estaCargando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: kColorRojo,
          content: Text('Error al registrar administrador inicial: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Form(
              key: _claveFormulario,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: kColorNaranja.withValues(alpha: 0.6),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: kColorNaranja.withValues(alpha: 0.25),
                            blurRadius: 18,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        _modoPrimerUsuario
                            ? Icons.admin_panel_settings_outlined
                            : Icons.shield_outlined,
                        size: 36,
                        color: kColorNaranja,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'APESENTINEL',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      letterSpacing: 2.5,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _modoPrimerUsuario
                        ? 'CONFIGURACIÓN INICIAL / PRIMER USUARIO'
                        : 'SISTEMA DE CONTROL Y ACCESO',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 9.5,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w600,
                      color: _modoPrimerUsuario
                          ? kColorNaranja
                          : Colors.white.withValues(alpha: 0.45),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Mensaje orientativo en caso de ser el primer usuario
                  if (_modoPrimerUsuario) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: kColorTarjeta,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: kColorNaranja.withValues(alpha: 0.35),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, color: kColorNaranja, size: 18),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'El sistema no tiene usuarios registrados. Configure las credenciales del Administrador para inicializar.',
                              style: TextStyle(color: Colors.white70, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    etiquetaCampo('NOMBRE COMPLETO DEL ADMINISTRADOR'),
                    campoTexto(
                      controlador: _controladorNombre,
                      pista: 'Ej. Administrador General',
                      icono: Icons.badge_outlined,
                      validador: (v) => (v == null || v.trim().isEmpty)
                          ? 'Ingrese el nombre completo'
                          : null,
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Campo de usuario o ficha
                  etiquetaCampo('USUARIO / FICHA'),
                  campoTexto(
                    controlador: _controladorFicha,
                    pista: _modoPrimerUsuario ? 'Ej. 1001 o admin' : 'Ej. Ficha de empleado',
                    icono: Icons.person_outline,
                    tipoTeclado: TextInputType.text,
                    validador: (v) => (v == null || v.trim().isEmpty)
                        ? 'Ingrese su número de ficha o usuario'
                        : null,
                  ),
                  const SizedBox(height: 14),

                  // Campo de contraseña
                  etiquetaCampo('CONTRASEÑA'),
                  TextFormField(
                    controller: _controladorContrasena,
                    obscureText: _ocultarContrasena,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 13,
                    ),
                    cursorColor: kColorNaranja,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: '••••••••',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 12,
                      ),
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: Colors.grey.shade600,
                        size: 16,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _ocultarContrasena
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey.shade600,
                          size: 18,
                        ),
                        onPressed: () => setState(
                          () => _ocultarContrasena = !_ocultarContrasena,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide.none,
                      ),
                      isDense: true,
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Ingrese su contraseña';
                      }
                      if (_modoPrimerUsuario && v.length < 4) {
                        return 'La contraseña debe tener al menos 4 caracteres';
                      }
                      return null;
                    },
                  ),

                  // Campo de confirmación si es el primer usuario
                  if (_modoPrimerUsuario) ...[
                    const SizedBox(height: 14),
                    etiquetaCampo('CONFIRMAR CONTRASEÑA'),
                    TextFormField(
                      controller: _controladorConfirmarContrasena,
                      obscureText: _ocultarConfirmar,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 13,
                      ),
                      cursorColor: kColorNaranja,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: '••••••••',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 12,
                        ),
                        prefixIcon: Icon(
                          Icons.lock_reset,
                          color: Colors.grey.shade600,
                          size: 16,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _ocultarConfirmar
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey.shade600,
                            size: 18,
                          ),
                          onPressed: () => setState(
                            () => _ocultarConfirmar = !_ocultarConfirmar,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide.none,
                        ),
                        isDense: true,
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Confirme su contraseña';
                        }
                        if (v != _controladorContrasena.text) {
                          return 'Las contraseñas no coinciden';
                        }
                        return null;
                      },
                    ),
                  ],

                  if (!_modoPrimerUsuario) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Contacte al administrador de turno para restablecer su clave.',
                              ),
                            ),
                          );
                        },
                        child: Text(
                          '¿Olvidó su contraseña?',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 11,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kColorNaranja,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _estaCargando
                          ? null
                          : (_modoPrimerUsuario
                              ? _registrarPrimerUsuario
                              : _iniciarSesion),
                      child: _estaCargando
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _modoPrimerUsuario
                                      ? Icons.person_add_alt_1
                                      : Icons.login,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _modoPrimerUsuario
                                      ? 'CREAR ADMINISTRADOR E INICIAR'
                                      : 'INGRESAR AL SISTEMA',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
