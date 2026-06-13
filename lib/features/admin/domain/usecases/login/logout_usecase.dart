// ============================================================
// NOMBRE: logout_usecase.dart
// USO: Caso de uso para cerrar la sesión del administrativo.
//      Pendiente de implementar. Será consumido por el panel
//      de gestión.
// ============================================================
import 'package:dartz/dartz.dart';
import 'package:gestion_ets_escom/features/admin/domain/repositories/auth_repository.dart';
import '../../../../../core/errors/failures.dart';

class LogoutUseCase {
  final AuthRepository repository;
  const LogoutUseCase(this.repository);

  // Cierra la sesión activa del administrativo en Supabase.
  Future<Either<Failure, void>> call() {
    throw UnimplementedError();
  }
}
