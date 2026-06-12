import 'package:dartz/dartz.dart';
import 'package:gestion_ets_escom/core/errors/failures.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/carrera.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/examen.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/materia.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/profesor.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/salon.dart';

abstract class SharedRepository {
  // Catalogs
  Future<Either<Failure, List<Carrera>>> getCarreras();
  Future<Either<Failure, List<Materia>>> getMaterias(int carreraId);
  Future<Either<Failure, List<Salon>>> getSalones();
  Future<Either<Failure, List<Profesor>>> getProfesores();

  // Exámenes
  Future<Either<Failure, List<Examen>>> getExamenes();
  Future<Either<Failure, List<Examen>>> searchExamenes({
    required int carreraId,
    required int semestre,
    int? materiaId,
  });
  Future<Either<Failure, Examen>> getExamenById(int id);
}
