import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:gestion_ets_escom/features/shared/domain/entities/calendario_examen.dart';
import 'package:gestion_ets_escom/features/user/presentation/providers/notification_prefs_provider.dart';

const _kChannelId = 'ets_examenes';
const _kChannelName = 'Recordatorios de ETS';
const _kChannelDesc = 'Avisos sobre exámenes guardados en tu calendario';

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    tz.initializeTimeZones();
    final tzInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(tzInfo.identifier));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(
      const InitializationSettings(android: androidSettings),
    );
    _initialized = true;
  }

  Future<bool> requestPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    return await android?.requestNotificationsPermission() ?? false;
  }

  Future<void> cancelAll() => _plugin.cancelAll();

  Future<void> scheduleAll(
    List<CalendarioExamen> calendarioExamenes,
    NotificationPrefs prefs,
  ) async {
    await cancelAll();
    if (!prefs.enabled || calendarioExamenes.isEmpty) return;

    final now = tz.TZDateTime.now(tz.local);

    for (final ce in calendarioExamenes) {
      final exam = ce.examen;

      // Build fire time: exam date − daysBefore days, at user-chosen hour:minute
      final examDate = exam.fecha;
      final notifDate = tz.TZDateTime(
        tz.local,
        examDate.year,
        examDate.month,
        examDate.day,
        prefs.hour,
        prefs.minute,
      ).subtract(Duration(days: prefs.daysBefore));

      if (notifDate.isBefore(now)) continue;

      final body = prefs.daysBefore == 0
          ? 'Hoy a las ${exam.hora} · ${exam.salon.etiquetaSalon ?? ''}'
          : 'En ${prefs.daysBefore} día(s) · ${exam.hora} · ${exam.salon.etiquetaSalon ?? ''}';

      await _plugin.zonedSchedule(
        exam.id.hashCode.abs() % 100000,
        'ETS: ${exam.materia.nombre}',
        body,
        notifDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _kChannelId,
            _kChannelName,
            channelDescription: _kChannelDesc,
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }
}
