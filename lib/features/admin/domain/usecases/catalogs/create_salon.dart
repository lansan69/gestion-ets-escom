import 'package:dartz/dartz.dart';
import 'package:gestion_ets_escom/core/errors/failures.dart';
import 'package:gestion_ets_escom/features/admin/domain/repositories/admin_repository.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/salon.dart';

class CreateSalon {
  final AdminRepository repository;
  const CreateSalon(this.repository);

  Future<Either<Failure, Salon>> call(Salon salon) {
    return repository.createSalon(salon);
  }
}
