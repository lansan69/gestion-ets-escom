// ============================================================
// NOMBRE: api_constants.dart
// USO: Define constantes de nombres de tablas usadas en las
//      consultas a Supabase. Consumido por los datasources.
// ============================================================
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String storageFileUrl(String fileName) {
    final base = dotenv.env['SUPABASE_URL']!;
    return '$base/storage/v1/object/public/Material%20de%20apoyo/${Uri.encodeComponent(fileName)}';
  }
}

class Tables {
  static const String examenes = 'examenes';
  static const String materias = 'materias';
  static const String carreras = 'carreras';
  static const String salones = 'salones';
  static const String profesores = 'profesores';
  static const String administrativos = 'administrativos';
  static const String logs = 'logs';
}
