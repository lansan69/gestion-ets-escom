// ============================================================
// NOMBRE: get_stats.dart
// USO: Caso de uso que obtiene las estadísticas de exámenes
//      agrupadas por carrera y área de formación desde el
//      caché local (SQLite). Consumido por statsProvider.
// ============================================================
import 'package:dartz/dartz.dart';
import 'package:gestion_ets_escom/core/errors/failures.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/stats_result.dart';
import 'package:gestion_ets_escom/features/shared/domain/repositories/shared_repository.dart';

class GetStats {
  final SharedRepository repository;
  const GetStats(this.repository);

  Future<Either<Failure, StatsResult>> call() => repository.getStats();
}
