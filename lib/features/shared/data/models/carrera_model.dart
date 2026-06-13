// ============================================================
// NOMBRE: carrera_model.dart
// USO: Modelo de datos para Carrera. Parsea la respuesta de
//      Supabase y la convierte a la entidad de dominio.
//      Consumido por SharedRemoteDatasourceImpl.
// ============================================================
import 'package:gestion_ets_escom/features/shared/domain/entities/carrera.dart';

class CarreraModel extends Carrera {
  const CarreraModel({
    required super.id,
    required super.nombre,
    required super.abreviatura,
    required super.activo,
    required super.plan,
  });

  // Parsea el JSON devuelto por Supabase desde la tabla carrera.
  factory CarreraModel.fromJson(Map<String, dynamic> json) => CarreraModel(
    id: json['id'] as String,
    nombre: json['nombre'] as String,
    abreviatura: json['abreviatura'] as String,
    plan: json['plan'] as int,
    activo: json['activo'] as bool,
  );

  // Convierte el modelo a la entidad de dominio Carrera.
  Carrera toEntity() => Carrera(
    id: id,
    nombre: nombre,
    abreviatura: abreviatura,
    activo: activo,
    plan: plan,
  );
}
