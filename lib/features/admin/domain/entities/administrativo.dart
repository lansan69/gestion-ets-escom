import 'package:equatable/equatable.dart';

class Administrativo extends Equatable {
  final int id;
  final String nombre;
  final String correo;
  final DateTime creadoEn;
  final bool activo;

  const Administrativo({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.creadoEn,
    required this.activo,
  });

  @override
  List<Object?> get props => [id, nombre, correo, creadoEn, activo];
}
