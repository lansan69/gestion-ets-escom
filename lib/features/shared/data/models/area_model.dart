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
    required super.color,
    required super.activo,
  });

  // Parsea el JSON devuelto por Supabase desde la tabla area_formacion.
  factory AreaFormacionModel.fromJson(Map<String, dynamic> json) =>
      AreaFormacionModel(
        id: json['id'] as String,
        nombre: json['nombre'] as String,
        color: json['color'] as String,
        activo: json['activo'] as bool,
      );

  // Parsea una fila de SQLite desde la tabla areas_formacion.
  // SQLite almacena booleanos como INTEGER (0/1).
  factory AreaFormacionModel.fromMap(Map<String, dynamic> map) =>
      AreaFormacionModel(
        id: map['id'] as String,
        nombre: map['nombre'] as String,
        color: map['color'] as String,
        activo: (map['activo'] as int) == 1,
      );

  // Serializa el modelo para inserción en la tabla areas_formacion de SQLite.
  Map<String, dynamic> toMap() => {
    'id': id,
    'nombre': nombre,
    'color': color,
    'activo': activo ? 1 : 0,
  };

  AreaFormacion toEntity() => AreaFormacion(
        id: id,
        nombre: nombre,
        color: color,
        activo: activo,
      );
}
