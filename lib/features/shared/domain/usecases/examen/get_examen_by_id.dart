// ============================================================
// NOMBRE: get_examen_by_id.dart
// USO: Caso de uso que obtiene un examen específico por su UUID.
//      Consumido por la pantalla IndividualMateriaView.
// ============================================================
import 'package:dartz/dartz.dart';
import 'package:gestion_ets_escom/core/errors/failures.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/examen.dart';
import 'package:gestion_ets_escom/features/shared/domain/repositories/shared_repository.dart';

class GetExamenById {
  final SharedRepository repository;
  const GetExamenById(this.repository);

  // Recibe el UUID del examen y retorna la entidad completa o un Failure.
  Future<Either<Failure, Examen>> call(String id) =>
      repository.getExamenById(id);
}
