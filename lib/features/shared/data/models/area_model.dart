// ============================================================
// NOMBRE: area_model.dart
// USO: Modelo de datos para AreaFormacion. Parsea la respuesta
//      de Supabase y la convierte a la entidad de dominio.
// ============================================================

import 'package:gestion_ets_escom/features/shared/domain/entities/area_formacion.dart';

class AreaFormacionModel extends AreaFormacion {
  const AreaFormacionModel({
    required super.id,
    required super.nombre,
    required super.activo,
  });

  // Parsea el JSON devuelto por Supabase desde la tabla area_formacion.
  factory AreaFormacionModel.fromJson(Map<String, dynamic> json) =>
      AreaFormacionModel(
        id: json['id'] as String,
        nombre: json['nombre'] as String,
        activo: json['activo'] as bool,
      );

  AreaFormacion toEntity() => AreaFormacion(
        id: id,
        nombre: nombre,
        activo: activo,
      );
}
