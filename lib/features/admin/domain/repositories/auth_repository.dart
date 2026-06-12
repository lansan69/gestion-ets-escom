import 'package:dartz/dartz.dart';
import 'package:gestion_ets_escom/core/errors/failures.dart';
import 'package:gestion_ets_escom/features/admin/domain/entities/administrativo.dart';

abstract class AuthRepository {
  Future<Either<Failure, Administrativo>> login({
    required String correo,
    required String contrasena,
  });

  Future<Either<Failure, void>> logout();
}
