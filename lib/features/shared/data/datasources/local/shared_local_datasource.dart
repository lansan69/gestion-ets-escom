// ============================================================
// NOMBRE: shared_local_datasource.dart
// USO: Contrato abstracto del datasource local (SQLite). Espeja
//      los métodos de SharedRemoteDatasource que se necesitan
//      para soporte offline. Implementado por SharedLocalDatasourceImpl.
// ============================================================

import 'package:gestion_ets_escom/features/shared/data/models/area_model.dart';
import 'package:gestion_ets_escom/features/shared/data/models/carrera_model.dart';
import 'package:gestion_ets_escom/features/shared/data/models/examen_model.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/examen_filter.dart';

abstract class SharedLocalDatasource {
  // Lee las carreras almacenadas en el caché local.
  Future<List<CarreraModel>> getCarreras();

  // Lee las áreas de formación almacenadas en el caché local.
  Future<List<AreaFormacionModel>> getAreasFormacion();

  // Lee los exámenes del caché aplicando filtros de carrera y semestres via WHERE.
  Future<List<ExamenModel>> getExamenes(ExamenFilter filter);

  // Inserta o reemplaza carreras en el caché local en lote.
  Future<void> upsertCarreras(List<CarreraModel> carreras);

  // Inserta o reemplaza áreas de formación en el caché local en lote.
  Future<void> upsertAreasFormacion(List<AreaFormacionModel> areas);

  // Inserta o reemplaza exámenes y todos sus objetos relacionados en el caché local.
  // Guarda TODOS los semestres presentes en la lista, sin filtrar por selección activa.
  Future<void> upsertExamenes(List<ExamenModel> examenes);

  // Devuelve true si la tabla preferencia tiene al menos una fila (onboarding completado).
  Future<bool> hasPreferencia();

  // Guarda un examen en el calendario local. Ignora duplicados (INSERT OR IGNORE).
  Future<void> addToCalendario(String examenId);

  // Devuelve true si el examen ya está guardado en el calendario local.
  Future<bool> isInCalendario(String examenId);
}
