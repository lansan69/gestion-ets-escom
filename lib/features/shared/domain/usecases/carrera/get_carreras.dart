// ============================================================
// NOMBRE: get_carreras.dart
// USO: Caso de uso que obtiene todas las carreras disponibles.
//      Consumido por getCarrerasProvider en carrera_providers.dart.
// ============================================================
import 'package:dartz/dartz.dart';
import 'package:gestion_ets_escom/core/errors/failures.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/carrera.dart';
import 'package:gestion_ets_escom/features/shared/domain/repositories/shared_repository.dart';

class GetCarreras {
  final SharedRepository repository;

  GetCarreras(this.repository);

  // Delega al repositorio y retorna la lista de carreras o un Failure.
  Future<Either<Failure, List<Carrera>>> call() async {
    return await repository.getCarreras();
  }
}