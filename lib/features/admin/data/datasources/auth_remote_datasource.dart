import 'package:gestion_ets_escom/features/admin/data/models/administrativo_model.dart';

abstract class AuthRemoteDatasource {
  Future<AdministrativoModel> login({
    required String correo,
    required String contrasena,
  });

  Future<void> logout();
}
