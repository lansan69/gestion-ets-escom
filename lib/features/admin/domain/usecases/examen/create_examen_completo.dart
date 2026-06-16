import 'package:dartz/dartz.dart';
import 'package:gestion_ets_escom/core/errors/failures.dart';
import 'package:gestion_ets_escom/features/admin/domain/entities/examen_create_params.dart';
import 'package:gestion_ets_escom/features/admin/domain/repositories/admin_repository.dart';

class CreateExamenCompleto {
  final AdminRepository repository;
  const CreateExamenCompleto(this.repository);

  Future<Either<Failure, void>> call(ExamenCreateParams params) =>
      repository.createExamenCompleto(params);
}
