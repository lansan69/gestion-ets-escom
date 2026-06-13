// ============================================================
// NOMBRE: get_examenes.dart
// USO: Caso de uso que obtiene la lista completa de exámenes
//      activos sin filtros. Consumido por examenesProvider para
//      la carga inicial; el filtrado se hace en memoria.
// ============================================================
import 'package:dartz/dartz.dart';
import 'package:gestion_ets_escom/core/errors/failures.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/examen.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/examen_filter.dart';
import 'package:gestion_ets_escom/features/shared/domain/repositories/shared_repository.dart';

class GetExamenes {
  final SharedRepository repository;
  const GetExamenes(this.repository);

  // Devuelve un Stream offline-first: emite caché local primero y luego datos remotos.
  // El filtro opcional se usa para pre-filtrar la consulta local (carreraId, semestres).
  Stream<Either<Failure, List<Examen>>> call([ExamenFilter? filter]) =>
      repository.getExamenes(filter);
}
