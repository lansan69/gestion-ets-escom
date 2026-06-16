import 'package:gestion_ets_escom/features/shared/domain/entities/edificio.dart';

class EdificioModel extends Edificio {
  const EdificioModel({
    required super.id,
    required super.nombre,
    required super.numero,
    required super.activo,
  });

  factory EdificioModel.fromJson(Map<String, dynamic> json) => EdificioModel(
        id: json['id'] as String,
        nombre: json['nombre'] as String,
        numero: json['numero'] as int,
        activo: json['activo'] as bool,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'numero': numero,
        'activo': activo,
      };

  Edificio toEntity() => Edificio(
        id: id,
        nombre: nombre,
        numero: numero,
        activo: activo,
      );
}
