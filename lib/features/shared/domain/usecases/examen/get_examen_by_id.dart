import 'package:dartz/dartz.dart';
import 'package:gestion_ets_escom/core/errors/failures.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/examen.dart';
import 'package:gestion_ets_escom/features/shared/domain/repositories/shared_repository.dart';

class GetExamenById {
  final SharedRepository repository;
  const GetExamenById(this.repository);

  Future<Either<Failure, Examen>> call(String id) =>
      repository.getExamenById(id);
}
