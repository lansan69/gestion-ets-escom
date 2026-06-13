// ============================================================
// NOMBRE: explore_materias_carrera.dart
// USO: Pantalla de exploración por carrera. Muestra tarjetas
//      seleccionables de carreras y sincroniza la selección con
//      el FilterCard. Ruta: /explorar/carrera.
// ============================================================
import 'package:flutter/material.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/app_colors.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/app_text_styles.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/app_buttons.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/app_search_bar.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/background_pattern_painter.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/filter_card.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/selectable_career_card.dart';

class ExploreMateriasCarrera extends StatefulWidget {
  @override
  State<ExploreMateriasCarrera> createState() => _ExploreMateriasCarreraState();
}

class _ExploreMateriasCarreraState extends State<ExploreMateriasCarrera> {
  // filter-level carrera set ('Todas', 'ISC', 'IIA', …)
  Set<String> _selectedCarrerasFilter = {'Todas'};
  // which card abbreviations are visually selected
  Set<String> _selectedCardAbbrevs = {};

  Set<String> _selectedSemestres = {'5', '7', '9'};
  Set<String> _selectedArea = {'Todas'};

  final _searchController = TextEditingController();
  int _selectedNavIndex = 0;

  // Actualiza los sets de selección de tarjetas y filtros al hacer toggle en una carrera.
  void _onCareerToggle(String abrev, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedCardAbbrevs.add(abrev);
        // All cards selected → 'Todas'
        if (_selectedCardAbbrevs.length == _careers.length) {
          _selectedCarrerasFilter = {'Todas'};
        } else {
          _selectedCarrerasFilter.remove('Todas');
          _selectedCarrerasFilter.add(
            _careers.firstWhere((c) => c.abrev == abrev).filterCode,
          );
        }
      } else {
        _selectedCardAbbrevs.remove(abrev);
        _selectedCarrerasFilter
          ..remove('Todas')
          ..removeAll(
            _careers
                .where((c) => !_selectedCardAbbrevs.contains(c.abrev))
                .map((c) => c.filterCode),
          );
        if (_selectedCarrerasFilter.isEmpty) {
          _selectedCarrerasFilter = {'Todas'};
        }
      }
    });
  }

  // Sincroniza el estado visual de las tarjetas cuando el filtro cambia desde FilterCard.
  void _syncCardsFromFilter() {
    if (_selectedCarrerasFilter.contains('Todas')) {
      _selectedCardAbbrevs = Set.from(_careers.map((c) => c.abrev));
    } else {
      _selectedCardAbbrevs = Set.from(
        _careers
            .where((c) => _selectedCarrerasFilter.contains(c.filterCode))
            .map((c) => c.abrev),
      );
    }
  }

  static const _careers = [
    (
      abrev: 'ISC 2020',
      nombre: 'Ingeniería en Sistemas Computacionales',
      color: AppColors.primaryDarkBlue,
      filterCode: 'ISC 2020',
    ),
    (
      abrev: 'IA',
      nombre: 'Ingeniería en Inteligencia Artificial',
      color: AppColors.statusComingSoonForeground,
      filterCode: 'IA',
    ),
    (
      abrev: 'LCD',
      nombre: 'Licenciatura en Ciencia de Datos',
      color: AppColors.primaryCherry,
      filterCode: 'LCD',
    ),
    (
      abrev: 'ISC 2009',
      nombre: 'Ingeniería en Sistemas Computacionales (Plan 2009)',
      color: AppColors.statusAvailableForeground,
      filterCode: 'ISC 2009',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topOffset = MediaQuery.of(context).size.height * 0.08 + 10;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Explorar'),
        toolbarHeight: MediaQuery.of(context).size.height * 0.08,
        foregroundColor: AppColors.textPrimaryWhite,
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedNavIndex,
        onTap: (i) => setState(() => _selectedNavIndex = i),
        selectedItemColor: AppColors.navBarActiveItem,
        unselectedItemColor: AppColors.navBarInactiveItem,
        backgroundColor: AppColors.navBarBackground,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Explorar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: 'Calendario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Config',
          ),
        ],
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: AppColors.primaryDarkBlue,
        child: Stack(
          children: [
            CustomPaint(
              size: Size.infinite,
              painter: BackgroundPatternPainter(),
            ),
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
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: AppSearchBar(
                        hint: 'Buscar materia...',
                        onFilterTap: () => FilterCard.show(
                          context,
                          selectedCarreras: _selectedCarrerasFilter,
                          selectedSemestres: _selectedSemestres,
                          selectedArea: _selectedArea,
                          onCarrerasChanged: (set) => setState(() {
                            _selectedCarrerasFilter = set;
                            _syncCardsFromFilter();
                          }),
                          onSemestresChanged: (set) =>
                              setState(() => _selectedSemestres = set),
                          onAreaChanged: (v) =>
                              setState(() => _selectedArea = v),
                          onApply: () {},
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                              child: Text(
                                'Selecciona las carreras',
                                style: AppTextStyles.headingLarge,
                              ),
                            ),
                          ),
                          SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final c = _careers[index];
                              return Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  12,
                                  20,
                                  0,
                                ),
                                child: SelectableCareerCard(
                                  abreviatura: c.abrev,
                                  nombre: c.nombre,
                                  colorBarra: c.color,
                                  isSelected:
                                      _selectedCarrerasFilter.contains(
                                        'Todas',
                                      ) ||
                                      _selectedCardAbbrevs.contains(c.abrev),
                                  onToggle: _onCareerToggle,
                                ),
                              );
                            }, childCount: _careers.length),
                          ),
                          const SliverToBoxAdapter(child: SizedBox(height: 16)),
                        ],
                      ),
                    ),
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
      ),
    );
  }
}
