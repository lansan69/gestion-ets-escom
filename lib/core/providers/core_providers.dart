// ============================================================
// NOMBRE: core_providers.dart
// USO: Proveedores globales del núcleo de la aplicación.
//      Expone el cliente de Supabase, el datasource compartido
//      y el repositorio compartido. Son consumidos por los
//      providers de features (carreras, materias, etc.).
// ============================================================

// ── External ──────────────────────────────
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gestion_ets_escom/features/shared/data/datasources/shared_remote_datasource.dart';
import 'package:gestion_ets_escom/features/shared/data/datasources/shared_remote_datasource_impl.dart';
import 'package:gestion_ets_escom/features/shared/data/repositories/shared_repository_impl.dart';
import 'package:gestion_ets_escom/features/shared/domain/repositories/shared_repository.dart';

// Expone la instancia global del cliente de Supabase ya inicializado.
// Consumido por sharedDatasourceProvider y cualquier datasource que acceda a Supabase.
final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);

// ── Datasource ────────────────────────────
// Crea e inyecta el datasource remoto compartido con el cliente de Supabase.
// Consumido únicamente por sharedRepositoryProvider.
final sharedDatasourceProvider = Provider<SharedRemoteDatasource>(
  (ref) => SharedRemoteDatasourceImpl(
    supabaseClient: ref.read(supabaseClientProvider),
  ),
);

// ── Repository ────────────────────────────
// Instancia el repositorio compartido inyectando el datasource remoto.
// Consumido por los providers de casos de uso de la feature shared (getCarrerasProvider, etc.).
final sharedRepositoryProvider = Provider<SharedRepository>(
  (ref) => SharedRepositoryImpl(datasource: ref.read(sharedDatasourceProvider)),
);
