// ============================================================
// NOMBRE: shared_repository_impl.dart
// USO: Implementación del repositorio compartido con soporte
//      offline-first. getCarreras y getExamenes emiten datos
//      locales primero y luego actualizan desde Supabase.
//      Los demás métodos siguen siendo Future.
// ============================================================

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:gestion_ets_escom/core/errors/failures.dart';
import 'package:gestion_ets_escom/features/shared/data/datasources/local/shared_local_datasource.dart';
import 'package:gestion_ets_escom/features/shared/data/datasources/shared_remote_datasource.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/carrera.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/examen.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/examen_filter.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/materia.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/profesor.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/salon.dart';
import 'package:gestion_ets_escom/features/shared/domain/repositories/shared_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SharedRepositoryImpl implements SharedRepository {
  final SharedRemoteDatasource datasource;
  final SharedLocalDatasource local;

  SharedRepositoryImpl({required this.datasource, required this.local});

  // Emite el caché local inmediatamente, luego busca en remoto y actualiza el caché.
  // Si no hay conexión, el stream termina silenciosamente con los datos locales.
  @override
  Stream<Either<Failure, List<Carrera>>> getCarreras() async* {
    final localModels = await local.getCarreras();
    yield Right(localModels.map((m) => m.toEntity()).toList());

    try {
      final remoteModels = await datasource.getCarreras();
      await local.upsertCarreras(remoteModels);
      yield Right(remoteModels.map((m) => m.toEntity()).toList());
    } catch (_) {
      // Sin conexión: el consumidor ya tiene los datos locales emitidos arriba.
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

  // Emite caché local filtrado inmediatamente, luego actualiza desde Supabase (todos los
  // exámenes) y re-emite el caché ya actualizado aplicando el mismo filtro.
  // El remoto siempre trae el set completo para mantener el caché íntegro.
  @override
  Stream<Either<Failure, List<Examen>>> getExamenes([ExamenFilter? filter]) async* {
    final f = filter ?? const ExamenFilter();

    final localModels = await local.getExamenes(f);
    yield Right(localModels.map((m) => m.toEntity()).toList());

    try {
      final remoteModels = await datasource.getExamenes();
      await local.upsertExamenes(remoteModels);
      // Re-consulta local para entregar la vista filtrada del caché ya actualizado.
      final refreshed = await local.getExamenes(f);
      yield Right(refreshed.map((m) => m.toEntity()).toList());
    } catch (_) {
      // Sin conexión: el consumidor ya tiene los datos locales emitidos arriba.
    }
  }

  // Busca exámenes aplicando filtros opcionales sobre materia, carrera, semestres y área.
  @override
  Future<Either<Failure, List<Examen>>> searchExamenes({
    String? carreraId,
    List<int>? semestres,
    String? materiaId,
    String? areaFormacion,
    String? unidadAprendizaje,
    String? searchTerm,
  }) async {
    try {
      final models = await datasource.searchExamenes(
        carreraId: carreraId,
        semestres: semestres,
        materiaId: materiaId,
        areaFormacion: areaFormacion,
        searchTerm: searchTerm,
      );
      return Right(models.map((m) => m.toEntity()).toList());
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e, st) {
      debugPrint('🔴 RAW ERROR: $e');
      debugPrint('🔴 TYPE: ${e.runtimeType}');
      debugPrint('🔴 STACKTRACE: $st');
      return Left(ServerFailure(e.toString()));
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
