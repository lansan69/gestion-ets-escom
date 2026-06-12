import 'package:gestion_ets_escom/features/shared/domain/entities/carrera.dart';

class CarreraModel extends Carrera {
  const CarreraModel({
    required super.id,
    required super.nombre,
    required super.abreviatura,
    required super.activo,
    required super.plan,
  });

  factory CarreraModel.fromJson(Map<String, dynamic> json) => CarreraModel(
    id: json['id'] as String,
    nombre: json['nombre'] as String,
    abreviatura: json['abreviatura'] as String,
    plan: json['plan'] as int,
    activo: json['activo'] as bool,
  );

  Carrera toEntity() => Carrera(
    id: id,
    nombre: nombre,
    abreviatura: abreviatura,
    activo: activo,
    plan: plan,
  );
}
