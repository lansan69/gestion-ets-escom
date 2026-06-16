// ============================================================
// NOMBRE: salon_model.dart
// USO: Modelo de datos para Salon. Parsea la respuesta de
//      Supabase y la convierte a la entidad de dominio.
//      Consumido por SharedRemoteDatasourceImpl y ExamenModel.
// ============================================================
import 'package:gestion_ets_escom/features/shared/domain/entities/salon.dart';

class SalonModel extends Salon {
  const SalonModel({
    required super.id,
    required super.edificio,
    required super.piso,
    required super.numeroSalon,
    super.etiquetaSalon,
    required super.activo,
  });

  // Parsea el JSON devuelto por Supabase desde la tabla salon.
  factory SalonModel.fromJson(Map<String, dynamic> json) => SalonModel(
        id: json['id'] as String,
        edificio: json['edificio'] as int,
        piso: json['piso'] as int,
        numeroSalon: json['numero_salon'] as int,
        etiquetaSalon: json['etiqueta_salon'] as String?,
        activo: json['activo'] as bool,
      );

   // Convierte el modelo a un mapa JSON para enviar a Supabase (Insert/Update)
  // etiqueta_salon es GENERATED ALWAYS en Supabase — no se envía en INSERT/UPDATE.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'edificio': edificio,
      'piso': piso,
      'numero_salon': numeroSalon,
      'activo': activo,
    };
  }

  // Convierte el modelo a la entidad de dominio Salon.
  Salon toEntity() => Salon(
        id: id,
        edificio: edificio,
        piso: piso,
        numeroSalon: numeroSalon,
        etiquetaSalon: etiquetaSalon,
        activo: activo,
      );
}

