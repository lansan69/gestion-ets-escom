import 'package:dartz/dartz.dart';
import 'package:gestion_ets_escom/core/errors/failures.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/examen.dart';
import 'package:gestion_ets_escom/features/shared/domain/repositories/shared_repository.dart';

class GetExamenes {
  final SharedRepository repository;
  const GetExamenes(this.repository);

  Future<Either<Failure, List<Examen>>> call() {
    throw UnimplementedError();
  }
}
