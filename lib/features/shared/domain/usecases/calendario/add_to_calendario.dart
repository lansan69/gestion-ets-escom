import 'package:dartz/dartz.dart';
import 'package:gestion_ets_escom/core/errors/failures.dart';
import 'package:gestion_ets_escom/features/shared/domain/repositories/shared_repository.dart';

class AddToCalendario {
  final SharedRepository repository;
  const AddToCalendario(this.repository);

  Future<Either<Failure, void>> call(String examenId) =>
      repository.addToCalendario(examenId);
}
