import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_ets_escom/core/providers/core_providers.dart';
import 'package:gestion_ets_escom/core/utils/date_formatter.dart';
import 'package:gestion_ets_escom/features/admin/domain/entities/examen_create_params.dart';
import 'package:gestion_ets_escom/features/admin/domain/entities/examen_update_params.dart';
import 'package:gestion_ets_escom/features/admin/presentation/providers/admin_filter_providers.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/turno.dart';
import 'package:gestion_ets_escom/features/admin/presentation/providers/admin_salon_providers.dart';
import 'package:file_selector/file_selector.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/app_colors.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/app_text_styles.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/app_search_bar.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/background_pattern_painter.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/filter_card.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/examen.dart';
import 'package:gestion_ets_escom/features/shared/presentation/pages/individual_materia_view.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/card_materia_expanded.dart';
import 'package:gestion_ets_escom/features/user/presentation/providers/carrera_providers.dart';

Color? _colorFromHex(String? hex) {
  if (hex == null) return null;
  final h = hex.replaceAll('#', '').trim();
  if (h.length != 6) return null;
  return Color(int.parse('FF$h', radix: 16));
}

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.primaryDarkBlue,
        body: Stack(
          children: [
            CustomPaint(
              size: Size.infinite,
              painter: BackgroundPatternPainter(),
            ),
            SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Header ──────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 8, 20),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Dashboard',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Gestiona los exámenes del semestre',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.white),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  // ─── Panel blanco ─────────────────────────────────────────
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppColors.backgroundWhite,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        children: [
                          const TabBar(
                            labelColor: AppColors.primaryDarkBlue,
                            unselectedLabelColor: Colors.grey,
                            indicatorColor: AppColors.primaryDarkBlue,
                            indicatorWeight: 3,
                            tabs: [
                              Tab(text: 'Estadísticas'),
                              Tab(text: 'Gestionar'),
                            ],
                          ),
                          const Expanded(
                            child: TabBarView(
                              children: [_EstadisticasTab(), _GestionarTab()],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =======================================================================
// PESTAÑA 1: ESTADÍSTICAS
// =======================================================================
class _EstadisticasTab extends ConsumerWidget {
  const _EstadisticasTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider);

    return statsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primaryDarkBlue),
      ),
      error: (_, __) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'No se pudieron cargar las estadísticas',
              style: AppTextStyles.bodySecondary,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => ref.invalidate(statsProvider),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
      data: (stats) {
        final maxArea = stats.porArea.isEmpty
            ? 1
            : stats.porArea.map((a) => a.total).reduce(max);
        final maxCarrera = stats.porCarrera.isEmpty
            ? 1
            : stats.porCarrera.map((c) => c.total).reduce(max);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      label: 'Total de exámenes',
                      value: stats.totalExamenes,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SummaryCard(
                      label: 'Carreras activas',
                      value: stats.totalCarreras,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SummaryCard(
                      label: 'Áreas de formación',
                      value: stats.totalAreas,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                'Por área de formación',
                style: AppTextStyles.sectionTitle,
              ),
              const SizedBox(height: 16),
              if (stats.porArea.isEmpty)
                Text('Sin datos', style: AppTextStyles.bodySecondary)
              else
                ...stats.porArea.map(
                  (area) => _StatBar(
                    label: area.nombre,
                    count: area.total,
                    maxCount: maxArea,
                    color:
                        _colorFromHex(area.color) ?? AppColors.primaryDarkBlue,
                  ),
                ),
              const SizedBox(height: 32),
              const Text('Por carrera', style: AppTextStyles.sectionTitle),
              const SizedBox(height: 16),
              if (stats.porCarrera.isEmpty)
                Text('Sin datos', style: AppTextStyles.bodySecondary)
              else
                ...stats.porCarrera.indexed.map((entry) {
                  final (index, carrera) = entry;
                  final opacity = (1.0 - index * 0.15).clamp(0.1, 1.0);
                  return _StatBar(
                    label: carrera.abreviatura,
                    count: carrera.total,
                    maxCount: maxCarrera,
                    color: AppColors.primaryDarkBlue.withValues(alpha: opacity),
                  );
                }),
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final int value;

  const _SummaryCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDarkBlue,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

// =======================================================================
// PESTAÑA 2: GESTIONAR
// =======================================================================
class _GestionarTab extends ConsumerStatefulWidget {
  const _GestionarTab();

  @override
  ConsumerState<_GestionarTab> createState() => _GestionarTabState();
}

class _GestionarTabState extends ConsumerState<_GestionarTab> {
  final _searchController = TextEditingController();
  Timer? _searchDebounce;
  bool _showInactivos = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      final text = _searchController.text;
      final n = ref.read(adminFilterSearchbarProvider.notifier);
      text.isEmpty ? n.clear() : n.select(text);
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasActiveFilters =>
      ref.watch(adminFilterCarreraProvider).isNotEmpty ||
      ref.watch(adminFilterSemestresProvider).isNotEmpty ||
      ref.watch(adminFilterAreaProvider).isNotEmpty ||
      ref.watch(adminFilterTurnoProvider) != null ||
      ref.watch(adminFilterFechaProvider) != null ||
      ref.watch(adminFilterSalonProvider) != null ||
      ref.watch(adminFilterSearchbarProvider) != null;

  void _clearAllFilters() {
    _searchController.clear();
    ref.invalidate(adminFilterCarreraProvider);
    ref.invalidate(adminFilterSemestresProvider);
    ref.invalidate(adminFilterAreaProvider);
    ref.invalidate(adminFilterTurnoProvider);
    ref.invalidate(adminFilterFechaProvider);
    ref.invalidate(adminFilterSalonProvider);
    ref.invalidate(adminFilterSearchbarProvider);
  }

  @override
  Widget build(BuildContext context) {
    final examenesAsync = ref.watch(adminExamenesFilteredProvider);
    debugPrint("examenes: ${examenesAsync}");
    final carreras = ref.watch(carrerasProvider).value ?? [];
    final areas = ref.watch(adminAreasFormacionProvider).value ?? [];

    final filterCarrera = ref.watch(adminFilterCarreraProvider);
    final filterSemestres = ref.watch(adminFilterSemestresProvider);
    final filterArea = ref.watch(adminFilterAreaProvider);
    final filterTurno = ref.watch(adminFilterTurnoProvider);
    final filterFecha = ref.watch(adminFilterFechaProvider);
    final filterSalon = ref.watch(adminFilterSalonProvider);

    final selectedCarreras = filterCarrera.isEmpty ? {'Todas'} : filterCarrera;
    final selectedSemestres = filterSemestres.isEmpty
        ? {'Todos'}
        : filterSemestres.map((s) => s.toString()).toSet();
    final selectedArea = filterArea.isEmpty ? {'Todas'} : filterArea;
    final selectedTurno = filterTurno ?? 'Todos';

    // ── chip builders ────────────────────────────────────────────────────
    List<({String id, String label})> buildCarreraChips() {
      final abbrevCount = <String, int>{};
      for (final c in carreras) {
        abbrevCount[c.abreviatura] = (abbrevCount[c.abreviatura] ?? 0) + 1;
      }
      return [
        (id: 'Todas', label: 'Todas'),
        for (final c in carreras)
          (
            id: c.id,
            label: (abbrevCount[c.abreviatura] ?? 1) > 1
                ? '${c.abreviatura} ${c.plan}'
                : c.abreviatura,
          ),
      ];
    }

    List<({String id, String label})> buildAreaChips() => [
      (id: 'Todas', label: 'Todas'),
      for (final af in areas) (id: af.id, label: af.nombre),
    ];

    final carreraChips = buildCarreraChips();
    final areaChips = buildAreaChips();

    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: AppSearchBar(
                controller: _searchController,
                hint: 'Buscar materia...',
                onFilterTap: () => FilterCard.show(
                  context,
                  carreraOptions: carreras,
                  areaFormacionOptions: areas,
                  selectedCarreras: selectedCarreras,
                  selectedSemestres: selectedSemestres,
                  selectedArea: selectedArea,
                  selectedTurno: selectedTurno,
                  selectedFecha: filterFecha,
                  selectedSalon: filterSalon,
                  onCarrerasChanged: (set) {
                    final n = ref.read(adminFilterCarreraProvider.notifier);
                    n.clear();
                    if (!set.contains('Todas')) {
                      for (final id in set) { n.add(id); }
                    }
                  },
                  onSemestresChanged: (set) {
                    final n = ref.read(adminFilterSemestresProvider.notifier);
                    n.clear();
                    for (final s in set) {
                      final i = int.tryParse(s);
                      if (i != null) n.add(i);
                    }
                  },
                  onAreaChanged: (set) {
                    final n = ref.read(adminFilterAreaProvider.notifier);
                    n.clear();
                    if (!set.contains('Todas')) {
                      for (final id in set) { n.add(id); }
                    }
                  },
                  onTurnoChanged: (v) {
                    final n = ref.read(adminFilterTurnoProvider.notifier);
                    v == 'Todos' ? n.clear() : n.select(v);
                  },
                  onFechaChanged: (d) {
                    final n = ref.read(adminFilterFechaProvider.notifier);
                    d == null ? n.clear() : n.select(d);
                  },
                  onSalonChanged: (s) {
                    final n = ref.read(adminFilterSalonProvider.notifier);
                    s == null ? n.clear() : n.select(s);
                  },
                  onApply: () {},
                ),
              ),
            ),
            if (_hasActiveFilters && !_showInactivos)
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16, top: 4),
                  child: TextButton(
                    onPressed: _clearAllFilters,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primaryDarkBlue,
                      textStyle: const TextStyle(fontSize: 13),
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text('Limpiar filtros'),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  _ToggleChip(
                    label: 'Activos',
                    selected: !_showInactivos,
                    onTap: () => setState(() => _showInactivos = false),
                  ),
                  const SizedBox(width: 8),
                  _ToggleChip(
                    label: 'Inactivos',
                    selected: _showInactivos,
                    onTap: () => setState(() => _showInactivos = true),
                  ),
                ],
              ),
            ),
            if (_showInactivos)
              Expanded(
                child: ref.watch(adminExamenesInactivosProvider).when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => const Center(child: Text('Error al cargar inactivos')),
                  data: (inactivos) => inactivos.isEmpty
                      ? const Center(child: Text('No hay exámenes inactivos', style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          padding: const EdgeInsets.only(top: 12, bottom: 80),
                          itemCount: inactivos.length,
                          itemBuilder: (_, i) {
                            final ex = inactivos[i];
                            final fecha = DateFormatter.formatDate(ex.fecha);
                            return _InactivoExamenCard(
                              examen: ex,
                              fecha: fecha,
                            );
                          },
                        ),
                ),
              )
            else
              Expanded(
              child: examenesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) =>
                    const Center(child: Text('Error al cargar exámenes')),
                data: (examenes) => examenes.isEmpty
                    ? const Center(
                        child: Text(
                          'Sin resultados',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Gestión de Exámenes',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${examenes.length} exámenes encontrados',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            ),
                          ),
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => _ExamListCardAdmin(
                                examen: examenes[index],
                                carreraChips: carreraChips,
                                areaChips: areaChips,
                              ),
                              childCount: examenes.length,
                            ),
                          ),
                          const SliverToBoxAdapter(child: SizedBox(height: 80)),
                        ],
                      ),
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            backgroundColor: AppColors.primaryDarkBlue,
            foregroundColor: Colors.white,
            shape: const CircleBorder(),
            onPressed: () => showDialog(
              context: context,
              barrierDismissible: true,
              builder: (context) => const _AddExamModal(),
            ),
            child: const Icon(Icons.add, size: 28),
          ),
        ),
      ],
    );
  }
}

