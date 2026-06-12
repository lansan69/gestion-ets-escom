import 'package:equatable/equatable.dart';

class Salon extends Equatable {
  final int id;
  final int edificio;
  final int piso;
  final int numeroSalon;
  final int? capacidad;
  final bool activo;

  const Salon({
    required this.id,
    required this.edificio,
    required this.piso,
    required this.numeroSalon,
    this.capacidad,
    required this.activo,
  });

  @override
  List<Object?> get props => [id, edificio, piso, numeroSalon, capacidad, activo];
}
