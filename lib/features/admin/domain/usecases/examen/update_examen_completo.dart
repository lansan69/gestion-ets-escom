import 'package:dartz/dartz.dart';
import 'package:gestion_ets_escom/core/errors/failures.dart';
import 'package:gestion_ets_escom/features/admin/domain/entities/examen_update_params.dart';
import 'package:gestion_ets_escom/features/admin/domain/repositories/admin_repository.dart';

class UpdateExamenCompleto {
  final AdminRepository repository;
  const UpdateExamenCompleto(this.repository);

  Future<Either<Failure, void>> call(ExamenUpdateParams params) =>
      repository.updateExamenCompleto(params);
}
