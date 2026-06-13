// ============================================================
// NOMBRE: salon.dart
// USO: Entidad de dominio que representa un salón de examen.
//      Consumida por Examen y los datasources de búsqueda.
// ============================================================
import 'package:equatable/equatable.dart';

class Salon extends Equatable {
  final String id;
  final int edificio;
  final int piso;
  final int numeroSalon;
  final String? etiquetaSalon;
  final bool activo;

  const Salon({
    required this.id,
    required this.edificio,
    required this.piso,
    required this.numeroSalon,
    this.etiquetaSalon,
    required this.activo,
  });

  @override
  List<Object?> get props => [id, edificio, piso, numeroSalon, etiquetaSalon, activo];
}
