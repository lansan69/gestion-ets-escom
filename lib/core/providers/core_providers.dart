// ── External ──────────────────────────────
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gestion_ets_escom/features/shared/data/datasources/shared_remote_datasource.dart';
import 'package:gestion_ets_escom/features/shared/data/datasources/shared_remote_datasource_impl.dart';
import 'package:gestion_ets_escom/features/shared/data/repositories/shared_repository_impl.dart';
import 'package:gestion_ets_escom/features/shared/domain/repositories/shared_repository.dart';

final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);

// ── Datasource ────────────────────────────
final sharedDatasourceProvider = Provider<SharedRemoteDatasource>(
  (ref) => SharedRemoteDatasourceImpl(
    supabaseClient: ref.read(supabaseClientProvider),
  ),
);

// ── Repository ────────────────────────────
final sharedRepositoryProvider = Provider<SharedRepository>(
  (ref) => SharedRepositoryImpl(datasource: ref.read(sharedDatasourceProvider)),
);
