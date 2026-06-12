
import 'package:gestion_ets_escom/features/shared/domain/entities/profesor.dart';

class ProfesorModel extends Profesor {
  const ProfesorModel({
    required super.id,
    required super.nombre,
    required super.primerApellido,
    super.segundoApellido,
    required super.correo,
    required super.activo,
  });

  factory ProfesorModel.fromJson(Map<String, dynamic> json) => ProfesorModel(
        id: json['id'] as int,
        nombre: json['nombre'] as String,
        primerApellido: json['primer_apellido'] as String,
        segundoApellido: json['segundo_apellido'] as String?,
        correo: json['correo'] as String,
        activo: json['activo'] as bool,
      );

  Profesor toEntity() => Profesor(
        id: id,
        nombre: nombre,
        primerApellido: primerApellido,
        segundoApellido: segundoApellido,
        correo: correo,
        activo: activo,
      );
}
