import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:gestion_ets_escom/core/providers/core_providers.dart';
import 'package:gestion_ets_escom/core/utils/text_utils.dart';
import 'package:gestion_ets_escom/features/admin/domain/usecases/catalogs/create_materia.dart';
import 'package:gestion_ets_escom/features/admin/domain/usecases/catalogs/delete_materia.dart';
import 'package:gestion_ets_escom/features/admin/domain/usecases/catalogs/update_materia.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/area_formacion.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/materia.dart';

// ── Lista de materias por carrera (raw desde Supabase) ─────────────────────
final adminMateriasRawProvider =
    FutureProvider.family<List<Materia>, String>((ref, carreraId) async {
  final result =
      await ref.read(sharedRepositoryProvider).getMaterias(carreraId);
  return result.fold((f) => throw Exception(f.message), (list) => list);
});

// ── Búsqueda por nombre ─────────────────────────────────────────────────────
class _SearchNotifier extends Notifier<String> {
  @override
  String build() => '';
  void set(String query) => state = query;
  void clear() => state = '';
}

final adminMateriaSearchProvider =
    NotifierProvider<_SearchNotifier, String>(_SearchNotifier.new);

// ── Filtro por semestres (conjunto vacío = todos) ───────────────────────────
class _SemestresNotifier extends Notifier<Set<int>> {
  @override
  Set<int> build() => {};

  void toggle(int s) {
    final next = Set<int>.from(state);
    next.contains(s) ? next.remove(s) : next.add(s);
    state = next;
  }

  void setAll(Set<int> semestres) => state = Set<int>.from(semestres);

  void clear() => state = {};
}

final adminMateriaSemestresProvider =
    NotifierProvider<_SemestresNotifier, Set<int>>(_SemestresNotifier.new);

// ── Filtro por área de formación (null = todas) ─────────────────────────────
class _AreaNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void set(String? areaId) => state = areaId;
}

final adminMateriaAreaProvider =
    NotifierProvider<_AreaNotifier, String?>(_AreaNotifier.new);

// ── Lista filtrada (combina raw + búsqueda + semestres + área) ──────────────
final adminMateriasFilteredProvider =
    Provider.family<AsyncValue<List<Materia>>, String>((ref, carreraId) {
  final raw = ref.watch(adminMateriasRawProvider(carreraId));
  final search = removeDiacritics(ref.watch(adminMateriaSearchProvider).trim());
  final semestres = ref.watch(adminMateriaSemestresProvider);
  final areaId = ref.watch(adminMateriaAreaProvider);

  return raw.whenData((list) {
    var filtered = list;
    if (search.isNotEmpty) {
      filtered =
          filtered.where((m) => removeDiacritics(m.nombre).contains(search)).toList();
    }
    if (semestres.isNotEmpty) {
      filtered = filtered.where((m) => semestres.contains(m.semestre)).toList();
    }
    if (areaId != null) {
      filtered =
          filtered.where((m) => m.areaFormacion?.id == areaId).toList();
    }
    return filtered;
  });
});

// ── Áreas de formación (para dropdown en modal y chips en filtro) ───────────
final areasFormacionProvider =
    FutureProvider<List<AreaFormacion>>((ref) async {
  final result =
      await ref.read(sharedRepositoryProvider).getAreasFormacion();
  return result.fold((f) => throw Exception(f.message), (list) => list);
});

// ── Estado de mutación de materia ───────────────────────────────────────────
class AdminMateriaMutationState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  const AdminMateriaMutationState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  AdminMateriaMutationState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
  }) =>
      AdminMateriaMutationState(
        isLoading: isLoading ?? this.isLoading,
        errorMessage: errorMessage ?? this.errorMessage,
        isSuccess: isSuccess ?? this.isSuccess,
      );
}

class AdminMateriaMutationNotifier
    extends Notifier<AdminMateriaMutationState> {
  @override
  AdminMateriaMutationState build() => const AdminMateriaMutationState();

  CreateMateria get _create =>
      CreateMateria(ref.read(adminRepositoryProvider));
  UpdateMateria get _update =>
      UpdateMateria(ref.read(adminRepositoryProvider));
  DeleteMateria get _delete =>
      DeleteMateria(ref.read(adminRepositoryProvider));

  Future<void> addMateria(Materia materia) async {
    state = state.copyWith(isLoading: true, errorMessage: null, isSuccess: false);
    final result = await _create(
      materia.id.isEmpty ? _withNewId(materia) : materia,
    );
    result.fold(
      (f) => state = state.copyWith(isLoading: false, errorMessage: f.message),
      (_) => state = state.copyWith(isLoading: false, isSuccess: true),
    );
  }

  Future<void> editMateria(Materia materia) async {
    state = state.copyWith(isLoading: true, errorMessage: null, isSuccess: false);
    final result = await _update(materia);
    result.fold(
      (f) => state = state.copyWith(isLoading: false, errorMessage: f.message),
      (_) => state = state.copyWith(isLoading: false, isSuccess: true),
    );
  }

  Future<void> removeMateria(String id) async {
    state = state.copyWith(isLoading: true, errorMessage: null, isSuccess: false);
    final result = await _delete(id);
    result.fold(
      (f) => state = state.copyWith(isLoading: false, errorMessage: f.message),
      (_) => state = state.copyWith(isLoading: false, isSuccess: true),
    );
  }

  void resetState() => state = const AdminMateriaMutationState();

  Materia _withNewId(Materia m) => Materia(
        id: const Uuid().v4(),
        nombre: m.nombre,
        carrera: m.carrera,
        semestre: m.semestre,
        activo: m.activo,
        areaFormacion: m.areaFormacion,
      );
}

final adminMateriaMutationProvider = NotifierProvider<
    AdminMateriaMutationNotifier, AdminMateriaMutationState>(
  AdminMateriaMutationNotifier.new,
);
