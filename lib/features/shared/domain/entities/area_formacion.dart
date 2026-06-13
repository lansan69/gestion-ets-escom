import 'package:equatable/equatable.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/carrera.dart';

class AreaFormacion extends Equatable {
  final String id;
  final String nombre;
  final bool activo;

  const AreaFormacion({
    required this.id,
    required this.nombre,
    required this.activo,
  });

  @override
  List<Object?> get props => [id, nombre, activo];
}
