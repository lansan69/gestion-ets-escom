import 'package:dartz/dartz.dart';
import 'package:gestion_ets_escom/core/errors/failures.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/calendario_examen.dart';
import 'package:gestion_ets_escom/features/shared/domain/repositories/shared_repository.dart';

class GetCalendarioExamenes {
  final SharedRepository repository;
  const GetCalendarioExamenes(this.repository);

  Future<Either<Failure, List<CalendarioExamen>>> call() =>
      repository.getCalendarioExamenes();
}
