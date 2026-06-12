import 'package:dartz/dartz.dart';
import 'package:gestion_ets_escom/core/errors/failures.dart';
import 'package:gestion_ets_escom/features/admin/domain/repositories/admin_repository.dart';

class DeleteExamen {
  final AdminRepository repository;
  const DeleteExamen(this.repository);

  Future<Either<Failure, void>> call(int id) {
    throw UnimplementedError();
  }
}
