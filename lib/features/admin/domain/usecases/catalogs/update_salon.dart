import 'package:dartz/dartz.dart';
import 'package:gestion_ets_escom/core/errors/failures.dart';
import 'package:gestion_ets_escom/features/admin/domain/repositories/admin_repository.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/salon.dart';

class UpdateSalon {
  final AdminRepository repository;
  const UpdateSalon(this.repository);

  Future<Either<Failure, Salon>> call(Salon salon) {
    return repository.updateSalon(salon);
  }
}
