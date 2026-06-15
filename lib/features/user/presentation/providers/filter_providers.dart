// ============================================================
// NOMBRE: filter_providers.dart
// USO: Providers de estado para los filtros de búsqueda del app.
//      Almacena la selección activa de carrera, semestres, área,
//      turno, fecha y salón. Consumidos por FilterCard y las
//      pantallas que muestran resultados de ETS filtrados.
// ============================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─── Carrera ──────────────────────────────────────────────────────────────────

// Notifier que almacena el ID (UUID) de la carrera seleccionada en el filtro.
// El estado inicial es null (sin filtro de carrera; se muestran todas las carreras).
class FilterCarreraNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  // Establece la carrera a filtrar a partir de su ID.
  void select(String id) => state = id;

  // Limpia el filtro, mostrando exámenes de todas las carreras.
  void clear() => state = null;
}

// Provider que expone el Notifier del filtro de carrera.
// Consumido por FilterCard y las pantallas de resultados de ETS.
final filterCarreraProvider = NotifierProvider<FilterCarreraNotifier, String?>(
  FilterCarreraNotifier.new,
);

// ─── Semestres ────────────────────────────────────────────────────────────────

// Notifier que almacena la lista de semestres seleccionados como filtro.
// El estado inicial es una lista vacía (sin filtro de semestre; se muestran todos).
class FilterSemestresNotifier extends Notifier<List<int>> {
  @override
  List<int> build() => [];

  // Agrega un semestre al filtro si aún no está incluido.
  void add(int semestre) {
    if (!state.contains(semestre)) {
      state = [...state, semestre];
    }
  }

  // Quita un semestre del filtro.
  void remove(int semestre) =>
      state = state.where((s) => s != semestre).toList();

  // Limpia toda la selección de semestres.
  void clear() => state = [];
}

// Provider que expone el Notifier del filtro de semestres.
// Consumido por FilterCard y las pantallas de resultados de ETS.
final filterSemestresProvider =
    NotifierProvider<FilterSemestresNotifier, List<int>>(
      FilterSemestresNotifier.new,
    );

// ─── Área ─────────────────────────────────────────────────────────────────────

// Notifier que almacena el ID (UUID) del área de formación seleccionada.
// El estado inicial es null (sin filtro de área; se muestran todas las áreas).
class FilterAreaNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  // Establece el área a filtrar a partir de su ID.
  void select(String id) => state = id;

  // Limpia el filtro, mostrando exámenes de todas las áreas de formación.
  void clear() => state = null;
}

// Provider que expone el Notifier del filtro de área de formación.
// Consumido por FilterCard y las pantallas de resultados de ETS.
final filterAreaProvider = NotifierProvider<FilterAreaNotifier, String?>(
  FilterAreaNotifier.new,
);

// ─── Turno ────────────────────────────────────────────────────────────────────

// Notifier que almacena el turno seleccionado como filtro ('Matutino' o 'Vespertino').
// El estado inicial es null (sin filtro de turno; equivale a mostrar ambos turnos).
class FilterTurnoNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  // Establece el turno a filtrar.
  void select(String turno) => state = turno;

  // Limpia el filtro, mostrando exámenes de cualquier turno.
  void clear() => state = null;
}

// Provider que expone el Notifier del filtro de turno.
// Consumido por FilterCard y las pantallas de resultados de ETS.
final filterTurnoProvider = NotifierProvider<FilterTurnoNotifier, String?>(
  FilterTurnoNotifier.new,
);

// ─── Fecha ────────────────────────────────────────────────────────────────────

// Notifier que almacena la fecha exacta seleccionada como filtro.
// El estado inicial es null (sin filtro de fecha; se muestran todas las fechas).
class FilterFechaNotifier extends Notifier<DateTime?> {
  @override
  DateTime? build() => null;

  // Establece la fecha a filtrar.
  void select(DateTime fecha) => state = fecha;

  // Limpia el filtro de fecha.
  void clear() => state = null;
}

// Provider que expone el Notifier del filtro de fecha.
// Consumido por FilterCard y las pantallas de resultados de ETS.
final filterFechaProvider = NotifierProvider<FilterFechaNotifier, DateTime?>(
  FilterFechaNotifier.new,
);

// ─── Salón ────────────────────────────────────────────────────────────────────

// Notifier que almacena el ID (UUID) del salón seleccionado como filtro.
// El estado inicial es null (sin filtro de salón; se muestran todos los salones).
class FilterSalonNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  // Establece el salón a filtrar a partir de su ID.
  void select(String id) => state = id;

  // Limpia el filtro de salón.
  void clear() => state = null;
}

// Provider que expone el Notifier del filtro de salón.
// Consumido por FilterCard y las pantallas de resultados de ETS.
final filterSalonProvider = NotifierProvider<FilterSalonNotifier, String?>(
  FilterSalonNotifier.new,
);

// ─── Search input ─────────────────────────────────────────────────────────────
class FilterSearchbarNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  // Establece el salón a filtrar a partir de su ID.
  void select(String id) => state = id;

  // Limpia el filtro de salón.
  void clear() => state = null;
}

final filterSearchbarProvider =
    NotifierProvider<FilterSearchbarNotifier, String?>(
      FilterSearchbarNotifier.new,
    );
