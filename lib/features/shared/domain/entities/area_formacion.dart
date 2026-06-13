// ============================================================
// NOMBRE: area_formacion.dart
// USO: Entidad de dominio que representa el área de formación
//      de una materia o profesor (Básica, Profesional, Terminal).
//      Consumida por Materia y Profesor.
// ============================================================
import 'package:equatable/equatable.dart';

class AreaFormacion extends Equatable {
  final String id;
  final String nombre;
  final String color;
  final bool activo;

  const AreaFormacion({
    required this.id,
    required this.nombre,
    required this.color,
    required this.activo,
  });

  @override
  List<Object?> get props => [id, nombre, color, activo];
}
