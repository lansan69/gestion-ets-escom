import 'package:dartz/dartz.dart';
import 'package:gestion_ets_escom/core/errors/failures.dart';
import 'package:gestion_ets_escom/features/admin/domain/repositories/admin_repository.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/carrera.dart';

class UpdateCarrera {
  final AdminRepository repository;
  const UpdateCarrera(this.repository);

  Future<Either<Failure, Carrera>> call(Carrera carrera) {
    return repository.updateCarrera(carrera);
  }
}
