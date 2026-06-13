// ============================================================
// NOMBRE: examen_filter.dart
// USO: Modelo inmutable de filtros para buscar exámenes. Consumido
//      por ExamenFilterNotifier y el caso de uso SearchExamenes.
// ============================================================

class ExamenFilter {
  final String? carreraId;
  final List<int> semestres;
  final String? materiaId;
  final String? areaFormacion;
  final String? searchTerm;

  const ExamenFilter({
    this.carreraId,
    this.semestres = const [],
    this.materiaId,
    this.areaFormacion,
    this.searchTerm,
  });

  // Retorna una copia del filtro actualizando solo los campos proporcionados.
  ExamenFilter copyWith({
    String? carreraId,
    List<int>? semestres,
    String? materiaId,
    String? areaFormacion,
    String? searchTerm,
  }) => ExamenFilter(
    carreraId: carreraId ?? this.carreraId,
    semestres: semestres ?? this.semestres,
    materiaId: materiaId ?? this.materiaId,
    areaFormacion: areaFormacion ?? this.areaFormacion,
    searchTerm: searchTerm ?? this.searchTerm,
  );
}
