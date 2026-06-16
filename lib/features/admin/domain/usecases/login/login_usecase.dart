// ============================================================
// NOMBRE: login_usecase.dart
// USO: Caso de uso para autenticar a un administrativo con
//      correo y contraseña. Consumido por el panel de gestión.
// ============================================================
import 'package:dartz/dartz.dart';
import 'package:gestion_ets_escom/features/admin/domain/entities/administrativo.dart';
import 'package:gestion_ets_escom/features/admin/domain/repositories/auth_repository.dart';
import '../../../../../core/errors/failures.dart';

class LoginUseCase {
  final AuthRepository repository;
  const LoginUseCase(this.repository);

  Future<Either<Failure, Administrativo>> call({
    required String correo,
    required String contrasena,
  }) {
    return repository.login(correo: correo, contrasena: contrasena);
  }
}
