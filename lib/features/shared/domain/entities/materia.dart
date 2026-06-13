import 'package:equatable/equatable.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/area_formacion.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/carrera.dart';

class Materia extends Equatable {
  final String id;
  final String nombre;
  final Carrera carrera;
  final int semestre;
  final bool activo;
  final AreaFormacion areaFormacion;

  const Materia({
    required this.id,
    required this.nombre,
    required this.carrera,
    required this.semestre,
    required this.activo,
    required this.areaFormacion,
  });

  @override
  List<Object?> get props => [
    id,
    nombre,
    carrera,
    semestre,
    activo,
    areaFormacion,
  ];
}
