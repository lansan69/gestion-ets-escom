import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_ets_escom/core/providers/core_providers.dart';
import 'package:gestion_ets_escom/core/utils/date_formatter.dart';
import 'package:gestion_ets_escom/features/admin/presentation/providers/admin_filter_providers.dart';
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
      ref.watch(adminFilterCarreraProvider) != null ||
      ref.watch(adminFilterSemestresProvider).isNotEmpty ||
      ref.watch(adminFilterAreaProvider) != null ||
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
    final carreras = ref.watch(carrerasProvider).value ?? [];
    final areas = ref.watch(adminAreasFormacionProvider).value ?? [];

    final filterCarrera = ref.watch(adminFilterCarreraProvider);
    final filterSemestres = ref.watch(adminFilterSemestresProvider);
    final filterArea = ref.watch(adminFilterAreaProvider);
    final filterTurno = ref.watch(adminFilterTurnoProvider);
    final filterFecha = ref.watch(adminFilterFechaProvider);
    final filterSalon = ref.watch(adminFilterSalonProvider);

    final selectedCarreras = filterCarrera == null
        ? {'Todas'}
        : {filterCarrera};
    final selectedSemestres = filterSemestres.isEmpty
        ? {'Todos'}
        : filterSemestres.map((s) => s.toString()).toSet();
    final selectedArea = filterArea == null ? {'Todas'} : {filterArea};
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
                    (set.contains('Todas') || set.isEmpty)
                        ? n.clear()
                        : n.select(set.first);
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
                    (set.contains('Todas') || set.isEmpty)
                        ? n.clear()
                        : n.select(set.first);
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
            if (_hasActiveFilters)
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
                                carreraChips: carreraChips,
                                areaChips: areaChips,
                                carrera: examen.materia.carrera.id,
                                area: examen.materia.areaFormacion?.id ?? '',
                                colorBarra: barColor,
                                turno: turno,
                                materia: materia,
                                fecha: fecha,
                                hora: hora,
                                salon: salon,
                                profesor: profe,
                                correo: examen.profesor.correo ?? '',
                                notas: examen.notas ?? '',
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
                  carreraChips: carreraChips,
                  areaChips: areaChips,
                  carrera: examen.materia.carrera.id,
                  area: examen.materia.areaFormacion?.id ?? '',
                  colorBarra: data.barColor,
                  turno: turno,
                  materia: data.nombre,
                  fecha: data.fecha,
                  hora: data.hora,
                  salon: data.salon,
                  profesor: data.profesor,
                  correo: examen.profesor.correo ?? '',
                  notas: examen.notas ?? '',
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
class _EditExamModal extends StatelessWidget {
  final List<({String id, String label})> carreraChips;
  final List<({String id, String label})> areaChips;
  final String carrera;
  final String area;
  final Color colorBarra;
  final String turno;
  final String materia;
  final String fecha;
  final String hora;
  final String salon;
  final String profesor;
  final String correo;
  final String notas;

  const _EditExamModal({
    required this.carreraChips,
    required this.areaChips,
    required this.carrera,
    required this.area,
    required this.colorBarra,
    required this.turno,
    required this.materia,
    required this.fecha,
    required this.hora,
    required this.salon,
    required this.profesor,
    required this.correo,
    required this.notas,
  });

  InputDecoration _inputDecoration({String? hint, IconData? icon}) {
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

  Widget _buildSectionTitle(String title, IconData icon) {
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

  Widget _buildTextField(
    String label,
    String initialValue, {
    IconData? icon,
    int maxLines = 1,
    String? hint,
  }) {
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
        TextFormField(
          initialValue: initialValue,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          decoration: _inputDecoration(hint: hint, icon: icon),
        ),
      ],
    );
  }

