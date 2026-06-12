import 'package:dartz/dartz.dart';
import 'package:gestion_ets_escom/core/errors/failures.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/carrera.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/materia.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/profesor.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/salon.dart';
import 'package:gestion_ets_escom/features/shared/data/datasources/shared_remote_datasource.dart';
import 'package:gestion_ets_escom/features/shared/domain/repositories/shared_repository.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/examen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SharedRepositoryImpl implements SharedRepository {
  final SharedRemoteDatasource datasource;
  SharedRepositoryImpl({required this.datasource});

  @override
  Future<Either<Failure, List<Carrera>>> getCarreras() async {
    try {
      // Llamada al datasource
      final models = await datasource.getCarreras();

      // Mapeo de la respuesta
      return Right(models.map((m) => m.toEntity()).toList());
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(const ServerFailure('Ocurrió un error inesperado'));
    }
  }

  @override
  Future<Either<Failure, List<Materia>>> getMaterias(int carreraId) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<Salon>>> getSalones() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<Profesor>>> getProfesores() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<Examen>>> getExamenes() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<Examen>>> searchExamenes({
    required int carreraId,
    required int semestre,
    int? materiaId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Examen>> getExamenById(int id) {
    throw UnimplementedError();
  }
}
