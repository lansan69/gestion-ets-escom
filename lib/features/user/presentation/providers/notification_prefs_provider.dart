import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_ets_escom/features/shared/data/datasources/local/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class NotificationPrefs {
  final bool enabled;
  final int daysBefore;
  final int hour;
  final int minute;

  const NotificationPrefs({
    this.enabled = true,
    this.daysBefore = 1,
    this.hour = 8,
    this.minute = 0,
  });

  NotificationPrefs copyWith({
    bool? enabled,
    int? daysBefore,
    int? hour,
    int? minute,
  }) =>
      NotificationPrefs(
        enabled: enabled ?? this.enabled,
        daysBefore: daysBefore ?? this.daysBefore,
        hour: hour ?? this.hour,
        minute: minute ?? this.minute,
      );

  Map<String, dynamic> toMap() => {
        'id': 1,
        'enabled': enabled ? 1 : 0,
        'days_before': daysBefore,
        'hour': hour,
        'minute': minute,
      };

  factory NotificationPrefs.fromMap(Map<String, dynamic> map) =>
      NotificationPrefs(
        enabled: (map['enabled'] as int? ?? 1) == 1,
        daysBefore: map['days_before'] as int? ?? 1,
        hour: map['hour'] as int? ?? 8,
        minute: map['minute'] as int? ?? 0,
      );
}

class NotificationPrefsNotifier extends AsyncNotifier<NotificationPrefs> {
  @override
  Future<NotificationPrefs> build() async {
    final db = await DatabaseHelper().database;
    final rows = await db.query(
      'notification_prefs',
      where: 'id = 1',
      limit: 1,
    );
    if (rows.isEmpty) return const NotificationPrefs();
    return NotificationPrefs.fromMap(rows.first);
  }

  Future<void> save(NotificationPrefs prefs) async {
    final db = await DatabaseHelper().database;
    await db.insert(
      'notification_prefs',
      prefs.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    state = AsyncData(prefs);
  }
}

final notificationPrefsProvider =
    AsyncNotifierProvider<NotificationPrefsNotifier, NotificationPrefs>(
  NotificationPrefsNotifier.new,
);
