// ============================================================
// NOMBRE: auth_remote_datasource_impl.dart
// USO: Implementación concreta del datasource de autenticación
//      admin. Pendiente de implementar con Supabase Auth.
// ============================================================
import 'package:gestion_ets_escom/features/admin/data/datasources/auth_remote_datasource.dart';
import 'package:gestion_ets_escom/features/admin/data/models/administrativo_model.dart';

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  @override
  Future<AdministrativoModel> login({
    required String correo,
    required String contrasena,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> logout() {
    throw UnimplementedError();
  }
}
