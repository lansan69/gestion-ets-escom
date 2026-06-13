// ============================================================
// NOMBRE: turno.dart
// USO: Enum que representa el turno de un examen (matutino,
//      vespertino, nocturno). Consumido por Examen y ExamenModel.
// ============================================================

enum Turno {
  matutino('MATUTINO'),
  vespertino('VESPERTINO'),
  nocturno('NOCTURNO');

  const Turno(this.value);
  final String value;

  // Parsea un string (p.ej. 'MATUTINO') al enum correspondiente.
  static Turno fromValue(String v) =>
      Turno.values.firstWhere((t) => t.value == v.toUpperCase());
}
