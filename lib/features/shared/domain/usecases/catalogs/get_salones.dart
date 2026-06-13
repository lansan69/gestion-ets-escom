// ============================================================
// NOMBRE: get_salones.dart
// USO: Caso de uso que obtiene el catálogo completo de salones.
//      Consumido por los providers de la feature admin.
// ============================================================
import 'package:dartz/dartz.dart';
import 'package:gestion_ets_escom/core/errors/failures.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/salon.dart';
import 'package:gestion_ets_escom/features/shared/domain/repositories/shared_repository.dart';

class GetSalones {
  final SharedRepository repository;
  const GetSalones(this.repository);

  // Retorna la lista de salones disponibles o un Failure.
  Future<Either<Failure, List<Salon>>> call() =>
      repository.getSalones();
}
