import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/calendar_state_provider.dart';

class CalendarViewToggle extends ConsumerWidget {
  const CalendarViewToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeView = ref.watch(calendarStateProvider).activeView;
    final notifier = ref.read(calendarStateProvider.notifier);

    const activeColor = Color(0xFF0D47A1); // Azul profundo
    const inactiveColor = Color(0xFFD4E1F5); // Azul pálido

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0), // Ajuste de padding centrado
      child: Container(
        height: kToolbarHeight - 8,
        decoration: BoxDecoration(
          color: inactiveColor,
          borderRadius: BorderRadius.circular(30), // Menos redondeado que el diseño anterior
        ),
        child: Row(
          children: [
            _buildTab(context, 'Mes', activeView == CalendarAppView.month, () => notifier.setActiveView(CalendarAppView.month), activeColor, inactiveColor),
            _buildTab(context, 'Semana', activeView == CalendarAppView.week, () => notifier.setActiveView(CalendarAppView.week), activeColor, inactiveColor),
            _buildTab(context, 'Lista', activeView == CalendarAppView.list, () => notifier.setActiveView(CalendarAppView.list), activeColor, inactiveColor),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(BuildContext context, String text, bool isActive, VoidCallback onTap, Color activeColor, Color inactiveColor) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.black,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}