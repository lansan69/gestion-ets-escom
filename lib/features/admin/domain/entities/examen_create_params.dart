import 'package:gestion_ets_escom/features/shared/domain/entities/turno.dart';

class ExamenCreateParams {
  final String materiaId;
  final String salonId;
  final String profesorId;
  final DateTime fecha;
  final String hora;
  final Turno turno;
  final String? documentoGuia;
  final String? documentoProyecto;
  final String? notas;

  const ExamenCreateParams({
    required this.materiaId,
    required this.salonId,
    required this.profesorId,
    required this.fecha,
    required this.hora,
    required this.turno,
    this.documentoGuia,
    this.documentoProyecto,
    this.notas,
  });
}
