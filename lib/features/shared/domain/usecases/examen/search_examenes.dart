// ============================================================
// NOMBRE: search_examenes.dart
// USO: Caso de uso que busca exámenes con filtros opcionales.
//      Consumido por examenesProvider en examenes_providers.dart.
// ============================================================
import 'package:dartz/dartz.dart';
import 'package:gestion_ets_escom/core/errors/failures.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/examen.dart';
import 'package:gestion_ets_escom/features/shared/domain/repositories/shared_repository.dart';

class SearchExamenes {
  final SharedRepository repository;
  const SearchExamenes(this.repository);

  // Aplica los filtros opcionales de carrera, semestres, materia y texto libre.
  Future<Either<Failure, List<Examen>>> call({
    String? carreraId,
    List<int>? semestres,
    String? materiaId,
    String? unidadAprendizaje,
    String? searchTerm,
  }) => repository.searchExamenes(
    carreraId: carreraId,
    semestres: semestres,
    materiaId: materiaId,
    unidadAprendizaje: unidadAprendizaje,
    searchTerm: searchTerm,
  );
}
