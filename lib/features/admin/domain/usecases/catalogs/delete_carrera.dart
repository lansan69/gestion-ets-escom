import 'package:dartz/dartz.dart';
import 'package:gestion_ets_escom/core/errors/failures.dart';
import 'package:gestion_ets_escom/features/admin/domain/repositories/admin_repository.dart';

class DeleteCarrera {
  final AdminRepository repository;
  const DeleteCarrera(this.repository);

  Future<Either<Failure, void>> call(String id) {
    return repository.deleteCarrera(id);
  }
}
