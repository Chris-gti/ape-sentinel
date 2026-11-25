import 'package:flutter/material.dart';
import '../tema/colores.dart';

// ============================================================================
// COMPONENTES REUTILIZABLES DE FORMULARIO E INTERFAZ
// ============================================================================

/// Etiqueta superior para campos de entrada
Widget etiquetaCampo(String texto) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: Text(
      texto,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
      ),
    ),
  );
}

/// Campo de texto estilizado para formularios
Widget campoTexto({
  String? pista,
  TextEditingController? controlador,
  IconData? icono,
  TextInputType? tipoTeclado,
  int maxLineas = 1,
  bool soloLectura = false,
  String? valorInicial,
  TextAlignVertical? alineacionVertical,
  String? Function(String?)? validador,
  ValueChanged<String>? alCambiar,
}) {
  return TextFormField(
    controller: controlador,
    keyboardType: tipoTeclado,
    maxLines: maxLineas,
    readOnly: soloLectura,
    initialValue: valorInicial,
    validator: validador,
    onChanged: alCambiar,
    style: TextStyle(
      color: soloLectura ? Colors.grey.shade700 : Colors.black87,
      fontSize: 12,
    ),
    textAlignVertical: alineacionVertical,
    cursorColor: kColorNaranja,
    decoration: InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintText: pista,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
      prefixIcon: icono != null
          ? Icon(icono, color: Colors.grey.shade600, size: 15)
          : null,
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide.none,
      ),
      isDense: true,
    ),
  );
}

/// Selector desplegable estilizado
Widget campoDesplegable({
  required String valor,
  required List<String> elementos,
  required ValueChanged<String?> alCambiar,
}) {
  return Container(
    height: 40,
    padding: const EdgeInsets.symmetric(horizontal: 10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(6),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: valor,
        isExpanded: true,
        dropdownColor: Colors.white,
        icon: Icon(
          Icons.keyboard_arrow_down,
          color: Colors.grey.shade600,
          size: 18,
        ),
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        items: elementos
            .map((item) => DropdownMenuItem(
                  value: item,
                  child: Text(item),
                ))
            .toList(),
        onChanged: alCambiar,
      ),
    ),
  );
}

/// Distribuidor de dos columnas paralelas
Widget filaDosColumnas(Widget columnaA, Widget columnaB) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(child: columnaA),
      const SizedBox(width: 10),
      Expanded(child: columnaB),
    ],
  );
}

/// Contenedor en tarjeta para formularios técnicos
Widget tarjetaFormulario({
  required String titulo,
  required List<Widget> hijos,
}) {
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: kColorTarjeta,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: kColorNaranja.withValues(alpha: 0.35)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(Icons.edit_note, color: kColorNaranja, size: 16),
            const SizedBox(width: 6),
            Text(
              titulo,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...hijos,
      ],
    ),
  );
}

/// Botón de acción principal con el color institucional naranja
Widget botonPrimario(
  String texto, {
  IconData? icono,
  required VoidCallback alPresionar,
  bool cargando = false,
}) {
  return SizedBox(
    height: 38,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: kColorNaranja,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      onPressed: cargando ? null : alPresionar,
      child: cargando
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icono case final icono?) ...[
                  Icon(icono, size: 15, color: Colors.white),
                  const SizedBox(width: 6),
                ],
                Text(
                  texto,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
    ),
  );
}

/// Botón secundario con estilo transparente y borde sutil
Widget botonSecundario(
  String texto, {
  required VoidCallback alPresionar,
}) {
  return SizedBox(
    height: 38,
    child: OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white70,
        side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
      ),
      onPressed: alPresionar,
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    ),
  );
}

/// Encabezado de sección con opción de widget derecho
Widget encabezadoSeccion(String texto, {Widget? accionDerecha}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8, top: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          texto,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.white54,
          ),
        ),
        ?accionDerecha,
      ],
    ),
  );
}

/// Insignia o chip para estados
Widget insigniaEstado(String texto, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: color.withValues(alpha: 0.4)),
    ),
    child: Text(
      texto,
      style: TextStyle(
        color: color,
        fontSize: 9,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
