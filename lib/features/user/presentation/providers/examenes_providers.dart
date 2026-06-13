// ============================================================
// NOMBRE: examenes_providers.dart
// USO: Providers para la búsqueda y filtrado de exámenes ETS.
//      Expone el Notifier de filtros, el caso de uso y el
//      FutureProvider reactivo. Consumidos por DashboardMaterias
//      y ExploreMateriasSelection.
// ============================================================
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_ets_escom/core/providers/core_providers.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/examen.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/examen_filter.dart';
import 'package:gestion_ets_escom/features/shared/domain/usecases/examen/search_examenes.dart';
import 'package:gestion_ets_escom/features/user/presentation/providers/selection_providers.dart';

// Notifier que gestiona el estado del filtro activo de exámenes.
// Consumido por examenesProvider para disparar nuevas consultas.
class ExamenFilterNotifier extends Notifier<ExamenFilter> {
  @override
  ExamenFilter build() {
    final carreraId = ref.watch(selectedCarreraProvider);
    final semestres = ref.watch(selectedSemestresProvider);
    return ExamenFilter(carreraId: carreraId, semestres: semestres);
  }

  void setCarrera(String? id) => state = state.copyWith(carreraId: id);
  void setSemestres(List<int> semestres) => state = state.copyWith(semestres: semestres);
  void clearSemestres() => state = state.copyWith(semestres: []);
  void setMateria(String? id) => state = state.copyWith(materiaId: id);
  void setSearchTerm(String? term) => state = state.copyWith(searchTerm: term);
  void clear() => state = const ExamenFilter();
}

final examenFilterProvider =
    NotifierProvider<ExamenFilterNotifier, ExamenFilter>(
      ExamenFilterNotifier.new,
    );

// ── Use case ──────────────────────────────
// Provider del caso de uso SearchExamenes. Consumido únicamente por examenesProvider.
final buscarExamenesProvider = Provider<SearchExamenes>(
  (ref) => SearchExamenes(ref.read(sharedRepositoryProvider)),
);

// ── Async data ────────────────────────────
// Se usa ref.watch para que el provider se recalcule al cambiar el filtro activo.
final examenesProvider = FutureProvider<List<Examen>>((ref) async {
  final filter = ref.watch(examenFilterProvider);

  final result = await ref.read(buscarExamenesProvider).call(
    carreraId: filter.carreraId,
    semestres: filter.semestres.isEmpty ? null : filter.semestres,
    materiaId: filter.materiaId,
    unidadAprendizaje: filter.unidadAprendizaje,
    searchTerm: filter.searchTerm,
  );
  return result.fold((f) => throw f.message, (examenes) => examenes);
});
