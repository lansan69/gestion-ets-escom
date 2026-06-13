import 'package:dartz/dartz.dart';
import 'package:gestion_ets_escom/core/errors/failures.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/profesor.dart';
import 'package:gestion_ets_escom/features/shared/domain/repositories/shared_repository.dart';

class GetProfesores {
  final SharedRepository repository;
  const GetProfesores(this.repository);

  Future<Either<Failure, List<Profesor>>> call() =>
      repository.getProfesores();
}