// =======================================================================
// WIDGETS REUTILIZABLES
// =======================================================================
class _StatBar extends StatelessWidget {
  final String label;
  final int count;
  final int maxCount;
  final Color color;

  const _StatBar({
    required this.label,
    required this.count,
    required this.maxCount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final double percentage = count / maxCount;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[700], fontSize: 13),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: percentage.clamp(0.0, 1.0),
                  child: Container(
                    height: 16,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              count.toString(),
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

// =======================================================================
// CHIP DE TOGGLE ACTIVOS/INACTIVOS
// =======================================================================
class _ToggleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryDarkBlue : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primaryDarkBlue : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
    );
  }
}

// =======================================================================
// TARJETA DE EXAMEN INACTIVO CON BOTÓN REACTIVAR
// =======================================================================
class _InactivoExamenCard extends ConsumerWidget {
  final Examen examen;
  final String fecha;

  const _InactivoExamenCard({required this.examen, required this.fecha});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 6,
              decoration: BoxDecoration(
                color: Colors.orange[300],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.orange[50],
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Inactivo',
                                  style: TextStyle(fontSize: 11, color: Colors.orange[700], fontWeight: FontWeight.w600),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  examen.materia.nombre,
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${examen.profesor.nombreCompleto} • $fecha',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        try {
                          await ref.read(adminRemoteDatasourceProvider).reactivarExamen(examen.id);
                          if (!context.mounted) return;
                          ref.invalidate(adminExamenesInactivosProvider);
                          ref.invalidate(adminExamenesProvider);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Examen reactivado'), backgroundColor: Colors.green),
                          );
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                          );
                        }
                      },
                      child: const Text('Reactivar'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoIconText extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoIconText({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
      ],
    );
  }
}

