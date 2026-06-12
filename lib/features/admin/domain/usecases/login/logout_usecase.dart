import 'package:dartz/dartz.dart';
import 'package:gestion_ets_escom/features/admin/domain/repositories/auth_repository.dart';
import '../../../../../core/errors/failures.dart';

class LogoutUseCase {
  final AuthRepository repository;
  const LogoutUseCase(this.repository);

  Future<Either<Failure, void>> call() {
    throw UnimplementedError();
  }
}
