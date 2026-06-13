// ============================================================
// NOMBRE: shared_repository.dart
// USO: Contrato abstracto del repositorio compartido. Define
//      las operaciones de catálogos y búsqueda de exámenes.
//      Implementado por SharedRepositoryImpl.
// ============================================================
import 'package:dartz/dartz.dart';
import 'package:gestion_ets_escom/core/errors/failures.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/carrera.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/examen.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/examen_filter.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/materia.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/profesor.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/salon.dart';

abstract class SharedRepository {
  // Catálogos
  // Emite datos locales primero (caché), luego los datos remotos actualizados.
  Stream<Either<Failure, List<Carrera>>> getCarreras();
  Future<Either<Failure, List<Carrera>>> getCarreraById(String carreraId);
  Future<Either<Failure, List<Materia>>> getMaterias(String carreraId);
  Future<Either<Failure, List<Salon>>> getSalones();
  Future<Either<Failure, List<Profesor>>> getProfesores();

  // Exámenes
  // Emite datos locales primero (caché), luego los datos remotos actualizados.
  // El filtro opcional se aplica a la consulta local para reducir los datos leídos.
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
}
