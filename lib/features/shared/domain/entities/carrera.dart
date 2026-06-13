// ============================================================
// NOMBRE: carrera.dart
// USO: Entidad de dominio que representa una carrera del ESCOM.
//      Consumida por Materia, SharedRepository y los providers
//      de carrera.
// ============================================================
import 'package:equatable/equatable.dart';

class Carrera extends Equatable {
  final String id;
  final String nombre;
  final String abreviatura;
  final int plan;
  final bool activo;

  const Carrera({
    required this.id,
    required this.nombre,
    required this.abreviatura,
    required this.plan,
    required this.activo,
  });

  @override
  List<Object?> get props => [id, nombre, abreviatura, plan, activo];
}
