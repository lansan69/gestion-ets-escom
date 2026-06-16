// ============================================================
// NOMBRE: core_providers.dart
// USO: Proveedores globales del núcleo de la aplicación.
//      Expone el cliente de Supabase, el datasource remoto,
//      el datasource local (SQLite), el DatabaseHelper y el
//      repositorio compartido. Son consumidos por los providers
//      de features (carreras, materias, exámenes, etc.).
// ============================================================

// ── External ──────────────────────────────
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gestion_ets_escom/features/shared/data/datasources/local/database_helper.dart';
import 'package:gestion_ets_escom/features/shared/data/datasources/local/shared_local_datasource.dart';
import 'package:gestion_ets_escom/features/shared/data/datasources/local/shared_local_datasource_impl.dart';
import 'package:gestion_ets_escom/features/shared/data/datasources/shared_remote_datasource.dart';
import 'package:gestion_ets_escom/features/shared/data/datasources/shared_remote_datasource_impl.dart';
import 'package:gestion_ets_escom/features/shared/data/repositories/shared_repository_impl.dart';
import 'package:gestion_ets_escom/features/shared/domain/repositories/shared_repository.dart';
import 'package:gestion_ets_escom/features/shared/domain/usecases/cache/clear_cache.dart';
import 'package:gestion_ets_escom/features/shared/domain/usecases/calendario/add_to_calendario.dart';
import 'package:gestion_ets_escom/features/shared/domain/usecases/calendario/get_calendario_examenes.dart';
import 'package:gestion_ets_escom/features/shared/domain/usecases/calendario/remove_from_calendario.dart';
import 'package:gestion_ets_escom/features/shared/domain/usecases/preferencia/get_preferencia.dart';
import 'package:gestion_ets_escom/features/shared/domain/usecases/preferencia/has_preferencia.dart';
import 'package:gestion_ets_escom/features/shared/domain/usecases/preferencia/save_preferencia.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/preferencia.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/stats_result.dart';
import 'package:gestion_ets_escom/features/shared/domain/usecases/stats/get_stats.dart';

// Expone la instancia global del cliente de Supabase ya inicializado.
// Consumido por sharedDatasourceProvider y cualquier datasource que acceda a Supabase.
final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);

// ── Local storage ─────────────────────────
// Singleton que gestiona la base de datos SQLite local.
// Consumido únicamente por sharedLocalDatasourceProvider.
final databaseHelperProvider = Provider<DatabaseHelper>(
  (ref) => DatabaseHelper(),
);

// Datasource local (SQLite). Provee lectura y escritura del caché offline.
// Consumido únicamente por sharedRepositoryProvider.
final sharedLocalDatasourceProvider = Provider<SharedLocalDatasource>(
  (ref) => SharedLocalDatasourceImpl(
    dbHelper: ref.read(databaseHelperProvider),
  ),
);

// ── Remote datasource ─────────────────────
// Crea e inyecta el datasource remoto compartido con el cliente de Supabase.
// Consumido únicamente por sharedRepositoryProvider.
final sharedDatasourceProvider = Provider<SharedRemoteDatasource>(
  (ref) => SharedRemoteDatasourceImpl(
    supabaseClient: ref.read(supabaseClientProvider),
  ),
);

// ── Repository ────────────────────────────
// Instancia el repositorio compartido inyectando el datasource remoto y el local.
// Consumido por los providers de casos de uso de la feature shared.
final sharedRepositoryProvider = Provider<SharedRepository>(
  (ref) => SharedRepositoryImpl(
    datasource: ref.read(sharedDatasourceProvider),
    local: ref.read(sharedLocalDatasourceProvider),
  ),
);

// ── Preferencia ───────────────────────────
final hasPreferenciaProvider = Provider<HasPreferencia>(
  (ref) => HasPreferencia(ref.read(sharedRepositoryProvider)),
);

final getPreferenciaProvider = Provider<GetPreferencia>(
  (ref) => GetPreferencia(ref.read(sharedRepositoryProvider)),
);

final savePreferenciaProvider = Provider<SavePreferencia>(
  (ref) => SavePreferencia(ref.read(sharedRepositoryProvider)),
);

// Cached read of the active user preference — auto-disposed on tab exit.
final preferenciaProvider = FutureProvider.autoDispose<Preferencia?>((ref) async {
  final result = await ref.read(getPreferenciaProvider).call();
  return result.fold((_) => null, (p) => p);
});

// ── Calendario ────────────────────────────
final addToCalendarioProvider = Provider<AddToCalendario>(
  (ref) => AddToCalendario(ref.read(sharedRepositoryProvider)),
);

final isInCalendarioProvider = FutureProvider.family<bool, String>(
  (ref, examenId) async {
    final result = await ref
        .read(sharedRepositoryProvider)
        .isInCalendario(examenId);
    return result.fold((_) => false, (v) => v);
  },
);

final getCalendarioExamenesProvider = Provider<GetCalendarioExamenes>(
  (ref) => GetCalendarioExamenes(ref.read(sharedRepositoryProvider)),
);

final removeFromCalendarioProvider = Provider<RemoveFromCalendario>(
  (ref) => RemoveFromCalendario(ref.read(sharedRepositoryProvider)),
);

// ── Cache ─────────────────────────────────
final clearCacheProvider = Provider<ClearCache>(
  (ref) => ClearCache(ref.read(sharedRepositoryProvider)),
);

// ── Estadísticas ──────────────────────────
final getStatsProvider = Provider<GetStats>(
  (ref) => GetStats(ref.read(sharedRepositoryProvider)),
);

final statsProvider = FutureProvider<StatsResult>((ref) async {
  final result = await ref.read(getStatsProvider).call();
  return result.fold(
    (_) => throw Exception('Error al cargar estadísticas'),
    (stats) => stats,
  );
});
