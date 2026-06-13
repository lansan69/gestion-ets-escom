import 'package:dartz/dartz.dart';
import 'package:gestion_ets_escom/core/errors/failures.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/examen.dart';
import 'package:gestion_ets_escom/features/shared/domain/repositories/shared_repository.dart';

class SearchExamenes {
  final SharedRepository repository;
  const SearchExamenes(this.repository);

  Future<Either<Failure, List<Examen>>> call({
    String? carreraId,
    int? semestre,
    String? materiaId,
    String? unidadAprendizaje,
    String? searchTerm,
  }) => repository.searchExamenes(
    carreraId: carreraId,
    semestre: semestre,
    materiaId: materiaId,
    unidadAprendizaje: unidadAprendizaje,
    searchTerm: searchTerm,
  );
}
