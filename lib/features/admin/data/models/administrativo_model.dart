// ============================================================
// NOMBRE: administrativo_model.dart
// USO: Modelo de datos para Administrativo. Parsea la respuesta
//      de Supabase y la convierte a la entidad de dominio.
//      Consumido por AuthRemoteDatasourceImpl.
// ============================================================
import 'package:gestion_ets_escom/features/admin/domain/entities/administrativo.dart';

class AdministrativoModel extends Administrativo {
  const AdministrativoModel({
    required super.id,
    required super.nombre,
    required super.correo,
    required super.creadoEn,
    required super.activo,
  });

  // Parsea el JSON devuelto por Supabase desde la tabla administrativos.
  factory AdministrativoModel.fromJson(Map<String, dynamic> json) =>
      AdministrativoModel(
        id: json['id'] as int,
        nombre: json['nombre'] as String,
        correo: json['correo'] as String,
        creadoEn: DateTime.parse(json['creado_en'] as String),
        activo: json['activo'] as bool,
      );

  // Convierte el modelo a la entidad de dominio Administrativo.
  Administrativo toEntity() => Administrativo(
        id: id,
        nombre: nombre,
        correo: correo,
        creadoEn: creadoEn,
        activo: activo,
      );
}
