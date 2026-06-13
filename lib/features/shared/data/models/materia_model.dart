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
    required super.areaFormacion,
  });

  // Espera objetos anidados 'carrera' y 'area_formacion' de un JOIN en Supabase.
  factory MateriaModel.fromJson(Map<String, dynamic> json) => MateriaModel(
        id: json['id'] as String,
        nombre: json['nombre'] as String,
        carrera: CarreraModel.fromJson(json['carrera'] as Map<String, dynamic>),
        semestre: json['semestre'] as int,
        activo: json['activo'] as bool,
        areaFormacion: AreaFormacionModel.fromJson(
            json['area_formacion'] as Map<String, dynamic>),
      );

  Materia toEntity() => Materia(
        id: id,
        nombre: nombre,
        carrera: carrera,
        semestre: semestre,
        activo: activo,
        areaFormacion: areaFormacion,
      );
}
