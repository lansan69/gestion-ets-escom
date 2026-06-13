// ============================================================
// NOMBRE: update_examen.dart
// USO: Caso de uso para actualizar un examen ETS existente.
//      Pendiente de implementar. Será consumido por el panel
//      de gestión.
// ============================================================
import 'package:dartz/dartz.dart';
import 'package:gestion_ets_escom/core/errors/failures.dart';
import 'package:gestion_ets_escom/features/admin/domain/repositories/admin_repository.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/examen.dart';

class UpdateExamen {
  final AdminRepository repository;
  const UpdateExamen(this.repository);

  // Recibe la entidad Examen con los datos actualizados y los persiste.
  Future<Either<Failure, Examen>> call(Examen examen) {
    throw UnimplementedError();
  }
}
