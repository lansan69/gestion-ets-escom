import 'package:equatable/equatable.dart';

class Edificio extends Equatable {
  final String id;
  final String nombre;
  final int numero;
  final bool activo;

  const Edificio({
    required this.id,
    required this.nombre,
    required this.numero,
    required this.activo,
  });

  @override
  List<Object?> get props => [id, nombre, numero, activo];
}
