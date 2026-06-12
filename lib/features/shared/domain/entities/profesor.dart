import 'package:equatable/equatable.dart';

class Profesor extends Equatable {
  final int id;
  final String nombre;
  final String primerApellido;
  final String? segundoApellido;
  final String correo;
  final bool activo;

  const Profesor({
    required this.id,
    required this.nombre,
    required this.primerApellido,
    this.segundoApellido,
    required this.correo,
    required this.activo,
  });

  String get nombreCompleto => segundoApellido != null
      ? '$nombre $primerApellido $segundoApellido'
      : '$nombre $primerApellido';

  @override
  List<Object?> get props =>
      [id, nombre, primerApellido, segundoApellido, correo, activo];
}
