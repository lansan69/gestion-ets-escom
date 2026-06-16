// ============================================================
// NOMBRE: stats_result.dart
// USO: Entidades de dominio para las estadísticas de exámenes
//      por carrera y área de formación. Consumidas por el
//      tab de estadísticas de AdminDashboardPage.
// ============================================================

class CarreraStats {
  final String carreraId;
  final String nombre;
  final String abreviatura;
  final int total;

  const CarreraStats({
    required this.carreraId,
    required this.nombre,
    required this.abreviatura,
    required this.total,
  });
}

class AreaStats {
  final String areaId;
  final String nombre;
  final String color;
  final int total;

  const AreaStats({
    required this.areaId,
    required this.nombre,
    required this.color,
    required this.total,
  });
}

class StatsResult {
  final List<CarreraStats> porCarrera;
  final List<AreaStats> porArea;
  final int totalExamenes;
  final int totalCarreras;
  final int totalAreas;

  const StatsResult({
    required this.porCarrera,
    required this.porArea,
    required this.totalExamenes,
    required this.totalCarreras,
    required this.totalAreas,
  });

  static const empty = StatsResult(
    porCarrera: [],
    porArea: [],
    totalExamenes: 0,
    totalCarreras: 0,
    totalAreas: 0,
  );
}
