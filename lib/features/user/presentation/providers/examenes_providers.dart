import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_ets_escom/core/providers/core_providers.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/examen.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/examen_filter.dart';
import 'package:gestion_ets_escom/features/shared/domain/usecases/examen/search_examenes.dart';

class ExamenFilterNotifier extends Notifier<ExamenFilter> {
  @override
  ExamenFilter build() => const ExamenFilter();

  void setCarrera(String? id) => state = state.copyWith(carreraId: id);
  void setSemestre(int? s) => state = state.copyWith(semestre: s);
  void setMateria(String? id) => state = state.copyWith(materiaId: id);
  void setSearchTerm(String? term) => state = state.copyWith(searchTerm: term);
  void clear() => state = const ExamenFilter();
}

final examenFilterProvider =
    NotifierProvider<ExamenFilterNotifier, ExamenFilter>(
      ExamenFilterNotifier.new,
    );

// ── Use case ──────────────────────────────
final buscarExamenesProvider = Provider<SearchExamenes>(
  (ref) => SearchExamenes(ref.read(sharedRepositoryProvider)),
);

// ── Async data ────────────────────────────
// Se usa ref.watch para que el provider se recalcule al cambiar el filtro activo.
final examenesProvider = FutureProvider<List<Examen>>((ref) async {
  final filter = ref.watch(examenFilterProvider);

  final result = await ref.read(buscarExamenesProvider).call(
    carreraId: filter.carreraId,
    semestre: filter.semestre,
    materiaId: filter.materiaId,
    unidadAprendizaje: filter.unidadAprendizaje,
    searchTerm: filter.searchTerm,
  );
  return result.fold((f) => throw f.message, (examenes) => examenes);
});
