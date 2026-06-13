// ============================================================
// NOMBRE: delete_examen.dart
// USO: Caso de uso para eliminar un examen ETS por su ID.
//      Pendiente de implementar. Será consumido por el panel
//      de gestión.
// ============================================================
import 'package:dartz/dartz.dart';
import 'package:gestion_ets_escom/core/errors/failures.dart';
import 'package:gestion_ets_escom/features/admin/domain/repositories/admin_repository.dart';

class DeleteExamen {
  final AdminRepository repository;
  const DeleteExamen(this.repository);

  // Recibe el ID entero del examen y lo elimina del repositorio.
  Future<Either<Failure, void>> call(int id) {
    throw UnimplementedError();
  }
}
