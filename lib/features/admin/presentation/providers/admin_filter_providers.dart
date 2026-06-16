// ============================================================
// NOMBRE: admin_filter_providers.dart
// USO: Providers de filtro y examen para la feature admin.
//      Paralelo a filter_providers.dart y examenes_providers.dart
//      pero con scope propio (prefijo admin) para no colisionar.
//      Consumidos por el tab Gestionar del AdminDashboardPage.
// ============================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_ets_escom/core/providers/core_providers.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/area_formacion.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/examen.dart';

// ─── Base exam fetch ──────────────────────────────────────────────────────────

// Carga todos los exámenes desde Supabase directamente para el panel admin.
// Separado del provider de usuario para que cada feature mantenga su ciclo de vida.
// Se invalida con ref.invalidate(adminExamenesProvider) tras guardar cambios.
final adminExamenesProvider = FutureProvider<List<Examen>>((ref) async {
  final models = await ref.read(sharedDatasourceProvider).getExamenes();
  return List<Examen>.from(models);
});

// Áreas de formación únicas extraídas del stream admin — alimenta FilterCard.
final adminAreasFormacionProvider = Provider<AsyncValue<List<AreaFormacion>>>((ref) {
  final examsAsync = ref.watch(adminExamenesProvider);
  return examsAsync.whenData((exams) {
    final seen = <String>{};
    final areas = <AreaFormacion>[];
    for (final e in exams) {
      final af = e.materia.areaFormacion;
      if (af != null && seen.add(af.id)) areas.add(af);
    }
    return areas;
  });
});

// ─── Carrera ─────────────────────────────────────────────────────────────────

class AdminFilterCarreraNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};
  void add(String id) => state = {...state, id};
  void remove(String id) => state = state.where((s) => s != id).toSet();
  void clear() => state = {};
}

final adminFilterCarreraProvider =
    NotifierProvider<AdminFilterCarreraNotifier, Set<String>>(
  AdminFilterCarreraNotifier.new,
);

// ─── Semestres ────────────────────────────────────────────────────────────────

class AdminFilterSemestresNotifier extends Notifier<List<int>> {
  @override
  List<int> build() => [];
  void add(int semestre) {
    if (!state.contains(semestre)) state = [...state, semestre];
  }
  void remove(int semestre) =>
      state = state.where((s) => s != semestre).toList();
  void clear() => state = [];
}

final adminFilterSemestresProvider =
    NotifierProvider<AdminFilterSemestresNotifier, List<int>>(
  AdminFilterSemestresNotifier.new,
);

// ─── Área ─────────────────────────────────────────────────────────────────────

class AdminFilterAreaNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};
  void add(String id) => state = {...state, id};
  void remove(String id) => state = state.where((s) => s != id).toSet();
  void clear() => state = {};
}

final adminFilterAreaProvider =
    NotifierProvider<AdminFilterAreaNotifier, Set<String>>(
  AdminFilterAreaNotifier.new,
);

// ─── Turno ────────────────────────────────────────────────────────────────────

class AdminFilterTurnoNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void select(String turno) => state = turno;
  void clear() => state = null;
}

final adminFilterTurnoProvider =
    NotifierProvider<AdminFilterTurnoNotifier, String?>(
  AdminFilterTurnoNotifier.new,
);

// ─── Fecha ────────────────────────────────────────────────────────────────────

class AdminFilterFechaNotifier extends Notifier<DateTime?> {
  @override
  DateTime? build() => null;
  void select(DateTime fecha) => state = fecha;
  void clear() => state = null;
}

final adminFilterFechaProvider =
    NotifierProvider<AdminFilterFechaNotifier, DateTime?>(
  AdminFilterFechaNotifier.new,
);

// ─── Salón ────────────────────────────────────────────────────────────────────

class AdminFilterSalonNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void select(String id) => state = id;
  void clear() => state = null;
}

final adminFilterSalonProvider =
    NotifierProvider<AdminFilterSalonNotifier, String?>(
  AdminFilterSalonNotifier.new,
);

// ─── Search input ─────────────────────────────────────────────────────────────

class AdminFilterSearchbarNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void select(String text) => state = text;
  void clear() => state = null;
}

final adminFilterSearchbarProvider =
    NotifierProvider<AdminFilterSearchbarNotifier, String?>(
  AdminFilterSearchbarNotifier.new,
);

// ─── Filtered provider ────────────────────────────────────────────────────────
// Aplica los 7 filtros activos sobre la lista completa en memoria.
// Devuelve AsyncValue para que el consumidor maneje loading/error/data.
final adminExamenesFilteredProvider = Provider<AsyncValue<List<Examen>>>((ref) {
  final allAsync = ref.watch(adminExamenesProvider);
  final carrera = ref.watch(adminFilterCarreraProvider);
  final semestres = ref.watch(adminFilterSemestresProvider);
  final area = ref.watch(adminFilterAreaProvider);
  final turno = ref.watch(adminFilterTurnoProvider);
  final fecha = ref.watch(adminFilterFechaProvider);
  final salon = ref.watch(adminFilterSalonProvider);
  final search = ref.watch(adminFilterSearchbarProvider);

  return allAsync.whenData((all) {
    return all.where((e) {
      if (carrera.isNotEmpty && !carrera.contains(e.materia.carrera.id)) return false;
      if (semestres.isNotEmpty && !semestres.contains(e.materia.semestre)) {
        return false;
      }
      if (area.isNotEmpty && !area.contains(e.materia.areaFormacion?.id)) return false;
      if (turno != null && e.turno.value != turno.toUpperCase()) return false;
      if (fecha != null) {
        final examDay = DateTime(e.fecha.year, e.fecha.month, e.fecha.day);
        final filterDay = DateTime(fecha.year, fecha.month, fecha.day);
        if (examDay != filterDay) return false;
      }
      if (salon != null &&
          !e.salon.etiquetaSalon
              .toString()
              .toLowerCase()
              .contains(salon.toLowerCase())) {
        return false;
      }
      if (search != null && search.isNotEmpty) {
        final term = search.toLowerCase();
        if (!e.materia.nombre.toLowerCase().contains(term) &&
            !e.profesor.nombreCompleto.toLowerCase().contains(term)) {
          return false;
        }
      }
      return true;
    }).toList();
  });
});
