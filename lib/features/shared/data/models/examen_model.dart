// ============================================================
// NOMBRE: examen_model.dart
// USO: Modelo de datos para Examen. Parsea la respuesta de
//      Supabase con JOINs anidados (materia→carrera, salon,
//      profesor) y la convierte a la entidad de dominio.
// ============================================================

// Espera objetos anidados materia(carrera), salon y profesor de un JOIN multinivel.
import 'package:gestion_ets_escom/features/shared/data/models/materia_model.dart';
import 'package:gestion_ets_escom/features/shared/data/models/profesor_model.dart';
import 'package:gestion_ets_escom/features/shared/data/models/salon_model.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/area_formacion.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/carrera.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/examen.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/materia.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/profesor.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/salon.dart';
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

  // Parsea el JSON de Supabase y construye los sub-modelos anidados.
  factory ExamenModel.fromJson(Map<String, dynamic> json) => ExamenModel(
        id: json['id'] as String,
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

  // Parsea una fila plana del JOIN de SQLite (con alias de columnas) y reconstruye
  // todos los objetos anidados. Los alias usados coinciden con la query de
  // SharedLocalDatasourceImpl.getExamenes().
  // SQLite almacena booleanos como INTEGER (0/1).
  factory ExamenModel.fromMap(Map<String, dynamic> map) {
    // Área de formación de la materia (LEFT JOIN → puede ser null)
    final AreaFormacion? areaMateria = map['af_m_id'] != null
        ? AreaFormacion(
            id: map['af_m_id'] as String,
            nombre: map['af_m_nombre'] as String,
            color: map['af_m_color'] as String,
            activo: (map['af_m_activo'] as int) == 1,
          )
        : null;

    final carrera = Carrera(
      id: map['c_id'] as String,
      nombre: map['c_nombre'] as String,
      abreviatura: map['abreviatura'] as String,
      plan: map['plan'] as int,
      activo: (map['c_activo'] as int) == 1,
    );

    final materia = Materia(
      id: map['m_id'] as String,
      nombre: map['m_nombre'] as String,
      carrera: carrera,
      semestre: map['semestre'] as int,
      activo: (map['m_activo'] as int) == 1,
      areaFormacion: areaMateria,
    );

    final salon = Salon(
      id: map['s_id'] as String,
      edificio: map['edificio'] as int,
      piso: map['piso'] as int,
      numeroSalon: map['numero_salon'] as int,
      etiquetaSalon: map['etiqueta_salon'] as String?,
      activo: (map['s_activo'] as int) == 1,
    );

    // Área de formación del profesor (LEFT JOIN → puede ser null)
    final AreaFormacion? areaProfesor = map['af_p_id'] != null
        ? AreaFormacion(
            id: map['af_p_id'] as String,
            nombre: map['af_p_nombre'] as String,
            color: map['af_p_color'] as String,
            activo: (map['af_p_activo'] as int) == 1,
          )
        : null;

    final profesor = Profesor(
      id: map['p_id'] as String,
      nombre: map['p_nombre'] as String,
      primerApellido: map['primer_apellido'] as String,
      segundoApellido: map['segundo_apellido'] as String?,
      correo: map['correo'] as String,
      activo: (map['p_activo'] as int) == 1,
      areaFormacion: areaProfesor,
    );

    return ExamenModel(
      id: map['e_id'] as String,
      materia: materia,
      salon: salon,
      profesor: profesor,
      fecha: DateTime.parse(map['fecha'] as String),
      hora: map['hora'] as String,
      turno: Turno.fromValue(map['turno'] as String),
      documentoGuia: map['documento_guia'] as String?,
      documentoProyecto: map['documento_proyecto'] as String?,
      notas: map['notas'] as String?,
      activo: (map['e_activo'] as int) == 1,
      creadoEn: map['creado_en'] != null
          ? DateTime.parse(map['creado_en'] as String)
          : null,
      actualizadoEn: map['actualizado_en'] != null
          ? DateTime.parse(map['actualizado_en'] as String)
          : null,
    );
  }

  // Serializa el examen para inserción en la tabla examenes de SQLite.
  // Solo almacena las FKs de los objetos relacionados; esos objetos se
  // guardan por separado en sus propias tablas mediante upsertExamenes.
  Map<String, dynamic> toMap() => {
        'id': id,
        'materia_id': materia.id,
        'salon_id': salon.id,
        'profesor_id': profesor.id,
        'fecha': fecha.toIso8601String(),
        'hora': hora,
        'turno': turno.value,
        'documento_guia': documentoGuia,
        'documento_proyecto': documentoProyecto,
        'notas': notas,
        'activo': activo ? 1 : 0,
        'creado_en': creadoEn?.toIso8601String(),
        'actualizado_en': actualizadoEn?.toIso8601String(),
      };

  // Convierte el modelo a la entidad de dominio Examen.
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
