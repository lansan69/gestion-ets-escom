// ============================================================
// NOMBRE: login_usecase.dart
// USO: Caso de uso para autenticar a un administrativo con
//      correo y contraseña. Pendiente de implementar. Será
//      consumido por el panel de gestión.
// ============================================================
import 'package:dartz/dartz.dart';
import 'package:gestion_ets_escom/features/admin/domain/entities/administrativo.dart';
import 'package:gestion_ets_escom/features/admin/domain/repositories/auth_repository.dart';
import '../../../../../core/errors/failures.dart';

class LoginUseCase {
  final AuthRepository repository;
  const LoginUseCase(this.repository);

  // Recibe correo y contraseña y retorna el Administrativo autenticado o un Failure.
  Future<Either<Failure, Administrativo>> call({
    required String correo,
    required String contrasena,
  }) {
    throw UnimplementedError();
  }
}
