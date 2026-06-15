import 'package:dartz/dartz.dart';
import 'package:gestion_ets_escom/core/errors/failures.dart';
import 'package:gestion_ets_escom/features/shared/domain/repositories/shared_repository.dart';

class HasPreferencia {
  final SharedRepository repository;
  const HasPreferencia(this.repository);

  Future<Either<Failure, bool>> call() => repository.hasPreferencia();
}
