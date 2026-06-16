import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_ets_escom/core/providers/core_providers.dart';
import 'package:gestion_ets_escom/features/shared/data/models/salon_model.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/salon.dart';

// ── Búsqueda por número/etiqueta de salón ──────────────────────────────────
class _SalonSearchNotifier extends Notifier<String> {
  @override
  String build() => '';
  void set(String query) => state = query;
  void clear() => state = '';
}

final adminSalonSearchProvider =
    NotifierProvider<_SalonSearchNotifier, String>(_SalonSearchNotifier.new);

// ── Filtro por piso (conjunto vacío = todos) ────────────────────────────────
class _SalonPisoNotifier extends Notifier<Set<int>> {
  @override
  Set<int> build() => {};

  void toggle(int p) {
    final next = Set<int>.from(state);
    next.contains(p) ? next.remove(p) : next.add(p);
    state = next;
  }

  void setAll(Set<int> pisos) => state = Set<int>.from(pisos);

  void clear() => state = {};
}

final adminSalonPisoFilterProvider =
    NotifierProvider<_SalonPisoNotifier, Set<int>>(_SalonPisoNotifier.new);

// ── Salones inactivos (soft-deleted) para la vista de reactivación ──────────
final adminSalonesInactivosProvider = FutureProvider<List<Salon>>((ref) async {
  final client = ref.read(supabaseClientProvider);
  final response = await client
      .from('salon')
      .select()
      .eq('activo', false)
      .order('edificio')
      .order('piso')
      .order('numero_salon');
  return response
      .map((json) => SalonModel.fromJson(json).toEntity())
      .toList();
});
