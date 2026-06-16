// ============================================================
// NOMBRE: shared_repository.dart
// USO: Contrato abstracto del repositorio compartido. Define
//      las operaciones de catálogos y búsqueda de exámenes.
//      Implementado por SharedRepositoryImpl.
// ============================================================
import 'package:dartz/dartz.dart';
import 'package:gestion_ets_escom/core/errors/failures.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/calendario_examen.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/carrera.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/examen.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/examen_filter.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/materia.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/preferencia.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/profesor.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/salon.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/stats_result.dart';

abstract class SharedRepository {
  // Catálogos
  Stream<Either<Failure, List<Carrera>>> getCarreras();
  Future<Either<Failure, List<Carrera>>> getCarreraById(String carreraId);
  Future<Either<Failure, List<Materia>>> getMaterias(String carreraId);
  Future<Either<Failure, List<Salon>>> getSalones();
  Future<Either<Failure, List<Profesor>>> getProfesores();

  // Exámenes
  Stream<Either<Failure, List<Examen>>> getExamenes([ExamenFilter? filter]);
  Future<Either<Failure, List<Examen>>> searchExamenes({
    String? carreraId,
    List<int>? semestres,
    String? materiaId,
    String? areaFormacion,
    String? unidadAprendizaje,
    String? searchTerm,
  });
  Future<Either<Failure, Examen>> getExamenById(String id);

  // Preferencia local
  Future<Either<Failure, bool>> hasPreferencia();
  Future<Either<Failure, Preferencia?>> getPreferencia();
  Future<Either<Failure, void>> savePreferencia(Preferencia preferencia);

  // Calendario local
  Future<Either<Failure, void>> addToCalendario(String examenId, String color);
  Future<Either<Failure, bool>> isInCalendario(String examenId);
  Future<Either<Failure, List<CalendarioExamen>>> getCalendarioExamenes();
  Future<Either<Failure, void>> removeFromCalendario(String examenId);

  // Limpia preferencias y calendario del usuario.
  Future<Either<Failure, void>> clearCache();

  // Estadísticas de exámenes agrupadas por carrera y área — solo caché local.
  Future<Either<Failure, StatsResult>> getStats();
}
