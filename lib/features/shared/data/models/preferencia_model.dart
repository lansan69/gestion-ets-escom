import 'package:gestion_ets_escom/features/shared/domain/entities/preferencia.dart';

class PreferenciaModel extends Preferencia {
  const PreferenciaModel({
    required super.omitir,
    required super.carreraId,
    super.seleccion1Semestre,
    super.seleccion2Semestre,
    super.seleccion3Semestre,
  });

  // Parses a SQLite row from the preferencia table.
  // SQLite stores booleans as INTEGER (0/1).
  factory PreferenciaModel.fromMap(Map<String, dynamic> map) => PreferenciaModel(
        omitir: (map['omitir'] as int) == 1,
        carreraId: map['carrera_id'] as String,
        seleccion1Semestre: map['seleccion1_semestre'] as int?,
        seleccion2Semestre: map['seleccion2_semestre'] as int?,
        seleccion3Semestre: map['seleccion3_semestre'] as int?,
      );

  // Serializes the model for insertion into the preferencia table.
  Map<String, dynamic> toMap() => {
        'carrera_id': carreraId,
        'omitir': omitir ? 1 : 0,
        'seleccion1_semestre': seleccion1Semestre,
        'seleccion2_semestre': seleccion2Semestre,
        'seleccion3_semestre': seleccion3Semestre,
      };

  Preferencia toEntity() => Preferencia(
        omitir: omitir,
        carreraId: carreraId,
        seleccion1Semestre: seleccion1Semestre,
        seleccion2Semestre: seleccion2Semestre,
        seleccion3Semestre: seleccion3Semestre,
      );
}
