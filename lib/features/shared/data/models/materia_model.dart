

import 'package:gestion_ets_escom/features/shared/data/models/carrera_model.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/materia.dart';

class MateriaModel extends Materia {
  const MateriaModel({
    required super.id,
    required super.nombre,
    required super.carrera,
    required super.semestre,
    required super.activo,
  });

  // Expects a Supabase response with an embedded 'carrera' object from a JOIN.
  factory MateriaModel.fromJson(Map<String, dynamic> json) => MateriaModel(
        id: json['id'] as int,
        nombre: json['nombre'] as String,
        carrera: CarreraModel.fromJson(
            json['carrera'] as Map<String, dynamic>),
        semestre: json['semestre'] as int,
        activo: json['activo'] as bool,
      );

  Materia toEntity() => Materia(
        id: id,
        nombre: nombre,
        carrera: carrera,
        semestre: semestre,
        activo: activo,
      );
}
