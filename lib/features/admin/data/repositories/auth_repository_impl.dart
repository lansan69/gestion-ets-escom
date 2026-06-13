// ============================================================
// NOMBRE: auth_repository_impl.dart
// USO: Implementación del repositorio de autenticación admin.
//      Pendiente de implementar login y logout con Supabase Auth.
// ============================================================
import 'package:dartz/dartz.dart';
import 'package:gestion_ets_escom/core/errors/failures.dart';
import 'package:gestion_ets_escom/features/admin/domain/entities/administrativo.dart';
import 'package:gestion_ets_escom/features/admin/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<Either<Failure, Administrativo>> login({
    required String correo,
    required String contrasena,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> logout() {
    throw UnimplementedError();
  }
}
