import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_ets_escom/core/providers/core_providers.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/carrera.dart';
import 'package:gestion_ets_escom/features/shared/domain/usecases/catalogs/get_carreras.dart';

// ── Use case ──────────────────────────────
final getCarrerasProvider = Provider<GetCarreras>(
  (ref) => GetCarreras(ref.read(sharedRepositoryProvider)),
);

// ── Async data ────────────────────────────
final carrerasProvider = FutureProvider<List<Carrera>>((ref) async {
  final result = await ref.read(getCarrerasProvider)();
  return result.fold(
    (failure) => throw failure.message,
    (carreras) => carreras,
  );
});
