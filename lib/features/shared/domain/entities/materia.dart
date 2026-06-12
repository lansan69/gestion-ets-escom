import 'package:equatable/equatable.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/carrera.dart';

class Materia extends Equatable {
  final int id;
  final String nombre;
  final Carrera carrera;
  final int semestre;
  final bool activo;

  const Materia({
    required this.id,
    required this.nombre,
    required this.carrera,
    required this.semestre,
    required this.activo,
  });

  @override
  List<Object?> get props => [id, nombre, carrera, semestre, activo];
}
