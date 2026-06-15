// ============================================================
// NOMBRE: shared_local_datasource.dart
// USO: Contrato abstracto del datasource local (SQLite). Espeja
//      los métodos de SharedRemoteDatasource que se necesitan
//      para soporte offline. Implementado por SharedLocalDatasourceImpl.
// ============================================================

import 'package:gestion_ets_escom/features/shared/data/models/area_model.dart';
import 'package:gestion_ets_escom/features/shared/data/models/carrera_model.dart';
import 'package:gestion_ets_escom/features/shared/data/models/examen_model.dart';
import 'package:gestion_ets_escom/features/shared/data/models/preferencia_model.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/calendario_entry.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/calendario_examen.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/examen_filter.dart';

abstract class SharedLocalDatasource {
  Future<List<CarreraModel>> getCarreras();
  Future<List<AreaFormacionModel>> getAreasFormacion();
  Future<List<ExamenModel>> getExamenes(ExamenFilter filter);
  Future<void> upsertCarreras(List<CarreraModel> carreras);
  Future<void> upsertAreasFormacion(List<AreaFormacionModel> areas);
  Future<void> upsertExamenes(List<ExamenModel> examenes);
  Future<bool> hasPreferencia();
  Future<PreferenciaModel?> getPreferencia();
  Future<void> savePreferencia(PreferenciaModel model);

  // Guarda un examen en el calendario local con el color elegido por el usuario.
  Future<void> addToCalendario(String examenId, String color);

  // Devuelve true si el examen ya está guardado en el calendario local.
  Future<bool> isInCalendario(String examenId);

  // Lee todas las entradas del calendario (examen_id + color).
  Future<List<CalendarioEntry>> getCalendario();

  // Lee los exámenes guardados en el calendario con JOIN completo.
  Future<List<CalendarioExamen>> getCalendarioExamenes();

  // Elimina un examen del calendario local.
  Future<void> removeFromCalendario(String examenId);

  // Borra todas las filas de preferencia y calendario (reset de datos del usuario).
  Future<void> clearCache();
}
