// ============================================================
// NOMBRE: notification_service.dart
// USO: Servicio de notificaciones locales programadas. Pendiente
//      de implementar. Será consumido por IndividualMateriaView
//      para agendar recordatorios de exámenes.
// ============================================================

class NotificationService {
  // Inicializa el canal de notificaciones al arrancar la app.
  Future<void> init() async {
    throw UnimplementedError();
  }

  // Programa una notificación local. Requiere id único, título,
  // cuerpo del mensaje y la fecha en que debe dispararse.
  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    throw UnimplementedError();
  }
}
