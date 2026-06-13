// ============================================================
// NOMBRE: explore_exams.dart
// USO: Pantalla principal del usuario. Muestra la lista de
//      exámenes ETS con filtros y barra de búsqueda. Navega a
//      IndividualMateriaView al tocar una tarjeta. Ruta: /inicio.
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_ets_escom/core/utils/date_formatter.dart';
import 'package:gestion_ets_escom/features/user/presentation/providers/carrera_providers.dart';
import 'package:gestion_ets_escom/features/user/presentation/providers/examenes_providers.dart';
import 'package:gestion_ets_escom/features/user/presentation/providers/filter_providers.dart';
import 'package:gestion_ets_escom/features/user/presentation/providers/selection_providers.dart';
import 'package:go_router/go_router.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/app_colors.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/app_text_styles.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/app_buttons.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/app_search_bar.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/background_pattern_painter.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/card_materia.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/card_materia_expanded.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/filter_card.dart';
import 'package:gestion_ets_escom/features/user/presentation/pages/individual_materia_view.dart';

EtsStatus _statusForDate(DateTime fecha) {
  final today = DateTime.now();
  final examDay = DateTime(fecha.year, fecha.month, fecha.day);
  final todayDay = DateTime(today.year, today.month, today.day);
  final diff = examDay.difference(todayDay).inDays;
  if (diff == 0) return EtsStatus.today;
  if (diff == 1) return EtsStatus.tomorrow;
  if (diff <= 7) return EtsStatus.soon;
  return EtsStatus.far;
}

Color _barColorForStatus(EtsStatus status) => switch (status) {
  EtsStatus.today => AppColors.statusTodayForeground,
  EtsStatus.tomorrow => AppColors.statusTomorrowForeground,
  EtsStatus.soon => AppColors.statusSoonForeground,
  EtsStatus.far => AppColors.statusFarForeground,
};

Color? _colorFromHex(String? hex) {
  if (hex == null) return null;
  final h = hex.replaceAll('#', '').trim();
  if (h.length != 6) return null;
  return Color(int.parse('FF$h', radix: 16));
}

class ExploreExams extends ConsumerStatefulWidget {
  const ExploreExams({super.key});
  @override
  ConsumerState<ExploreExams> createState() => _ExploreExamsState();
}

