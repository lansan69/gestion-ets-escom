// ============================================================
// NOMBRE: carrera_providers.dart
// USO: Providers de la feature de selección de carrera.
//      Expone el caso de uso GetCarreras y el StreamProvider
//      que carga las carreras con estrategia offline-first:
//      emite el caché local primero y luego los datos remotos.
//      Consumido por la pantalla OnboardingCarrera.
// ============================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_ets_escom/core/providers/core_providers.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/carrera.dart';
import 'package:gestion_ets_escom/features/shared/domain/usecases/carrera/get_carreras.dart';

// ── Use case ──────────────────────────────
// Provider del caso de uso GetCarreras. Inyecta el repositorio compartido.
// Consumido por carrerasProvider para ejecutar la consulta offline-first.
final getCarrerasProvider = Provider<GetCarreras>(
  (ref) => GetCarreras(ref.read(sharedRepositoryProvider)),
);

// ── Async data ────────────────────────────
// Escucha el Stream offline-first del caso de uso: primero emite el caché
// local y luego los datos frescos de Supabase cuando estén disponibles.
// Si el repositorio emite un Failure, lanza su mensaje para que el widget
// lo muestre a través del estado de error de AsyncValue.
final carrerasProvider = StreamProvider<List<Carrera>>((ref) {
  return ref.read(getCarrerasProvider)().map(
    (either) => either.fold(
      (failure) => throw failure.message,
      (carreras) => carreras,
    ),
  );
});
