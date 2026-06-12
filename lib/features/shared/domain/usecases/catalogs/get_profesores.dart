import 'package:dartz/dartz.dart';
import 'package:gestion_ets_escom/core/errors/failures.dart';
import 'package:gestion_ets_escom/features/admin/domain/repositories/admin_repository.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/profesor.dart';


class GetProfesores {
  final AdminRepository repository;
  const GetProfesores(this.repository);

  Future<Either<Failure, List<Profesor>>> call() {
    throw UnimplementedError();
  }
}
