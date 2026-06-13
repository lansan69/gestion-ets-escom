// ============================================================
// NOMBRE: get_profesores.dart
// USO: Caso de uso que obtiene el catálogo completo de profesores.
//      Consumido por los providers de la feature admin.
// ============================================================
import 'package:dartz/dartz.dart';
import 'package:gestion_ets_escom/core/errors/failures.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/profesor.dart';
import 'package:gestion_ets_escom/features/shared/domain/repositories/shared_repository.dart';

class GetProfesores {
  final SharedRepository repository;
  const GetProfesores(this.repository);

  // Retorna la lista de profesores con su área de formación o un Failure.
  Future<Either<Failure, List<Profesor>>> call() =>
      repository.getProfesores();
}
