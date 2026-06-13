// ============================================================
// NOMBRE: failures.dart
// USO: Clases de fallo del dominio (Either<Failure, T>). Usadas
//      por los repositorios y casos de uso para representar
//      errores de servidor o caché de forma tipada.
// ============================================================
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}
