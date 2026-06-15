import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/calendar_state_provider.dart';

class CustomCalendarGrid extends ConsumerWidget {
  const CustomCalendarGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calendarStateProvider);
    final notifier = ref.read(calendarStateProvider.notifier);

    // MOCK DATA para puntos. Aquí conectarás con tus providers reales
    final Map<DateTime, List<Color>> eventsMarkers = {
      DateTime.utc(2026, 6, 17): const [Color(0xFFE18301)], // Naranja
      DateTime.utc(2026, 6, 18): const [Color(0xFFE18301), Color(0xFFBA361B)], // Naranja, Rojo
      DateTime.utc(2026, 6, 19): const [Color(0xFF1680D1)], // Azul Institucional
      DateTime.utc(2026, 6, 20): const [Color(0xFF3C8041)], // Verde
    };

    // Mapeo enum app view -> TableCalendar format
    CalendarFormat calendarFormat = CalendarFormat.month;
    if (state.activeView == CalendarAppView.week) calendarFormat = CalendarFormat.week;

    // Si la vista es lista, ocultamos el calendario completamente
    if (state.activeView == CalendarAppView.list) return const SizedBox.shrink();

    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      locale: 'es_ES', // Asegúrate de inicializar locales en main.dart
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
        titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      daysOfWeekStyle: const DaysOfWeekStyle(
        weekdayStyle: TextStyle(color: Colors.grey),
        weekendStyle: TextStyle(color: Colors.grey),
      ),
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        selectedDecoration: const BoxDecoration(
          color: Color(0xFF0D47A1), // Azul profundo de selección
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: const Color(0xFFD4E1F5), // Azul pálido de toggle inactivo
          shape: BoxShape.circle,
        ),
        defaultTextStyle: const TextStyle(fontWeight: FontWeight.normal),
      ),
      // --- BUILDERS PERSONALIZADOS PARA PUNTOS ---
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, day, events) {
          // Normalizamos la fecha para buscar en el mock map
          final normalizedDay = DateTime.utc(day.year, day.month, day.day);
          final colors = eventsMarkers[normalizedDay];
          
          if (colors == null || colors.isEmpty) return const SizedBox.shrink();

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: colors.map((color) => Container(
              width: 5,
              height: 5,
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            )).toList(),
          );
        },
      ),
    );
  }
}