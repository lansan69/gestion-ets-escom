import 'package:dartz/dartz.dart';
import 'package:gestion_ets_escom/core/errors/failures.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/preferencia.dart';
import 'package:gestion_ets_escom/features/shared/domain/repositories/shared_repository.dart';

class SavePreferencia {
  final SharedRepository repository;
  const SavePreferencia(this.repository);

  Future<Either<Failure, void>> call(Preferencia preferencia) =>
      repository.savePreferencia(preferencia);
}
