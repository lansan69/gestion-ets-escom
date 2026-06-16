// ============================================================
// NOMBRE: examen_update_params.dart
// USO: Parámetros para la actualización completa de un examen ETS.
//      Toca tres tablas en paralelo: examen, materia y profesor.
// ============================================================

class ExamenUpdateParams {
  final String examenId;
  final String materiaId;
  final String carreraId;
  final String? areaFormacionId; // null = sin área (limpia la FK)
  final String profesorId;
  final String salonId;
  final DateTime fecha;
  final String hora;
  final String? documentoGuia;
  final String? documentoProyecto;
  final String? notas;

  const ExamenUpdateParams({
    required this.examenId,
    required this.materiaId,
    required this.carreraId,
    this.areaFormacionId,
    required this.profesorId,
    required this.salonId,
    required this.fecha,
    required this.hora,
    this.documentoGuia,
    this.documentoProyecto,
    this.notas,
  });
}