class _ExploreExamsState extends ConsumerState<ExploreExams> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-rellena los filtros con la selección del onboarding en la primera
    // visita. Si el usuario ya modificó los filtros manualmente, no se sobreescriben.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initFiltersFromSelection();
    });
  }

  // Siembra los filtros de carrera y semestres a partir de la selección activa del
  // onboarding, solo si cada filtro está en su estado inicial (null / vacío).
  // filterCarreraProvider almacena el UUID directamente; FilterCard lo resuelve
  // a etiqueta usando las listas de opciones que recibe del padre.
  void _initFiltersFromSelection() {
    if (ref.read(filterCarreraProvider) == null) {
      final carreraId = ref.read(selectedCarreraProvider);
      if (carreraId != null) {
        ref.read(filterCarreraProvider.notifier).select(carreraId);
      }
    }

    if (ref.read(filterSemestresProvider).isEmpty) {
      for (final s in ref.read(selectedSemestresProvider)) {
        ref.read(filterSemestresProvider.notifier).add(s);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final examenesAsync = ref.watch(examenesProvider);
    final topOffset = MediaQuery.of(context).padding.top + 10;

    // ─── Lectura de providers ─────────────────────────────────────────────────
    final filterCarrera = ref.watch(filterCarreraProvider);
    final filterSemestres = ref.watch(filterSemestresProvider);
    final filterArea = ref.watch(filterAreaProvider);
    final filterTurno = ref.watch(filterTurnoProvider);
    final filterFecha = ref.watch(filterFechaProvider);
    final filterSalon = ref.watch(filterSalonProvider);

    // Listas de opciones para FilterCard, extraídas del caché local.
    final carreras = ref.watch(carrerasProvider).value ?? [];
    final areas = ref.watch(areasFormacionProvider).value ?? [];

    // ─── Conversión provider → tipos que espera FilterCard ────────────────────
    // Carrera y área usan UUID como valor; 'Todas'/'Todas' indica sin filtro.
    final selectedCarreras = filterCarrera == null
        ? {'Todas'}
        : {filterCarrera};
    final selectedSemestres = filterSemestres.isEmpty
        ? {'Todos'}
        : filterSemestres.map((s) => s.toString()).toSet();
    final selectedArea = filterArea == null ? {'Todas'} : {filterArea};
    final selectedTurno = filterTurno ?? 'Todos';
    // filterSalon es String? (número como texto); FilterCard espera int?.
    final selectedSalon = filterSalon == null
        ? null
        : int.tryParse(filterSalon);
    return Container(
      height: double.infinity,
      width: double.infinity,
      color: AppColors.primaryDarkBlue,
      child: Stack(
        children: [
          // ─── Fondo decorativo ──────────────────────────────────
          CustomPaint(size: Size.infinite, painter: BackgroundPatternPainter()),
          // ─── Contenido ────────────────────────────────────────
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
                  // ─── Search bar ──────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: AppSearchBar(
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
                        selectedSalon: selectedSalon,
                        // Carrera: guarda el UUID del primer chip seleccionado; 'Todas' limpia.
                        onCarrerasChanged: (set) {
                          final n = ref.read(filterCarreraProvider.notifier);
                          (set.contains('Todas') || set.isEmpty)
                              ? n.clear()
                              : n.select(set.first);
                        },
                        // Semestres: reemplaza la lista completa con los valores del chip.
                        onSemestresChanged: (set) {
                          final n = ref.read(filterSemestresProvider.notifier);
                          n.clear();
                          for (final s in set) {
                            final i = int.tryParse(s);
                            if (i != null) n.add(i);
                          }
                        },
                        // Área: guarda el UUID del primer chip seleccionado; 'Todas' limpia.
                        onAreaChanged: (set) {
                          final n = ref.read(filterAreaProvider.notifier);
                          (set.contains('Todas') || set.isEmpty)
                              ? n.clear()
                              : n.select(set.first);
                        },
                        // Turno: 'Todos' limpia; cualquier otro valor lo selecciona.
                        onTurnoChanged: (v) {
                          final n = ref.read(filterTurnoProvider.notifier);
                          v == 'Todos' ? n.clear() : n.select(v);
                        },
                        // Fecha: null limpia; cualquier DateTime lo selecciona.
                        onFechaChanged: (d) {
                          final n = ref.read(filterFechaProvider.notifier);
                          d == null ? n.clear() : n.select(d);
                        },
                        // Salón: null limpia; el int se convierte a String para el provider.
                        onSalonChanged: (s) {
                          final n = ref.read(filterSalonProvider.notifier);
                          s == null ? n.clear() : n.select(s.toString());
                        },
                        onApply: () {},
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // ─── Lista ───────────────────────────────────
                  Expanded(
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Buenos días',
                                  style: AppTextStyles.headingLarge,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Explora los próximos ETS basados en tu carrera y semestre',
                                  style: AppTextStyles.bodySecondary,
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ),
                        ...examenesAsync.when(
                          loading: () => [
                            const SliverFillRemaining(
                              child: Center(child: CircularProgressIndicator()),
                            ),
                          ],
                          error: (e, _) => [
                            const SliverFillRemaining(
                              child: Center(
                                child: Text('Error al cargar exámenes'),
                              ),
                            ),
                          ],
                          data: (examenes) => [
                            SliverList(
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                final examen = examenes[index];
                                final status = _statusForDate(examen.fecha);
                                final areaColor = _colorFromHex(
                                  examen.materia.areaFormacion?.color,
                                );
                                final barColor =
                                    areaColor ?? _barColorForStatus(status);
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 6,
                                  ),
                                  child: CardExamenMateria(
                                    nombreMateria: examen.materia.nombre,
                                    profesor: examen.profesor.nombreCompleto,
                                    semestre: examen.materia.semestre,
                                    salon: examen.salon.numeroSalon,
                                    fecha: DateFormatter.formatDate(
                                      examen.fecha,
                                    ),
                                    hora: examen.hora,
                                    turno:
                                        examen.turno.name[0].toUpperCase() +
                                        examen.turno.name.substring(1),
                                    status: status,
                                    barColor: areaColor,
                                    onTap: () => context.push(
                                      '/materia',
                                      extra: MateriaData(
                                        nombre: examen.materia.nombre,
                                        profesor:
                                            examen.profesor.nombreCompleto,
                                        semestre: examen.materia.semestre,
                                        salon: examen.salon.numeroSalon,
                                        fecha: DateFormatter.formatDate(
                                          examen.fecha,
                                        ),
                                        hora: examen.hora,
                                        turno:
                                            examen.turno.name[0].toUpperCase() +
                                            examen.turno.name.substring(1),
                                        status: status,
                                        barColor: barColor,
                                      ),
                                    ),
                                  ),
                                );
                              }, childCount: examenes.length),
                            ),
                            const SliverToBoxAdapter(
                              child: SizedBox(height: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // ─── Botón principal ─────────────────────────
                  AppPrimaryButton(
                    label: 'Explorar ETS',
                    width: MediaQuery.of(context).size.width * 0.9,
                    onPressed: () {},
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
