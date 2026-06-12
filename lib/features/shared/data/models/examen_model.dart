

// Expects a Supabase response with nested materia(carrera), salon, and profesor
// objects from a multi-level JOIN.
import 'package:gestion_ets_escom/features/shared/data/models/materia_model.dart';
import 'package:gestion_ets_escom/features/shared/data/models/profesor_model.dart';
import 'package:gestion_ets_escom/features/shared/data/models/salon_model.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/examen.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/turno.dart';

class ExamenModel extends Examen {
  const ExamenModel({
    required super.id,
    required super.materia,
    required super.salon,
    required super.profesor,
    required super.fecha,
    required super.hora,
    required super.turno,
    super.documentoGuia,
    super.documentoProyecto,
    super.notas,
    required super.activo,
    super.creadoEn,
    super.actualizadoEn,
  });

  factory ExamenModel.fromJson(Map<String, dynamic> json) => ExamenModel(
        id: json['id'] as int,
        materia:
            MateriaModel.fromJson(json['materia'] as Map<String, dynamic>),
        salon: SalonModel.fromJson(json['salon'] as Map<String, dynamic>),
        profesor:
            ProfesorModel.fromJson(json['profesor'] as Map<String, dynamic>),
        fecha: DateTime.parse(json['fecha'] as String),
        hora: json['hora'] as String,
        turno: Turno.fromValue(json['turno'] as String),
        documentoGuia: json['documento_guia'] as String?,
        documentoProyecto: json['documento_proyecto'] as String?,
        notas: json['notas'] as String?,
        activo: json['activo'] as bool,
        creadoEn: json['creado_en'] != null
            ? DateTime.parse(json['creado_en'] as String)
            : null,
        actualizadoEn: json['actualizado_en'] != null
            ? DateTime.parse(json['actualizado_en'] as String)
            : null,
      );

  Examen toEntity() => Examen(
        id: id,
        materia: materia,
        salon: salon,
        profesor: profesor,
        fecha: fecha,
        hora: hora,
        turno: turno,
        documentoGuia: documentoGuia,
        documentoProyecto: documentoProyecto,
        notas: notas,
        activo: activo,
        creadoEn: creadoEn,
        actualizadoEn: actualizadoEn,
      );
}
