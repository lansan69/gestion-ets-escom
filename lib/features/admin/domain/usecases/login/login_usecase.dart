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
    throw UnimplementedError();
  }
}