  /// Dropdown para listas de records ({id, label}) — carrera y área.
  Widget _buildRecordDropdown(
    String label,
    String currentId,
    List<({String id, String label})> items,
    IconData icon,
  ) {
    final validId = items.any((e) => e.id == currentId)
        ? currentId
        : items.first.id;

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
        DropdownButtonFormField<String>(
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
          decoration: _inputDecoration(icon: icon),
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e.id,
                  child: Text(e.label, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: (val) {}, // TODO: conectar a provider
        ),
      ],
    );
  }

  /// Dropdown para listas simples de String — turno.
  Widget _buildStringDropdown(
    String label,
    String currentValue,
    List<String> items,
    IconData icon,
  ) {
    final validValue = items.contains(currentValue)
        ? currentValue
        : items.first;

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
        DropdownButtonFormField<String>(
          value: validValue,
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
          decoration: _inputDecoration(icon: icon),
          items: items
              .map(
                (v) => DropdownMenuItem(
                  value: v,
                  child: Text(v, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: (val) {}, // TODO: conectar a provider
        ),
      ],
    );
  }

  Widget _buildAutocomplete(
    String label,
    String initialValue,
    List<String> options,
  ) {
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
        Autocomplete<String>(
          initialValue: TextEditingValue(text: initialValue),
          optionsBuilder: (tv) {
            if (tv.text.isEmpty) return const Iterable<String>.empty();
            return options.where(
              (o) => o.toLowerCase().contains(tv.text.toLowerCase()),
            );
          },
          fieldViewBuilder: (context, controller, focusNode, onDone) =>
              TextFormField(
                controller: controller,
                focusNode: focusNode,
                onEditingComplete: onDone,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                decoration: _inputDecoration(
                  hint: 'Escribe para buscar...',
                  icon: Icons.meeting_room_outlined,
                ),
              ),
          optionsViewBuilder: (context, onSelected, options) => Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(16),
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                width: MediaQuery.of(context).size.width - 80,
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (_, i) {
                    final option = options.elementAt(i);
                    return ListTile(
                      leading: const Icon(
                        Icons.location_on_outlined,
                        size: 18,
                        color: Colors.grey,
                      ),
                      title: Text(
                        option,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () => onSelected(option),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilePicker(String label, String? fileName) {
    final hasFile = fileName != null;
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
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {}, // TODO: file_picker
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                  hasFile ? Icons.check_circle : Icons.upload_file_rounded,
                  size: 20,
                  color: hasFile
                      ? Colors.green[600]
                      : const Color(0xFF00338D).withValues(alpha: 0.6),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    fileName ?? 'Toca para explorar archivos...',
                    style: TextStyle(
                      color: hasFile ? Colors.green[800] : Colors.grey[500],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
                        color: colorBarra,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            materia,
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
                      _buildSectionTitle(
                        'Clasificación Académica',
                        Icons.category_outlined,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildRecordDropdown(
                              'Carrera',
                              carrera,
                              carreraChips,
                              Icons.school_outlined,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStringDropdown('Turno', turno, [
                              'Matutino',
                              'Vespertino',
                            ], Icons.wb_sunny_outlined),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildRecordDropdown(
                        'Área de Formación',
                        area,
                        areaChips,
                        Icons.account_tree_outlined,
                      ),
                      const SizedBox(height: 32),
                      _buildSectionTitle(
                        'Programación y Espacio',
                        Icons.event_available_outlined,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              'Fecha',
                              fecha,
                              icon: Icons.calendar_today_rounded,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              'Horario',
                              hora,
                              icon: Icons.access_time_rounded,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildAutocomplete('Salón / Laboratorio', salon, [
                        '1203',
                        '1204',
                        '2201',
                        '4003',
                        '4103',
                        'Laboratorio de Redes',
                      ]),
                      const SizedBox(height: 32),
                      _buildSectionTitle(
                        'Coordinador Evaluador',
                        Icons.badge_outlined,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        'Nombre completo',
                        profesor,
                        icon: Icons.person_outline_rounded,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        'Correo Institucional',
                        correo,
                        icon: Icons.alternate_email_rounded,
                      ),
                      const SizedBox(height: 32),
                      _buildSectionTitle(
                        'Recursos Adicionales',
                        Icons.folder_open_outlined,
                      ),
                      const SizedBox(height: 16),
                      _buildFilePicker('Proyecto (Opcional)', null),
                      const SizedBox(height: 16),
                      _buildFilePicker('Guía de Estudio (Opcional)', null),
                      const SizedBox(height: 16),
                      _buildTextField(
                        'Nota para el alumno',
                        notas,
                        maxLines: 3,
                        hint: 'Instrucciones especiales para el examen...',
                      ),
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
                    icon: const Icon(Icons.check_circle_outline),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF00338D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      // TODO: UPDATE en Supabase
                      Navigator.pop(context);
                    },
                    label: const Text(
                      'Guardar Cambios',
                      style: TextStyle(
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
class _DeleteExamModal extends StatelessWidget {
  final String materia;
  final String profe;
  final String fecha;

  const _DeleteExamModal({
    required this.materia,
    required this.profe,
    required this.fecha,
  });

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
                '¿Eliminar examen?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1A1A1A),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Esta acción es irreversible y los alumnos inscritos (si los hay) perderán su registro.',
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
                            materia,
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
                            '$profe • $fecha',
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
                      onPressed: () => Navigator.pop(context),
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
                      onPressed: () {
                        // TODO: DELETE en Supabase
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Sí, eliminar',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
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
class _AddExamModal extends StatelessWidget {
  const _AddExamModal();

  InputDecoration _inputDecoration({String? hint, IconData? icon}) {
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

  Widget _buildSectionTitle(String title, IconData icon) {
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

  Widget _buildTextField(
    String label,
    String initialValue, {
    IconData? icon,
    int maxLines = 1,
    String? hint,
  }) {
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
        TextFormField(
          initialValue: initialValue.isEmpty ? null : initialValue,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          decoration: _inputDecoration(hint: hint, icon: icon),
        ),
      ],
    );
  }

  // FIX: usa `value` en lugar del inexistente `initialValue`
  Widget _buildDropdown(
    String label,
    String currentValue,
    List<String> items,
    IconData icon,
  ) {
    final validValue = items.contains(currentValue)
        ? currentValue
        : items.first;
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
        DropdownButtonFormField<String>(
          value: validValue,
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
          decoration: _inputDecoration(icon: icon),
          items: items
              .map((v) => DropdownMenuItem(value: v, child: Text(v)))
              .toList(),
          onChanged: (val) {},
        ),
      ],
    );
  }

  Widget _buildAutocomplete(
    String label,
    String initialValue,
    List<String> options,
  ) {
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
        Autocomplete<String>(
          initialValue: TextEditingValue(text: initialValue),
          optionsBuilder: (tv) {
            if (tv.text.isEmpty) return const Iterable<String>.empty();
            return options.where(
              (o) => o.toLowerCase().contains(tv.text.toLowerCase()),
            );
          },
          fieldViewBuilder: (context, controller, focusNode, onDone) =>
              TextFormField(
                controller: controller,
                focusNode: focusNode,
                onEditingComplete: onDone,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                decoration: _inputDecoration(
                  hint: 'Escribe para buscar...',
                  icon: Icons.search_rounded,
                ),
              ),
          optionsViewBuilder: (context, onSelected, options) => Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(16),
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                width: MediaQuery.of(context).size.width - 80,
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (_, i) {
                    final option = options.elementAt(i);
                    return ListTile(
                      leading: const Icon(
                        Icons.label_important_outline_rounded,
                        size: 18,
                        color: Colors.grey,
                      ),
                      title: Text(
                        option,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () => onSelected(option),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilePicker(String label, String? fileName) {
    final hasFile = fileName != null;
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
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                  hasFile ? Icons.check_circle : Icons.upload_file_rounded,
                  size: 20,
                  color: hasFile
                      ? Colors.green[600]
                      : const Color(0xFF00338D).withValues(alpha: 0.6),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    fileName ?? 'Toca para explorar archivos...',
                    style: TextStyle(
                      color: hasFile ? Colors.green[800] : Colors.grey[500],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
                            'Completa la información para dar de alta la oferta',
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
                      _buildSectionTitle(
                        'Asignatura y Clasificación',
                        Icons.menu_book_outlined,
                      ),
                      const SizedBox(height: 16),
                      _buildAutocomplete(
                        'Unidad de Aprendizaje (Materia)',
                        '',
                        [
                          'Redes de Computadoras',
                          'Compiladores',
                          'Análisis y Diseño de Sistemas',
                          'Arquitectura de Computadoras',
                          'Liderazgo Personal',
                          'Trabajo Terminal II',
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdown('Carrera', 'ISC 2020', [
                              'ISC 2020',
                              'ISC 2009',
                              'IIA',
                              'LCD',
                              'ISISA',
                            ], Icons.school_outlined),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDropdown('Turno', 'Matutino', [
                              'Matutino',
                              'Vespertino',
                            ], Icons.wb_sunny_outlined),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildDropdown(
                        'Área de Formación',
                        'Profesional',
                        [
                          'Científica Básica',
                          'Profesional',
                          'Institucional',
                          'Terminal y de integración',
                        ],
                        Icons.account_tree_outlined,
                      ),
                      const SizedBox(height: 32),
                      _buildSectionTitle(
                        'Programación y Espacio',
                        Icons.event_available_outlined,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              'Fecha',
                              '',
                              icon: Icons.calendar_today_rounded,
                              hint: 'Ej. 19 jun 2026',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              'Horario',
                              '',
                              icon: Icons.access_time_rounded,
                              hint: 'Ej. 10:00:00',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildAutocomplete('Salón / Laboratorio', '', [
                        '1203',
                        '1204',
                        '2201',
                        '4003',
                        '4103',
                        'Laboratorio de Redes',
                      ]),
                      const SizedBox(height: 32),
                      _buildSectionTitle(
                        'Coordinador Evaluador',
                        Icons.badge_outlined,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        'Nombre completo',
                        '',
                        icon: Icons.person_outline_rounded,
                        hint: 'Nombre del profesor de ESCOM',
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        'Correo Institucional',
                        '',
                        icon: Icons.alternate_email_rounded,
                        hint: 'ejemplo@ipn.mx',
                      ),
                      const SizedBox(height: 32),
                      _buildSectionTitle(
                        'Recursos Adicionales',
                        Icons.folder_open_outlined,
                      ),
                      const SizedBox(height: 16),
                      _buildFilePicker('Proyecto (Opcional)', null),
                      const SizedBox(height: 16),
                      _buildFilePicker('Guía de Estudio (Opcional)', null),
                      const SizedBox(height: 16),
                      _buildTextField(
                        'Nota para el alumno',
                        '',
                        maxLines: 3,
                        hint: 'Instrucciones especiales para el examen...',
                      ),
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
                    icon: const Icon(Icons.add_circle_outline_rounded),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF00338D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      // TODO: INSERT en Supabase
                      Navigator.pop(context);
                    },
                    label: const Text(
                      'Crear Examen',
                      style: TextStyle(
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
