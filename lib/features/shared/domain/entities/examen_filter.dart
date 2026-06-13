class ExamenFilter {
  final String? carreraId;
  final int? semestre;
  final String? materiaId;
  final String? unidadAprendizaje;
  final String? searchTerm;

  const ExamenFilter({
    this.carreraId,
    this.semestre,
    this.materiaId,
    this.unidadAprendizaje,
    this.searchTerm,
  });

  ExamenFilter copyWith({
    String? carreraId,
    int? semestre,
    String? materiaId,
    String? unidadAprendizaje,
    String? searchTerm,
  }) => ExamenFilter(
    carreraId: carreraId ?? this.carreraId,
    semestre: semestre ?? this.semestre,
    materiaId: materiaId ?? this.materiaId,
    unidadAprendizaje: unidadAprendizaje ?? this.unidadAprendizaje,
    searchTerm: searchTerm ?? this.searchTerm,
  );
}
