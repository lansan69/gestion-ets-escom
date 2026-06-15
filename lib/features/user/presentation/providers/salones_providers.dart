// ============================================================
// NOMBRE: salones_providers.dart
// USO: Providers de la feature de salones.
//      Expone el caso de uso GetSalones y el FutureProvider
//      que carga el catálogo completo de salones desde el
//      repositorio compartido.
// ============================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_ets_escom/core/providers/core_providers.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/salon.dart';
import 'package:gestion_ets_escom/features/shared/domain/usecases/catalogs/get_salones.dart';

// ── Use case ──────────────────────────────
final getSalonesProvider = Provider<GetSalones>(
  (ref) => GetSalones(ref.read(sharedRepositoryProvider)),
);

// ── Async data ────────────────────────────
// Carga el catálogo completo de salones. Usa FutureProvider porque
// GetSalones retorna Future (no Stream).
final salonesProvider = FutureProvider<List<Salon>>((ref) async {
  final result = await ref.read(getSalonesProvider)();
  return result.fold(
    (failure) => throw failure.message,
    (salones) => salones,
  );
});
