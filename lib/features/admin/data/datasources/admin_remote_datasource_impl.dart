// ============================================================
// NOMBRE: admin_remote_datasource_impl.dart
// USO: Implementación concreta del datasource admin. Realiza
//      operaciones CRUD de exámenes en Supabase. Pendiente de
//      implementar los métodos.
// ============================================================
import 'package:gestion_ets_escom/features/admin/data/datasources/admin_remote_datasource.dart';
import 'package:gestion_ets_escom/features/shared/data/models/examen_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminRemoteDatasourceImpl implements AdminRemoteDatasource {
  final supabaseClient = Supabase.instance.client;

  @override
  Future<ExamenModel> createExamen(Map<String, dynamic> data) {
    throw UnimplementedError();
  }

  @override
  Future<ExamenModel> updateExamen(int id, Map<String, dynamic> data) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteExamen(int id) {
    throw UnimplementedError();
  }
}
