import 'package:equatable/equatable.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/materia.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/profesor.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/salon.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/turno.dart';


class Examen extends Equatable {
  final String id;
  final Materia materia;
  final Salon salon;
  final Profesor profesor;
  final DateTime fecha;
  final String hora;
  final Turno turno;
  final String? documentoGuia;
  final String? documentoProyecto;
  final String? notas;
  final bool activo;
  final DateTime? creadoEn;
  final DateTime? actualizadoEn;

  const Examen({
    required this.id,
    required this.materia,
    required this.salon,
    required this.profesor,
    required this.fecha,
    required this.hora,
    required this.turno,
    this.documentoGuia,
    this.documentoProyecto,
    this.notas,
    required this.activo,
    this.creadoEn,
    this.actualizadoEn,
  });

  @override
  List<Object?> get props => [
        id,
        materia,
        salon,
        profesor,
        fecha,
        hora,
        turno,
        documentoGuia,
        documentoProyecto,
        notas,
        activo,
        creadoEn,
        actualizadoEn,
      ];
}