// =======================================================================
// TARJETA ADMINISTRATIVA DE EXAMEN
// =======================================================================
class _ExamListCardAdmin extends StatelessWidget {
  final Examen examen;
  final List<({String id, String label})> carreraChips;
  final List<({String id, String label})> areaChips;

  const _ExamListCardAdmin({
    required this.examen,
    required this.carreraChips,
    required this.areaChips,
  });

  EtsStatus get _status {
    final examDay = DateTime(
      examen.fecha.year,
      examen.fecha.month,
      examen.fecha.day,
    );
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diff = examDay.difference(today).inDays;
    if (diff == 0) return EtsStatus.today;
    if (diff == 1) return EtsStatus.tomorrow;
    if (diff <= 7) return EtsStatus.soon;
    return EtsStatus.far;
  }

  Color get _barColor {
    final parsed = _colorFromHex(examen.materia.areaFormacion?.color);
    if (parsed != null) return parsed;
    return switch (_status) {
      EtsStatus.today => AppColors.statusTodayForeground,
      EtsStatus.tomorrow => AppColors.statusTomorrowForeground,
      EtsStatus.soon => AppColors.statusSoonForeground,
      EtsStatus.far => AppColors.statusFarForeground,
    };
  }

  MateriaData _buildMateriaData() => MateriaData(
    id: examen.id,
    nombre: examen.materia.nombre,
    profesor: examen.profesor.nombreCompleto,
    emailProfesor: examen.profesor.correo,
    semestre: examen.materia.semestre,
    salon: examen.salon.etiquetaSalon ?? '',
    fecha: DateFormatter.formatDate(examen.fecha),
    rawFecha: examen.fecha,
    hora: examen.hora,
    turno: examen.turno.name[0].toUpperCase() + examen.turno.name.substring(1),
    status: _status,
    barColor: _barColor,
    areaFormacionColor: examen.materia.areaFormacion?.color,
    guia: examen.documentoGuia,
    proyecto: examen.documentoProyecto,
    notas: examen.notas,
  );

