import 'package:dartz/dartz.dart';
import 'package:gestion_ets_escom/core/errors/failures.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/carrera.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/examen.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/materia.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/profesor.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/salon.dart';

abstract class AdminRepository {
  // Examen CRUD
  Future<Either<Failure, Examen>> createExamen(Examen examen);
  Future<Either<Failure, Examen>> updateExamen(Examen examen);
  Future<Either<Failure, void>> deleteExamen(int id);
}
