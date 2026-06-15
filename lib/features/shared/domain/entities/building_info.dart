// ============================================================
// NOMBRE: building_info.dart
// USO: Entidades de dominio para el croquis interactivo del campus.
//      BuildingRegion describe la región táctil y visual de cada
//      edificio en coordenadas SVG. BuildingInfo almacena los
//      metadatos de pisos y etiqueta de cada edificio.
// ============================================================

import 'dart:ui';

class BuildingRegion {
  final String id;
  final int number;
  final Path path;
  final Rect bounds;

  BuildingRegion({
    required this.id,
    required this.number,
    required this.bounds,
  }) : path = (Path()..addRect(bounds));
}

class BuildingInfo {
  final List<int> floors;
  final String label;

  const BuildingInfo({required this.floors, required this.label});
}
