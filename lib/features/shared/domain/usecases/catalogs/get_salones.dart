import 'package:dartz/dartz.dart';
import 'package:gestion_ets_escom/core/errors/failures.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/salon.dart';
import 'package:gestion_ets_escom/features/shared/domain/repositories/shared_repository.dart';

class GetSalones {
  final SharedRepository repository;
  const GetSalones(this.repository);

  Future<Either<Failure, List<Salon>>> call() =>
      repository.getSalones();
}
