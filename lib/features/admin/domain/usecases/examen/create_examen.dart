// ============================================================
// NOMBRE: create_examen.dart
// USO: Caso de uso para crear un nuevo examen ETS. Pendiente
//      de implementar. Será consumido por el panel de gestión.
// ============================================================
import 'package:dartz/dartz.dart';
import 'package:gestion_ets_escom/core/errors/failures.dart';
import 'package:gestion_ets_escom/features/admin/domain/repositories/admin_repository.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/examen.dart';

class CreateExamen {
  final AdminRepository repository;
  const CreateExamen(this.repository);

  // Recibe la entidad Examen con todos sus datos y la persiste en Supabase.
  Future<Either<Failure, Examen>> call(Examen examen) {
    throw UnimplementedError();
  }
}
