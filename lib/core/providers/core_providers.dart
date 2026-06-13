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
