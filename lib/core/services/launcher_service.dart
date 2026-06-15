// ============================================================
// NOMBRE: launcher_service.dart
// USO: Servicio para abrir URLs y ubicaciones externas desde
//      la app. Consumido por IndividualMateriaView para abrir
//      PDFs de guía y proyecto desde Supabase Storage.
// ============================================================
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';

class LauncherService {
  // URL pública del bucket "Material de apoyo" en Supabase Storage.
  // La URL base se lee de dotenv (ya cargado en main.dart antes del runApp).
  static String _pdfUrl(String fileName) {
    final base = dotenv.env['SUPABASE_URL']!;
    return '$base/storage/v1/object/public/Material%20de%20apoyo/$fileName';
  }

  // Abre el PDF del examen en el navegador o visor externo del dispositivo.
  Future<void> openPdf(String fileName) async {
    final uri = Uri.parse(_pdfUrl(fileName));
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('No se pudo abrir el archivo: $fileName');
    }
  }

  // Abre la ubicación del salón en mapas a partir de su etiqueta.
  Future<void> openClassroomLocation(String salon) async {
    throw UnimplementedError();
  }

  // Abre el canal de soporte (correo o URL externa).
  Future<void> contactSupport() async {
    throw UnimplementedError();
  }
}
