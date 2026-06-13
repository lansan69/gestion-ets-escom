// ============================================================
// NOMBRE: profesor.dart
// USO: Entidad de dominio que representa a un profesor coordinador
//      de examen ETS. Consumida por Examen y CardExamenMateria.
// ============================================================
import 'package:equatable/equatable.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/area_formacion.dart';

class Profesor extends Equatable {
  final String id;
  final String nombre;
  final String primerApellido;
  final String? segundoApellido;
  final String correo;
  final bool activo;
  final AreaFormacion? areaFormacion;

  const Profesor({
    required this.id,
    required this.nombre,
    required this.primerApellido,
    this.segundoApellido,
    required this.correo,
    required this.activo,
    this.areaFormacion,
  });

  // Retorna el nombre completo con uno o dos apellidos según disponibilidad.
  String get nombreCompleto => segundoApellido != null
      ? '$nombre $primerApellido $segundoApellido'
      : '$nombre $primerApellido';

  @override
  List<Object?> get props => [
    id,
    nombre,
    primerApellido,
    segundoApellido,
    correo,
    activo,
    areaFormacion,
  ];
}
