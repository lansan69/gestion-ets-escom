import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_ets_escom/core/providers/core_providers.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/carrera.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/examen.dart';
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
  final models =
      await ref.read(adminRemoteDatasourceProvider).getSalonesInactivos();
  return models.map((m) => m.toEntity()).toList();
});

// ── Catálogo de salones activos (id + etiqueta) para el dropdown de edición ──
final adminSalonesActivosCatalogProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.read(adminRemoteDatasourceProvider).getCatalogSalonesActivos();
});

// ── Catálogo de materias activas (id + nombre + carrera) para el dropdown de alta ──
final adminMateriasActivasCatalogProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.read(adminRemoteDatasourceProvider).getCatalogMaterias();
});

// ── Catálogo de profesores activos (id + nombre + apellido + correo) para el dropdown ──
final adminProfesoresActivosCatalogProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.read(adminRemoteDatasourceProvider).getCatalogProfesores();
});

// ── Carreras inactivas (soft-deleted) para la vista de reactivación ──────────
final adminCarrerasInactivasProvider = FutureProvider<List<Carrera>>((ref) async {
  final models = await ref.read(adminRemoteDatasourceProvider).getCarrerasInactivas();
  return models.map((m) => m.toEntity()).toList();
});

// ── Exámenes inactivos (soft-deleted) para la vista de reactivación ──────────
final adminExamenesInactivosProvider = FutureProvider<List<Examen>>((ref) async {
  final models = await ref.read(adminRemoteDatasourceProvider).getExamenesInactivos();
  return models.map((m) => m.toEntity()).toList();
});
