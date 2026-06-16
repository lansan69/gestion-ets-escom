// ============================================================
// NOMBRE: auth_repository_impl.dart
// USO: Implementación del repositorio de autenticación admin.
//      Delega al datasource remoto y mapea errores a Failures.
// ============================================================
import 'package:dartz/dartz.dart';
import 'package:gestion_ets_escom/core/errors/failures.dart';
import 'package:gestion_ets_escom/features/admin/data/datasources/auth_remote_datasource.dart';
import 'package:gestion_ets_escom/features/admin/domain/entities/administrativo.dart';
import 'package:gestion_ets_escom/features/admin/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remoteDatasource;

  AuthRepositoryImpl({required this.remoteDatasource});

  @override
  Future<Either<Failure, Administrativo>> login({
    required String correo,
    required String contrasena,
  }) async {
    try {
      final model = await remoteDatasource.login(
        correo: correo,
        contrasena: contrasena,
      );
      return Right(model.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDatasource.logout();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
