import 'package:dartz/dartz.dart';
import 'package:gestion_ets_escom/core/errors/failures.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/materia.dart';
import 'package:gestion_ets_escom/features/shared/domain/repositories/shared_repository.dart';

class GetMaterias {
  final SharedRepository repository;
  const GetMaterias(this.repository);

  // Recibe el ID de la carrera para filtrar las materias correspondientes.
  Future<Either<Failure, List<Materia>>> call(String carreraId) =>
      repository.getMaterias(carreraId);
}
