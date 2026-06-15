import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

// Definimos un enum para manejar la vista de "Lista" que no es nativa de TableCalendar
enum CalendarAppView { month, week, list }

class CalendarState {
  final DateTime focusedDay;
  final DateTime selectedDay;
  final CalendarAppView activeView;

  CalendarState({
    required this.focusedDay,
    required this.selectedDay,
    required this.activeView,
  });

  CalendarState copyWith({
    DateTime? focusedDay,
    DateTime? selectedDay,
    CalendarAppView? activeView,
  }) {
    return CalendarState(
      focusedDay: focusedDay ?? this.focusedDay,
      selectedDay: selectedDay ?? this.selectedDay,
      activeView: activeView ?? this.activeView,
    );
  }
}

class CalendarStateNotifier extends Notifier<CalendarState> {
  @override
  CalendarState build() {
    final now = DateTime.now();
    return CalendarState(
      focusedDay: now,
      selectedDay: now,
      activeView: CalendarAppView.month, // Mes por defecto
    );
  }

  void setActiveView(CalendarAppView view) {
    state = state.copyWith(activeView: view);
  }

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    state = state.copyWith(selectedDay: selectedDay, focusedDay: focusedDay);
  }
}

final calendarStateProvider = NotifierProvider<CalendarStateNotifier, CalendarState>(
  () => CalendarStateNotifier(),
);