  @override
  Widget build(BuildContext context) {
    final materia = examen.materia.nombre;
    final profe = examen.profesor.nombreCompleto;
    final fecha = DateFormatter.formatDate(examen.fecha);
    final hora = examen.hora;
    final salon = examen.salon.etiquetaSalon ?? '';
    final semestre = 'Semestre ${examen.materia.semestre}';
    final barColor = _barColor;
    final turno =
        examen.turno.name[0].toUpperCase() + examen.turno.name.substring(1);

    return GestureDetector(
      onTap: () {
        final data = _buildMateriaData();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => IndividualMateriaView(
              data: data,
              bottomBar: _AdminDetailActions(
                data: data,
                examen: examen,
                carreraChips: carreraChips,
                areaChips: areaChips,
              ),
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, left: 20, right: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 6,
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  materia,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange[50],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Próximamente',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange[800],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            profe,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 16,
                            runSpacing: 8,
                            children: [
                              _InfoIconText(
                                icon: Icons.calendar_today_outlined,
                                text: fecha,
                              ),
                              _InfoIconText(
                                icon: Icons.access_time,
                                text: hora,
                              ),
                              _InfoIconText(
                                icon: Icons.meeting_room_outlined,
                                text: salon,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _InfoIconText(
                            icon: Icons.school_outlined,
                            text: semestre,
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: Colors.grey[200]),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () => showDialog(
                              context: context,
                              barrierDismissible: true,
                              builder: (_) => _EditExamModal(
                                examen: examen,
                                carreraChips: carreraChips,
                                areaChips: areaChips,
                              ),
                            ),
                            icon: Icon(
                              Icons.edit_outlined,
                              size: 18,
                              color: Colors.blue[700],
                            ),
                            label: Text(
                              'Editar',
                              style: TextStyle(color: Colors.blue[700]),
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton.icon(
                            onPressed: () => showDialog(
                              context: context,
                              barrierDismissible: true,
                              builder: (_) => _DeleteExamModal(
                                examId: examen.id,
                                materia: materia,
                                profe: profe,
                                fecha: fecha,
                              ),
                            ),
                            icon: Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: Colors.red[600],
                            ),
                            label: Text(
                              'Eliminar',
                              style: TextStyle(color: Colors.red[600]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =======================================================================
// BARRA DE ACCIONES DEL ADMIN EN LA VISTA DE DETALLE
// =======================================================================
class _AdminDetailActions extends StatelessWidget {
  const _AdminDetailActions({
    required this.data,
    required this.examen,
    required this.carreraChips,
    required this.areaChips,
  });

  final MateriaData data;
  final Examen examen;
  final List<({String id, String label})> carreraChips;
  final List<({String id, String label})> areaChips;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final turno =
        examen.turno.name[0].toUpperCase() + examen.turno.name.substring(1);

    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red[600],
                side: BorderSide(color: Colors.red[300]!),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => showDialog(
                context: context,
                barrierDismissible: true,
                builder: (_) => _DeleteExamModal(
                  examId: examen.id,
                  materia: data.nombre,
                  profe: data.profesor,
                  fecha: data.fecha,
                ),
              ),
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('Eliminar', style: TextStyle(fontSize: 13)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryDarkBlue,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => showDialog(
                context: context,
                barrierDismissible: true,
                builder: (_) => _EditExamModal(
                  examen: examen,
                  carreraChips: carreraChips,
                  areaChips: areaChips,
                ),
              ),
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Editar', style: TextStyle(fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }
}

// =======================================================================
// MODAL DE EDICIÓN
// =======================================================================
class _EditExamModal extends ConsumerStatefulWidget {
  final Examen examen;
  final List<({String id, String label})> carreraChips;
  final List<({String id, String label})> areaChips;

  const _EditExamModal({
    required this.examen,
    required this.carreraChips,
    required this.areaChips,
  });

  @override
  ConsumerState<_EditExamModal> createState() => _EditExamModalState();
}

class _EditExamModalState extends ConsumerState<_EditExamModal> {
  late TextEditingController _horaCtrl;
  late TextEditingController _notasCtrl;

  late String _selectedCarreraId;
  String? _selectedAreaId;
  late String _selectedSalonId;
  late DateTime _selectedFecha;
  String? _selectedProfesorId;

  ({String name, Uint8List bytes})? _pendingGuia;
  ({String name, Uint8List bytes})? _pendingProyecto;
  String? _guiaFileName;
  String? _proyectoFileName;

  bool _isSaving = false;
  String? _saveError;

  @override
  void initState() {
    super.initState();
    final e = widget.examen;
    _horaCtrl = TextEditingController(text: e.hora);
    _notasCtrl = TextEditingController(text: e.notas ?? '');
    _selectedCarreraId = e.materia.carrera.id;
    _selectedAreaId = e.materia.areaFormacion?.id;
    _selectedSalonId = e.salon.id;
    _selectedFecha = e.fecha;
    _selectedProfesorId = e.profesor.id;
    _guiaFileName = e.documentoGuia;
    _proyectoFileName = e.documentoProyecto;
  }

  @override
  void dispose() {
    _horaCtrl.dispose();
    _notasCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardarCambios() async {
    setState(() {
      _isSaving = true;
      _saveError = null;
    });

    if (_pendingGuia != null) {
      final result = await ref
          .read(adminRepositoryProvider)
          .uploadExamenFile(_pendingGuia!.name, _pendingGuia!.bytes);
      if (!mounted) return;
      if (result.isLeft()) {
        setState(() {
          _isSaving = false;
          _saveError = 'Error al subir la guía de estudio';
        });
        return;
      }
      _guiaFileName = _pendingGuia!.name;
    }

    if (_pendingProyecto != null) {
      final result = await ref
          .read(adminRepositoryProvider)
          .uploadExamenFile(_pendingProyecto!.name, _pendingProyecto!.bytes);
      if (!mounted) return;
      if (result.isLeft()) {
        setState(() {
          _isSaving = false;
          _saveError = 'Error al subir el proyecto';
        });
        return;
      }
      _proyectoFileName = _pendingProyecto!.name;
    }

    final params = ExamenUpdateParams(
      examenId: widget.examen.id,
      materiaId: widget.examen.materia.id,
      carreraId: _selectedCarreraId,
      areaFormacionId: _selectedAreaId,
      profesorId: _selectedProfesorId ?? widget.examen.profesor.id,
      salonId: _selectedSalonId,
      fecha: _selectedFecha,
      hora: _horaCtrl.text.trim(),
      documentoGuia: _guiaFileName,
      documentoProyecto: _proyectoFileName,
      notas: _notasCtrl.text.trim().isEmpty ? null : _notasCtrl.text.trim(),
    );

    final result = await ref.read(updateExamenCompletoProvider).call(params);
    if (!mounted) return;

    result.fold(
      (failure) => setState(() {
        _isSaving = false;
        _saveError = failure.message;
      }),
      (_) {
        ref.invalidate(adminExamenesProvider);
        Navigator.pop(context);
      },
    );
  }

  InputDecoration _inputDeco({String? hint, IconData? icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
      filled: true,
      fillColor: const Color(0xFFF8F9FA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF00338D), width: 1.5),
      ),
      prefixIcon: icon != null
          ? Icon(
              icon,
              size: 20,
              color: const Color(0xFF00338D).withValues(alpha: 0.6),
            )
          : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF00338D)),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Color(0xFF00338D),
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _labeled(String label, Widget field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        field,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final salonesAsync = ref.watch(adminSalonesActivosCatalogProvider);
    final examen = widget.examen;
    final barColor =
        _colorFromHex(examen.materia.areaFormacion?.color) ??
        AppColors.primaryDarkBlue;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00338D).withValues(alpha: 0.15),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── HEADER ────────────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue[50]?.withValues(alpha: 0.4),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                  border: Border(bottom: BorderSide(color: Colors.blue[100]!)),
                ),
                padding: const EdgeInsets.fromLTRB(24, 24, 16, 24),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 46,
                      decoration: BoxDecoration(
                        color: barColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            examen.materia.nombre,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Editando detalles del ETS',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.grey,
                          size: 20,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),

              // ── BODY ──────────────────────────────────────────────
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle(
                        'Clasificación Académica',
                        Icons.category_outlined,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _labeled(
                              'Carrera',
                              DropdownButtonFormField<String>(
                                value:
                                    widget.carreraChips.any(
                                      (c) => c.id == _selectedCarreraId,
                                    )
                                    ? _selectedCarreraId
                                    : widget.carreraChips.first.id,
                                isExpanded: true,
                                icon: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Colors.grey[500],
                                ),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: _inputDeco(
                                  icon: Icons.school_outlined,
                                ),
                                items: widget.carreraChips
                                    .map(
                                      (c) => DropdownMenuItem(
                                        value: c.id,
                                        child: Text(
                                          c.label,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) {
                                  if (val != null)
                                    setState(() => _selectedCarreraId = val);
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _labeled(
                              'Turno',
                              TextFormField(
                                initialValue: examen.turno.value,
                                readOnly: true,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: _inputDeco(
                                  icon: Icons.wb_sunny_outlined,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _labeled(
                        'Área de Formación',
                        DropdownButtonFormField<String?>(
                          value:
                              widget.areaChips.any(
                                (a) => a.id == _selectedAreaId,
                              )
                              ? _selectedAreaId
                              : null,
                          isExpanded: true,
                          icon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Colors.grey[500],
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: _inputDeco(
                            icon: Icons.account_tree_outlined,
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('Sin área'),
                            ),
                            ...widget.areaChips.map(
                              (a) => DropdownMenuItem(
                                value: a.id,
                                child: Text(
                                  a.label,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                          onChanged: (val) =>
                              setState(() => _selectedAreaId = val),
                        ),
                      ),
                      const SizedBox(height: 32),
                      _sectionTitle(
                        'Programación y Espacio',
                        Icons.event_available_outlined,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _labeled(
                              'Fecha',
                              GestureDetector(
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: _selectedFecha,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2030),
                                  );
                                  if (picked != null) {
                                    setState(() => _selectedFecha = picked);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8F9FA),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.grey[200]!,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today_rounded,
                                        size: 20,
                                        color: const Color(
                                          0xFF00338D,
                                        ).withValues(alpha: 0.6),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        DateFormatter.formatDate(
                                          _selectedFecha,
                                        ),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _labeled(
                              'Horario',
                              TextFormField(
                                controller: _horaCtrl,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: _inputDeco(
                                  icon: Icons.access_time_rounded,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _labeled(
                        'Salón / Laboratorio',
                        salonesAsync.when(
                          loading: () => const SizedBox(
                            height: 56,
                            child: Center(child: LinearProgressIndicator()),
                          ),
                          error: (e, _) => Text(
                            'Error cargando salones',
                            style: TextStyle(color: Colors.red[600]),
                          ),
                          data: (salones) {
                            final validId =
                                salones.any(
                                  (s) => s['id'].toString() == _selectedSalonId,
                                )
                                ? _selectedSalonId
                                : salones.isNotEmpty
                                ? salones.first['id'].toString()
                                : _selectedSalonId;
                            return DropdownButtonFormField<String>(
                              value: validId,
                              isExpanded: true,
                              icon: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Colors.grey[500],
                              ),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: _inputDeco(
                                icon: Icons.meeting_room_outlined,
                              ),
                              items: salones
                                  .map(
                                    (s) => DropdownMenuItem(
                                      value: s['id'].toString(),
                                      child: Text(
                                        s['etiqueta_salon']?.toString() ??
                                            '${s['edificio']}-${s['numero_salon']}',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) {
                                if (val != null)
                                  setState(() => _selectedSalonId = val);
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 32),
                      _sectionTitle(
                        'Coordinador Evaluador',
                        Icons.badge_outlined,
                      ),
                      const SizedBox(height: 16),
                      _labeled(
                        'Profesor',
                        ref.watch(adminProfesoresActivosCatalogProvider).when(
                          loading: () => const SizedBox(
                            height: 56,
                            child: Center(child: LinearProgressIndicator()),
                          ),
                          error: (e, _) => Text(
                            'Error cargando profesores',
                            style: TextStyle(color: Colors.red[600]),
                          ),
                          data: (profesores) {
                            final validId = profesores.any(
                              (p) => p['id'].toString() == _selectedProfesorId,
                            )
                                ? _selectedProfesorId
                                : (profesores.isNotEmpty
                                    ? profesores.first['id'].toString()
                                    : null);
                            return DropdownButtonFormField<String>(
                              value: validId,
                              isExpanded: true,
                              icon: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Colors.grey[500],
                              ),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: _inputDeco(
                                icon: Icons.person_outline_rounded,
                              ),
                              items: profesores
                                  .map(
                                    (p) => DropdownMenuItem(
                                      value: p['id'].toString(),
                                      child: Text(
                                        '${p['nombre']} ${p['primer_apellido']}',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _selectedProfesorId = val);
                                }
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 32),
                      _sectionTitle(
                        'Recursos Adicionales',
                        Icons.folder_open_outlined,
                      ),
                      const SizedBox(height: 16),
                      _FileLink(
                        label: 'Proyecto (Opcional)',
                        fileName: _proyectoFileName,
                        onFileSelected: (name, bytes) => setState(() {
                          _pendingProyecto = (name: name, bytes: bytes);
                          _proyectoFileName = name;
                        }),
                      ),
                      const SizedBox(height: 16),
                      _FileLink(
                        label: 'Guía de Estudio (Opcional)',
                        fileName: _guiaFileName,
                        onFileSelected: (name, bytes) => setState(() {
                          _pendingGuia = (name: name, bytes: bytes);
                          _guiaFileName = name;
                        }),
                      ),
                      const SizedBox(height: 16),
                      _labeled(
                        'Nota para el alumno',
                        TextFormField(
                          controller: _notasCtrl,
                          maxLines: 3,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: _inputDeco(
                            hint: 'Instrucciones especiales para el examen...',
                          ),
                        ),
                      ),
                      if (_saveError != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red[600],
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _saveError!,
                                  style: TextStyle(
                                    color: Colors.red[700],
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // ── FOOTER ────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(28),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_circle_outline),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF00338D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    onPressed: _isSaving ? null : _guardarCambios,
                    label: Text(
                      _isSaving ? 'Guardando...' : 'Guardar Cambios',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =======================================================================
// MODAL DE CONFIRMACIÓN PARA ELIMINAR
// =======================================================================
class _DeleteExamModal extends ConsumerStatefulWidget {
  final String examId;
  final String materia;
  final String profe;
  final String fecha;

  const _DeleteExamModal({
    required this.examId,
    required this.materia,
    required this.profe,
    required this.fecha,
  });

  @override
  ConsumerState<_DeleteExamModal> createState() => _DeleteExamModalState();
}

class _DeleteExamModalState extends ConsumerState<_DeleteExamModal> {
  bool _isDeleting = false;

  Future<void> _confirmarEliminar() async {
    setState(() => _isDeleting = true);
    try {
      final result = await ref.read(adminRepositoryProvider).deleteExamen(widget.examId);
      if (!mounted) return;
      result.fold(
        (failure) {
          setState(() => _isDeleting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(failure.message), backgroundColor: Colors.red),
          );
        },
        (_) {
          ref.invalidate(adminExamenesProvider);
          ref.invalidate(adminExamenesInactivosProvider);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Examen desactivado'), backgroundColor: Colors.green),
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withValues(alpha: 0.15),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_sweep_rounded,
                  size: 36,
                  color: Colors.red[600],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '¿Desactivar examen?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1A1A1A),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'El examen pasará a la sección de inactivos y podrá reactivarse después.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        size: 20,
                        color: Colors.red[400],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.materia,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${widget.profe} • ${widget.fecha}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.grey[300]!, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _isDeleting ? null : () => Navigator.pop(context),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _isDeleting ? null : _confirmarEliminar,
                      child: _isDeleting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                            )
                          : const Text(
                              'Sí, desactivar',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =======================================================================
// MODAL PARA CREAR NUEVO ETS
// =======================================================================
class _AddExamModal extends ConsumerStatefulWidget {
  const _AddExamModal();

  @override
  ConsumerState<_AddExamModal> createState() => _AddExamModalState();
}

class _AddExamModalState extends ConsumerState<_AddExamModal> {
  final _horaCtrl = TextEditingController();
  final _notasCtrl = TextEditingController();

  String? _selectedMateriaId;
  String? _selectedSalonId;
  String? _selectedProfesorId;
  Turno _selectedTurno = Turno.matutino;
  DateTime _selectedFecha = DateTime.now();

  ({String name, Uint8List bytes})? _pendingGuia;
  ({String name, Uint8List bytes})? _pendingProyecto;
  String? _guiaFileName;
  String? _proyectoFileName;

  bool _isSaving = false;
  String? _saveError;

  @override
  void dispose() {
    _horaCtrl.dispose();
    _notasCtrl.dispose();
    super.dispose();
  }

  Future<void> _crearExamen() async {
    if (_selectedMateriaId == null || _selectedSalonId == null) {
      setState(() => _saveError = 'Selecciona una materia y un salón');
      return;
    }
    if (_selectedProfesorId == null || _horaCtrl.text.trim().isEmpty) {
      setState(() => _saveError = 'Selecciona un profesor y completa el horario');
      return;
    }

    setState(() {
      _isSaving = true;
      _saveError = null;
    });

    if (_pendingGuia != null) {
      final result = await ref
          .read(adminRepositoryProvider)
          .uploadExamenFile(_pendingGuia!.name, _pendingGuia!.bytes);
      if (!mounted) return;
      if (result.isLeft()) {
        setState(() {
          _isSaving = false;
          _saveError = 'Error al subir la guía de estudio';
        });
        return;
      }
      _guiaFileName = _pendingGuia!.name;
    }

    if (_pendingProyecto != null) {
      final result = await ref
          .read(adminRepositoryProvider)
          .uploadExamenFile(_pendingProyecto!.name, _pendingProyecto!.bytes);
      if (!mounted) return;
      if (result.isLeft()) {
        setState(() {
          _isSaving = false;
          _saveError = 'Error al subir el proyecto';
        });
        return;
      }
      _proyectoFileName = _pendingProyecto!.name;
    }

    final params = ExamenCreateParams(
      materiaId: _selectedMateriaId!,
      salonId: _selectedSalonId!,
      profesorId: _selectedProfesorId!,
      fecha: _selectedFecha,
      hora: _horaCtrl.text.trim(),
      turno: _selectedTurno,
      documentoGuia: _guiaFileName,
      documentoProyecto: _proyectoFileName,
      notas: _notasCtrl.text.trim().isEmpty ? null : _notasCtrl.text.trim(),
    );

    final result = await ref.read(createExamenCompletoProvider).call(params);
    if (!mounted) return;

    result.fold(
      (failure) => setState(() {
        _isSaving = false;
        _saveError = failure.message;
      }),
      (_) {
        ref.invalidate(adminExamenesProvider);
        Navigator.pop(context);
      },
    );
  }

  InputDecoration _inputDeco({String? hint, IconData? icon}) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF00338D), width: 1.5),
        ),
        prefixIcon: icon != null
            ? Icon(icon, size: 20,
                color: const Color(0xFF00338D).withValues(alpha: 0.6))
            : null,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      );

  Widget _sectionTitle(String title, IconData icon) => Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF00338D)),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF00338D),
              letterSpacing: 1.0,
            ),
          ),
        ],
      );

  Widget _labeled(String label, Widget field) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700])),
          const SizedBox(height: 8),
          field,
        ],
      );

  @override
  Widget build(BuildContext context) {
    final materiasAsync = ref.watch(adminMateriasActivasCatalogProvider);
    final salonesAsync = ref.watch(adminSalonesActivosCatalogProvider);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00338D).withValues(alpha: 0.15),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── HEADER ────────────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue[50]?.withValues(alpha: 0.4),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(28)),
                  border:
                      Border(bottom: BorderSide(color: Colors.blue[100]!)),
                ),
                padding: const EdgeInsets.fromLTRB(24, 24, 16, 24),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00338D),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Nuevo Examen ETS',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Completa la información para dar de alta',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.close_rounded,
                            color: Colors.grey, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),

              // ── BODY ──────────────────────────────────────────────
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle(
                          'Asignatura', Icons.menu_book_outlined),
                      const SizedBox(height: 16),
                      _labeled(
                        'Materia',
                        materiasAsync.when(
                          loading: () => const SizedBox(
                            height: 56,
                            child: Center(child: LinearProgressIndicator()),
                          ),
                          error: (e, _) => Text('Error cargando materias',
                              style: TextStyle(color: Colors.red[600])),
                          data: (materias) => DropdownButtonFormField<String>(
                            value: _selectedMateriaId,
                            isExpanded: true,
                            hint: const Text('Selecciona una materia'),
                            icon: Icon(Icons.keyboard_arrow_down_rounded,
                                color: Colors.grey[500]),
                            style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500),
                            decoration:
                                _inputDeco(icon: Icons.menu_book_outlined),
                            items: materias
                                .map((m) => DropdownMenuItem(
                                      value: m['id'].toString(),
                                      child: Text(
                                        '${m['nombre']} — ${(m['carrera'] as Map?)?['abreviatura'] ?? ''}',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ))
                                .toList(),
                            onChanged: (val) =>
                                setState(() => _selectedMateriaId = val),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _labeled(
                        'Turno',
                        DropdownButtonFormField<Turno>(
                          value: _selectedTurno,
                          isExpanded: true,
                          icon: Icon(Icons.keyboard_arrow_down_rounded,
                              color: Colors.grey[500]),
                          style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500),
                          decoration: _inputDeco(icon: Icons.wb_sunny_outlined),
                          items: Turno.values
                              .map((t) => DropdownMenuItem(
                                    value: t,
                                    child: Text(t.value),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedTurno = val);
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 32),
                      _sectionTitle(
                          'Programación y Espacio',
                          Icons.event_available_outlined),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _labeled(
                              'Fecha',
                              GestureDetector(
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: _selectedFecha,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2030),
                                  );
                                  if (picked != null) {
                                    setState(() => _selectedFecha = picked);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal:4, vertical: 16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8F9FA),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                        color: Colors.grey[200]!),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today_rounded,
                                        size: 20,
                                        color: const Color(0xFF00338D)
                                            .withValues(alpha: 0.6),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        DateFormatter.formatDate(
                                            _selectedFecha),
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _labeled(
                              'Horario',
                              TextFormField(
                                controller: _horaCtrl,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500),
                                decoration: _inputDeco(
                                    hint: 'Ej. 10:00:00',
                                    icon: Icons.access_time_rounded),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _labeled(
                        'Salón / Laboratorio',
                        salonesAsync.when(
                          loading: () => const SizedBox(
                            height: 56,
                            child: Center(child: LinearProgressIndicator()),
                          ),
                          error: (e, _) => Text('Error cargando salones',
                              style: TextStyle(color: Colors.red[600])),
                          data: (salones) => DropdownButtonFormField<String>(
                            value: _selectedSalonId,
                            isExpanded: true,
                            hint: const Text('Selecciona un salón'),
                            icon: Icon(Icons.keyboard_arrow_down_rounded,
                                color: Colors.grey[500]),
                            style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500),
                            decoration: _inputDeco(
                                icon: Icons.meeting_room_outlined),
                            items: salones
                                .map((s) => DropdownMenuItem(
                                      value: s['id'].toString(),
                                      child: Text(
                                        s['etiqueta_salon']?.toString() ??
                                            '${s['edificio']}-${s['numero_salon']}',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ))
                                .toList(),
                            onChanged: (val) =>
                                setState(() => _selectedSalonId = val),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      _sectionTitle(
                          'Coordinador Evaluador', Icons.badge_outlined),
                      const SizedBox(height: 16),
                      _labeled(
                        'Profesor',
                        ref.watch(adminProfesoresActivosCatalogProvider).when(
                          loading: () => const SizedBox(
                            height: 56,
                            child: Center(child: LinearProgressIndicator()),
                          ),
                          error: (e, _) => Text('Error cargando profesores',
                              style: TextStyle(color: Colors.red[600])),
                          data: (profesores) => DropdownButtonFormField<String>(
                            value: _selectedProfesorId,
                            isExpanded: true,
                            hint: const Text('Selecciona un profesor'),
                            icon: Icon(Icons.keyboard_arrow_down_rounded,
                                color: Colors.grey[500]),
                            style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500),
                            decoration: _inputDeco(
                                icon: Icons.person_outline_rounded),
                            items: profesores
                                .map((p) => DropdownMenuItem(
                                      value: p['id'].toString(),
                                      child: Text(
                                        '${p['nombre']} ${p['primer_apellido']}',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ))
                                .toList(),
                            onChanged: (val) =>
                                setState(() => _selectedProfesorId = val),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      _sectionTitle(
                          'Recursos Adicionales',
                          Icons.folder_open_outlined),
                      const SizedBox(height: 16),
                      _FileLink(
                        label: 'Proyecto (Opcional)',
                        fileName: _proyectoFileName,
                        onFileSelected: (name, bytes) => setState(() {
                          _pendingProyecto = (name: name, bytes: bytes);
                          _proyectoFileName = name;
                        }),
                      ),
                      const SizedBox(height: 16),
                      _FileLink(
                        label: 'Guía de Estudio (Opcional)',
                        fileName: _guiaFileName,
                        onFileSelected: (name, bytes) => setState(() {
                          _pendingGuia = (name: name, bytes: bytes);
                          _guiaFileName = name;
                        }),
                      ),
                      const SizedBox(height: 16),
                      _labeled(
                        'Nota para el alumno',
                        TextFormField(
                          controller: _notasCtrl,
                          maxLines: 3,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500),
                          decoration: _inputDeco(
                              hint:
                                  'Instrucciones especiales para el examen...'),
                        ),
                      ),
                      if (_saveError != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline,
                                  color: Colors.red[600], size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _saveError!,
                                  style: TextStyle(
                                      color: Colors.red[700], fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // ── FOOTER ────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(28)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5, color: Colors.white),
                          )
                        : const Icon(Icons.add_circle_outline_rounded),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF00338D),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    onPressed: _isSaving ? null : _crearExamen,
                    label: Text(
                      _isSaving ? 'Creando...' : 'Crear Examen',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =======================================================================
// WIDGET REUTILIZABLE: SUBIDA DE ARCHIVO A SUPABASE STORAGE
// =======================================================================
class _FileLink extends StatefulWidget {
  final String label;
  final String? fileName;
  final void Function(String name, Uint8List bytes) onFileSelected;

  const _FileLink({
    required this.label,
    required this.onFileSelected,
    this.fileName,
  });

  @override
  State<_FileLink> createState() => _FileLinkState();
}

class _FileLinkState extends State<_FileLink> {
  bool _isPicking = false;

  Future<void> _pickFile() async {
    const pdfType = XTypeGroup(label: 'PDF', extensions: ['pdf']);
    final file = await openFile(acceptedTypeGroups: [pdfType]);
    if (file == null) return;

    setState(() => _isPicking = true);
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    setState(() => _isPicking = false);
    widget.onFileSelected(file.name, bytes);
  }

  @override
  Widget build(BuildContext context) {
    final hasFile = widget.fileName != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: hasFile ? Colors.green[50] : const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasFile ? Colors.green[300]! : Colors.grey[200]!,
            ),
          ),
          child: Row(
            children: [
              Icon(
                hasFile
                    ? Icons.insert_drive_file_outlined
                    : Icons.upload_file_rounded,
                size: 20,
                color: hasFile
                    ? Colors.green[600]
                    : const Color(0xFF00338D).withValues(alpha: 0.6),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.fileName ?? 'Sin archivo',
                  style: TextStyle(
                    color: hasFile ? Colors.green[800] : Colors.grey[400],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _isPicking ? null : _pickFile,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00338D).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _isPicking
                      ? SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: const Color(
                              0xFF00338D,
                            ).withValues(alpha: 0.7),
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.upload_rounded,
                              size: 14,
                              color: const Color(
                                0xFF00338D,
                              ).withValues(alpha: 0.8),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Subir',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(
                                  0xFF00338D,
                                ).withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
