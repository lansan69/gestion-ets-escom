import 'package:dartz/dartz.dart';
import 'package:gestion_ets_escom/core/errors/failures.dart';
import 'package:gestion_ets_escom/features/admin/domain/repositories/admin_repository.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/materia.dart';

class CreateMateria {
  final AdminRepository repository;
  const CreateMateria(this.repository);
  Future<Either<Failure, Materia>> call(Materia materia) {
    return repository.createMateria(materia);
  }
}
