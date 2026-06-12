import 'package:gestion_ets_escom/features/admin/domain/entities/administrativo.dart';

class AdministrativoModel extends Administrativo {
  const AdministrativoModel({
    required super.id,
    required super.nombre,
    required super.correo,
    required super.creadoEn,
    required super.activo,
  });

  factory AdministrativoModel.fromJson(Map<String, dynamic> json) =>
      AdministrativoModel(
        id: json['id'] as int,
        nombre: json['nombre'] as String,
        correo: json['correo'] as String,
        creadoEn: DateTime.parse(json['creado_en'] as String),
        activo: json['activo'] as bool,
      );

  Administrativo toEntity() => Administrativo(
        id: id,
        nombre: nombre,
        correo: correo,
        creadoEn: creadoEn,
        activo: activo,
      );
}
