import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // <-- IMPORTANTE PARA LA FECHA
import '../widgets/calendar_view_toggle.dart';
import '../widgets/custom_calendar_grid.dart';
import '../widgets/calendar_exam_card.dart';
import '../providers/calendar_state_provider.dart';

class CalendarPage extends ConsumerWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calendarStateProvider);

    // Cambiamos Scaffold por Container para evitar conflictos con el AppShell
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // --- HEADER AZUL ---
          Container(
            color: const Color(0xFF0D47A1),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Mi Calendario',
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(shape: BoxShape.circle),
                          child: const Icon(Icons.notifications, color: Color(0xFFFFC107)),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(shape: BoxShape.circle),
                          child: const Icon(Icons.north_rounded, color: Colors.white, size: 20),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const CalendarViewToggle(),
          const SizedBox(height: 8),
          const CustomCalendarGrid(),
          const Divider(color: Color(0xFFEEEEEE), thickness: 1),
          
          // --- LISTA DE EXÁMENES ---
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero, // <-- ESTO ELIMINA EL ESPACIO EN BLANCO FANTASMA
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  child: Text(
                    '${DateFormat("d 'de' MMMM", "es_ES").format(state.selectedDay)} • 1 examen', // <-- FECHA DINÁMICA
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
                CalendarExamCard(
                  fecha: state.selectedDay,
                  materia: 'Compiladores',
                  detalles: 'ISC 2020 • Sal. 1007 • 9:30',
                  colorClave: const Color(0xFFE18301),
                ),
              ],
            ),
          ),
          
          // --- LEYENDA INFERIOR ---
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ColorLegendItem(color: Color(0xFF3C8041), label: 'Básica'),
                ColorLegendItem(color: Color(0xFFE18301), label: 'Profesional'),
                ColorLegendItem(color: Color(0xFFBA361B), label: 'Terminal'),
                ColorLegendItem(color: Color(0xFF1680D1), label: 'Institucional'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ColorLegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const ColorLegendItem({super.key, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}