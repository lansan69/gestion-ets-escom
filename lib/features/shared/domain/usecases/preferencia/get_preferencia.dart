import 'package:dartz/dartz.dart';
import 'package:gestion_ets_escom/core/errors/failures.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/preferencia.dart';
import 'package:gestion_ets_escom/features/shared/domain/repositories/shared_repository.dart';

class GetPreferencia {
  final SharedRepository repository;
  const GetPreferencia(this.repository);

  Future<Either<Failure, Preferencia?>> call() => repository.getPreferencia();
}
