import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/app_colors.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/background_pattern_painter.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendario extends ConsumerStatefulWidget {
  const Calendario({super.key});

  @override
  ConsumerState<Calendario> createState() => _CalendarioState();
}

class _CalendarioState extends ConsumerState<Calendario> {
  @override
  Widget build(BuildContext context) {
    final topOffset = MediaQuery.of(context).padding.top + 10;

    return Container(
      height: double.infinity,
      width: double.infinity,
      color: AppColors.primaryDarkBlue,
      child: Stack(
        children: [
          CustomPaint(size: Size.infinite, painter: BackgroundPatternPainter()),
          Positioned(
            top: topOffset,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.backgroundWhite,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: CalendarMonth(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CalendarWeek extends StatelessWidget {
  const CalendarWeek({super.key});

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      availableCalendarFormats: const {CalendarFormat.week: 'Semana'},
      calendarFormat: CalendarFormat.week,
      locale: 'es_MX',
      firstDay: DateTime.utc(2010, 10, 16),
      lastDay: DateTime.utc(2030, 3, 14),
      focusedDay: DateTime.now(),
    );
  }
}

class CalendarMonth extends StatelessWidget {
  const CalendarMonth({super.key});

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      availableCalendarFormats: const {CalendarFormat.month: 'Mes'},
      calendarFormat: CalendarFormat.month,
      locale: 'es_MX',
      firstDay: DateTime.utc(2010, 10, 16),
      lastDay: DateTime.utc(2030, 3, 14),
      focusedDay: DateTime.now(),
    );
  }
}
