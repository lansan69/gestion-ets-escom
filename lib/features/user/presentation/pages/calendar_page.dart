import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_ets_escom/core/providers/core_providers.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/calendario_examen.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/app_colors.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/background_pattern_painter.dart';
import 'package:gestion_ets_escom/features/user/presentation/providers/calendar_state_provider.dart';
import 'package:gestion_ets_escom/features/user/presentation/providers/calendario_providers.dart';
import 'package:gestion_ets_escom/features/user/presentation/widgets/calendar_exam_card_compact.dart';
import 'package:gestion_ets_escom/features/user/presentation/widgets/calendar_view_toggle.dart';
import 'package:gestion_ets_escom/features/user/presentation/widgets/custom_calendar_grid.dart';
import 'package:intl/intl.dart';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  // ── Helpers ──────────────────────────────────────────────────────────────

  Color _colorFromHex(String hex) {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  Map<DateTime, List<Color>> _buildEventsMap(List<CalendarioExamen> examenes) {
    final map = <DateTime, List<Color>>{};
    for (final ce in examenes) {
      final key = DateTime.utc(
        ce.examen.fecha.year,
        ce.examen.fecha.month,
        ce.examen.fecha.day,
      );
      final color = _colorFromHex(ce.color);
      map.putIfAbsent(key, () => []);
      // Max 3 dots per day, no duplicates.
      if (map[key]!.length < 3 && !map[key]!.contains(color)) {
        map[key]!.add(color);
      }
    }
    return map;
  }

  List<CalendarioExamen> _examenesForDay(
    List<CalendarioExamen> all,
    DateTime day,
  ) {
    final target = DateTime(day.year, day.month, day.day);
    return all.where((ce) {
      final d = DateTime(
        ce.examen.fecha.year,
        ce.examen.fecha.month,
        ce.examen.fecha.day,
      );
      return d == target;
    }).toList();
  }

  int _diasRestantes(DateTime fecha) {
    final today = DateTime.now();
    final examDay = DateTime(fecha.year, fecha.month, fecha.day);
    final todayDay = DateTime(today.year, today.month, today.day);
    return examDay.difference(todayDay).inDays;
  }

  Future<void> _confirmRemove(String examenId) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Icon(Icons.calendar_month_outlined,
                color: Color(0xFFC62828), size: 36),
            const SizedBox(height: 12),
            const Text(
              '¿Eliminar este examen del calendario?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primaryDarkBlue),
                      foregroundColor: AppColors.primaryDarkBlue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFC62828),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Eliminar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (confirmed != true || !mounted) return;

    final result =
        await ref.read(removeFromCalendarioProvider).call(examenId);
    if (!mounted) return;
    result.fold(
      (_) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo eliminar. Intenta de nuevo')),
      ),
      (_) {
        ref.invalidate(calendarioPageProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Examen eliminado del calendario')),
        );
      },
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final calState = ref.watch(calendarStateProvider);
    final calendarioAsync = ref.watch(calendarioPageProvider);
    final topOffset = MediaQuery.of(context).padding.top + 10;

    final examenes = calendarioAsync.value ?? [];
    final eventsMap = _buildEventsMap(examenes);

    final isListView = calState.activeView == CalendarAppView.list;
    final isMonthView = calState.activeView == CalendarAppView.month;

    final dayExamenes = isListView
        ? examenes
        : _examenesForDay(examenes, calState.selectedDay);

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
              child: Column(
                children: [
                  // ── View toggle ──────────────────────────────────
                  const Padding(
                    padding: EdgeInsets.only(
                        top: 16, left: 16, right: 16, bottom: 8),
                    child: CalendarViewToggle(),
                  ),

                  // ── Calendar grid (hidden in list view) ──────────
                  if (!isListView)
                    CustomCalendarGrid(eventsMarkers: eventsMap),

                  if (!isListView)
                    const Divider(color: Color(0xFFEEEEEE), thickness: 1),

                  // ── Date / count label ───────────────────────────
                  if (!isListView)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      child: Row(
                        children: [
                          Text(
                            DateFormat("d 'de' MMMM", 'es_ES')
                                .format(calState.selectedDay),
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${dayExamenes.length} examen(s)',
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // ── Exam cards ───────────────────────────────────
                  Expanded(
                    child: calendarioAsync.when(
                      loading: () => const Center(
                          child: CircularProgressIndicator()),
                      error: (e, _) => Center(
                        child: Text('Error: $e',
                            style:
                                TextStyle(color: Colors.grey.shade500)),
                      ),
                      data: (_) {
                        if (dayExamenes.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.event_available_outlined,
                                    size: 48,
                                    color: Colors.grey.shade300),
                                const SizedBox(height: 8),
                                Text(
                                  'Sin exámenes guardados',
                                  style: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 14),
                                ),
                              ],
                            ),
                          );
                        }

                        if (isMonthView) {
                          return GridView.count(
                            crossAxisCount: 2,
                            childAspectRatio: 2.4,
                            padding: EdgeInsets.zero,
                            children: dayExamenes
                                .map(
                                  (ce) => CalendarExamCardCompact(
                                    fecha: ce.examen.fecha,
                                    materia: ce.examen.materia.nombre,
                                    salon: ce.examen.salon
                                            .etiquetaSalon ??
                                        '',
                                    hora: ce.examen.hora,
                                    colorClave: _colorFromHex(ce.color),
                                    onRemove: () =>
                                        _confirmRemove(ce.examen.id),
                                  ),
                                )
                                .toList(),
                          );
                        }

                        return ListView(
                          padding: EdgeInsets.zero,
                          children: dayExamenes
                              .map(
                                (ce) => _CalendarioListCard(
                                  ce: ce,
                                  diasRestantes:
                                      _diasRestantes(ce.examen.fecha),
                                  colorClave:
                                      _colorFromHex(ce.color),
                                  onRemove: () =>
                                      _confirmRemove(ce.examen.id),
                                ),
                              )
                              .toList(),
                        );
                      },
                    ),
                  ),

                  // ── Legend ───────────────────────────────────────
                  const Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ColorLegendItem(
                            color: Color(0xFF3C8041), label: 'Básica'),
                        ColorLegendItem(
                            color: Color(0xFFE18301),
                            label: 'Profesional'),
                        ColorLegendItem(
                            color: Color(0xFFBA361B),
                            label: 'Terminal'),
                        ColorLegendItem(
                            color: Color(0xFF1680D1),
                            label: 'Institucional'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Card for week/list view ───────────────────────────────────────────────────

class _CalendarioListCard extends StatelessWidget {
  const _CalendarioListCard({
    required this.ce,
    required this.diasRestantes,
    required this.colorClave,
    required this.onRemove,
  });

  final CalendarioExamen ce;
  final int diasRestantes;
  final Color colorClave;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final chipColor =
        diasRestantes <= 7 ? const Color(0xFFF9A825) : const Color(0xFF4CAF50);
    final chipLabel =
        diasRestantes < 0 ? 'Pasado' : '$diasRestantes días';

    return GestureDetector(
      onLongPress: onRemove,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              // Colored date box
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: colorClave,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('dd').format(ce.examen.fecha),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      DateFormat('MMM').format(ce.examen.fecha),
                      style:
                          const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Text info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ce.examen.materia.nombre,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${ce.examen.materia.carrera.abreviatura} · '
                      '${ce.examen.salon.etiquetaSalon ?? ''} · '
                      '${ce.examen.hora}',
                      style: TextStyle(
                          color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ],
                ),
              ),
              // Days chip
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: chipColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  chipLabel,
                  style: TextStyle(
                    color: chipColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onRemove,
                icon: Icon(Icons.delete_outline,
                    color: Colors.grey.shade400, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                splashRadius: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Legend item ───────────────────────────────────────────────────────────────

class ColorLegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const ColorLegendItem({super.key, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}
