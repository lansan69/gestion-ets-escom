import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/calendar_state_provider.dart';

class CustomCalendarGrid extends ConsumerWidget {
  const CustomCalendarGrid({super.key, this.eventsMarkers = const {}});

  final Map<DateTime, List<Color>> eventsMarkers;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calendarStateProvider);
    final notifier = ref.read(calendarStateProvider.notifier);

    CalendarFormat calendarFormat = CalendarFormat.month;
    if (state.activeView == CalendarAppView.week) {
      calendarFormat = CalendarFormat.week;
    }

    if (state.activeView == CalendarAppView.list) return const SizedBox.shrink();

    return TableCalendar(
      rowHeight: 40,
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      locale: 'es_ES',
      focusedDay: state.focusedDay,
      calendarFormat: calendarFormat,
      availableCalendarFormats: const {
        CalendarFormat.month: 'Mes',
        CalendarFormat.week: 'Semana',
      },
      formatAnimationCurve: Curves.easeInOut,
      formatAnimationDuration: const Duration(milliseconds: 300),
      selectedDayPredicate: (day) => isSameDay(state.selectedDay, day),
      onDaySelected: notifier.onDaySelected,
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        leftChevronIcon: Icon(Icons.chevron_left, color: Color(0xFF0D47A1)),
        rightChevronIcon: Icon(Icons.chevron_right, color: Color(0xFF0D47A1)),
        titleTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      daysOfWeekStyle: const DaysOfWeekStyle(
        weekdayStyle: TextStyle(color: Colors.grey),
        weekendStyle: TextStyle(color: Colors.grey),
      ),
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        selectedDecoration: const BoxDecoration(
          color: Color(0xFF0D47A1),
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: const Color(0xFFD4E1F5),
          shape: BoxShape.circle,
        ),
        defaultTextStyle: const TextStyle(fontWeight: FontWeight.normal),
      ),
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, day, _) {
          final key = DateTime.utc(day.year, day.month, day.day);
          final colors = eventsMarkers[key];
          if (colors == null || colors.isEmpty) return const SizedBox.shrink();
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: colors
                .map(
                  (color) => Container(
                    width: 5,
                    height: 5,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}
