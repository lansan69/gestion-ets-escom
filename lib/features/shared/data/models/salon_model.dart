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

  factory SalonModel.fromJson(Map<String, dynamic> json) => SalonModel(
        id: json['id'] as String,
        edificio: json['edificio'] as int,
        piso: json['piso'] as int,
        numeroSalon: json['numero_salon'] as int,
        etiquetaSalon: json['etiqueta_salon'] as String?,
        activo: json['activo'] as bool,
      );

  Salon toEntity() => Salon(
        id: id,
        edificio: edificio,
        piso: piso,
        numeroSalon: numeroSalon,
        etiquetaSalon: etiquetaSalon,
        activo: activo,
      );
}
