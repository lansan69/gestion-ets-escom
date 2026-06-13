// ============================================================
// NOMBRE: get_carrera_by_id.dart
// USO: Caso de uso que obtiene una carrera específica por su ID.
//      Consumido por pantallas que muestran el detalle de carrera.
// ============================================================
import 'package:dartz/dartz.dart';
import 'package:gestion_ets_escom/core/errors/failures.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/carrera.dart';
import 'package:gestion_ets_escom/features/shared/domain/repositories/shared_repository.dart';

class GetCarreraById {
  final SharedRepository repository;

  GetCarreraById(this.repository);

  // Recibe el UUID de la carrera y retorna la entidad o un Failure.
  Future<Either<Failure, List<Carrera>>> call(String carreraId) async {
    return await repository.getCarreraById(carreraId);
  }
}