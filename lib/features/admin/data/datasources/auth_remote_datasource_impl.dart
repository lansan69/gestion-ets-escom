// ============================================================
// NOMBRE: auth_remote_datasource_impl.dart
// USO: Implementación concreta del datasource de autenticación
//      admin. Autentica con Supabase Auth y obtiene el perfil
//      administrativo de la tabla pública.
// ============================================================
import 'package:gestion_ets_escom/features/admin/data/datasources/auth_remote_datasource.dart';
import 'package:gestion_ets_escom/features/admin/data/models/administrativo_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final SupabaseClient supabaseClient;

  AuthRemoteDatasourceImpl({required this.supabaseClient});

  @override
  Future<AdministrativoModel> login({
    required String correo,
    required String contrasena,
  }) async {
    final authResponse = await supabaseClient.auth.signInWithPassword(
      email: correo,
      password: contrasena,
    );

    if (authResponse.user == null) {
      throw Exception('Credenciales inválidas');
    }

    final data = await supabaseClient
        .from('administrativo')
        .select()
        .eq('correo', correo)
        .single();

    return AdministrativoModel.fromJson(data);
  }

  @override
  Future<void> logout() async {
    await supabaseClient.auth.signOut();
  }
}
