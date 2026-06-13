// ============================================================
// NOMBRE: shared_repository_impl.dart
// USO: Implementación del repositorio compartido. Coordina el
//      datasource remoto y mapea errores de Supabase a Failures.
// ============================================================

import 'package:dartz/dartz.dart';
import 'package:gestion_ets_escom/core/errors/failures.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/carrera.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/examen.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/materia.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/profesor.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/salon.dart';
import 'package:gestion_ets_escom/features/shared/data/datasources/shared_remote_datasource.dart';
import 'package:gestion_ets_escom/features/shared/domain/repositories/shared_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SharedRepositoryImpl implements SharedRepository {
  final SharedRemoteDatasource datasource;
  SharedRepositoryImpl({required this.datasource});

  // Obtiene la lista de carreras desde el datasource.
  @override
  Future<Either<Failure, List<Carrera>>> getCarreras() async {
    try {
      final models = await datasource.getCarreras();
      return Right(models.map((m) => m.toEntity()).toList());
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(const ServerFailure('Ocurrió un error inesperado'));
    }
  }

  @override
  Future<Either<Failure, List<Carrera>>> getCarreraById(String carreraId) {
    throw UnimplementedError();
  }

  // Obtiene las materias de una carrera específica.
  @override
  Future<Either<Failure, List<Materia>>> getMaterias(String carreraId) async {
    try {
      final models = await datasource.getMaterias(carreraId);
      return Right(models.map((m) => m.toEntity()).toList());
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(const ServerFailure('Ocurrió un error inesperado'));
    }
  }

  // Obtiene todos los salones disponibles.
  @override
  Future<Either<Failure, List<Salon>>> getSalones() async {
    try {
      final models = await datasource.getSalones();
      return Right(models.map((m) => m.toEntity()).toList());
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(const ServerFailure('Ocurrió un error inesperado'));
    }
  }

  // Obtiene todos los profesores con su área de formación.
  @override
  Future<Either<Failure, List<Profesor>>> getProfesores() async {
    try {
      final models = await datasource.getProfesores();
      return Right(models.map((m) => m.toEntity()).toList());
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(const ServerFailure('Ocurrió un error inesperado'));
    }
  }

  // Obtiene todos los exámenes con sus relaciones completas.
  @override
  Future<Either<Failure, List<Examen>>> getExamenes() async {
    try {
      final models = await datasource.getExamenes();
      return Right(models.map((m) => m.toEntity()).toList());
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(const ServerFailure('Ocurrió un error inesperado'));
    }
  }

  // Busca exámenes con filtros opcionales de carrera, semestre y materia.
  @override
  Future<Either<Failure, List<Examen>>> searchExamenes({
    String? carreraId,
    int? semestre,
    String? materiaId,
    String? unidadAprendizaje,
    String? searchTerm,
  }) async {
    try {
      final models = await datasource.searchExamenes(
        carreraId: carreraId,
        semestre: semestre,
        materiaId: materiaId,
        unidadAprendizaje: unidadAprendizaje,
        searchTerm: searchTerm,
      );
      return Right(models.map((m) => m.toEntity()).toList());
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(const ServerFailure('Ocurrió un error inesperado'));
    }
  }

  // Obtiene un examen por su ID (UUID).
  @override
  Future<Either<Failure, Examen>> getExamenById(String id) async {
    try {
      final model = await datasource.getExamenById(id);
      return Right(model.toEntity());
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(const ServerFailure('Ocurrió un error inesperado'));
    }
  }
}
