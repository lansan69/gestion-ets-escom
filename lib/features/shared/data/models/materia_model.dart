// ============================================================
// NOMBRE: materia_model.dart
// USO: Modelo de datos para Materia. Parsea la respuesta de
//      Supabase con JOINs de carrera y area_formacion y la
//      convierte a la entidad de dominio.
// ============================================================
import 'package:gestion_ets_escom/features/shared/data/models/area_model.dart';
import 'package:gestion_ets_escom/features/shared/data/models/carrera_model.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/materia.dart';

class MateriaModel extends Materia {
  const MateriaModel({
    required super.id,
    required super.nombre,
    required super.carrera,
    required super.semestre,
    required super.activo,
    super.areaFormacion,
  });

  // Espera objetos anidados 'carrera' y opcionalmente 'area_formacion' de un JOIN en Supabase.
  factory MateriaModel.fromJson(Map<String, dynamic> json) => MateriaModel(
        id: json['id'] as String,
        nombre: json['nombre'] as String,
        carrera: CarreraModel.fromJson(json['carrera'] as Map<String, dynamic>),
        semestre: json['semestre'] as int,
        activo: json['activo'] as bool,
        areaFormacion: json['area_formacion'] != null
            ? AreaFormacionModel.fromJson(
                json['area_formacion'] as Map<String, dynamic>)
            : null,
      );

  // Serializa para INSERT/UPDATE en Supabase usando IDs de FK (no objetos anidados).
  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'carrera_id': carrera.id,
    'semestre': semestre,
    'activo': activo,
    'area_formacion_id': areaFormacion?.id,
  };

  // Convierte el modelo a la entidad de dominio Materia.
  Materia toEntity() => Materia(
        id: id,
        nombre: nombre,
        carrera: carrera,
        semestre: semestre,
        activo: activo,
        areaFormacion: areaFormacion,
      );
}
