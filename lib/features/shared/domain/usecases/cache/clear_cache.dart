import 'package:dartz/dartz.dart';
import 'package:gestion_ets_escom/core/errors/failures.dart';
import 'package:gestion_ets_escom/features/shared/domain/repositories/shared_repository.dart';

class ClearCache {
  final SharedRepository repository;
  const ClearCache(this.repository);
  Future<Either<Failure, void>> call() => repository.clearCache();
}
