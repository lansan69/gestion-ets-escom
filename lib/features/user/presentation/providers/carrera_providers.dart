// ============================================================
// NOMBRE: carrera_providers.dart
// USO: Providers de la feature de selección de carrera.
//      Expone el caso de uso GetCarreras y el FutureProvider
//      que carga asincrónicamente la lista de carreras desde
//      Supabase. Consumido por la pantalla OnboardingCarrera.
// ============================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_ets_escom/core/providers/core_providers.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/carrera.dart';
import 'package:gestion_ets_escom/features/shared/domain/usecases/carrera/get_carreras.dart';

// ── Use case ──────────────────────────────
// Provider del caso de uso GetCarreras. Inyecta el repositorio compartido.
// Consumido por carrerasProvider para ejecutar la consulta a Supabase.
final getCarrerasProvider = Provider<GetCarreras>(
  (ref) => GetCarreras(ref.read(sharedRepositoryProvider)),
);

// ── Async data ────────────────────────────
// Ejecuta el caso de uso y devuelve la lista de carreras disponibles.
// Si el repositorio retorna un Failure, lanza su mensaje para que el
// widget muestre el estado de error a través de AsyncValue.
final carrerasProvider = FutureProvider<List<Carrera>>((ref) async {
  final result = await ref.read(getCarrerasProvider)();
  return result.fold(
    (failure) => throw failure.message,
    (carreras) => carreras,
  );
});
