import 'package:dartz/dartz.dart';
import 'package:gestion_ets_escom/core/errors/failures.dart';
import 'package:gestion_ets_escom/features/admin/domain/repositories/admin_repository.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/salon.dart';


class GetSalones {
  final AdminRepository repository;
  const GetSalones(this.repository);

  Future<Either<Failure, List<Salon>>> call() {
    throw UnimplementedError();
  }
}
