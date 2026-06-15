import 'package:dartz/dartz.dart';
import 'package:gestion_ets_escom/core/errors/failures.dart';
import 'package:gestion_ets_escom/features/shared/domain/repositories/shared_repository.dart';

class RemoveFromCalendario {
  final SharedRepository repository;
  const RemoveFromCalendario(this.repository);

  Future<Either<Failure, void>> call(String examenId) =>
      repository.removeFromCalendario(examenId);
}
