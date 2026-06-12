import 'package:dartz/dartz.dart';
import 'package:gestion_ets_escom/core/errors/failures.dart';
import 'package:gestion_ets_escom/features/admin/domain/repositories/admin_repository.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/examen.dart';

class CreateExamen {
  final AdminRepository repository;
  const CreateExamen(this.repository);

  Future<Either<Failure, Examen>> call(Examen examen) {
    throw UnimplementedError();
  }
}
