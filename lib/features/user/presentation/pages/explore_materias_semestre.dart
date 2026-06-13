// ============================================================
// NOMBRE: explore_materias_semestre.dart
// USO: Pantalla de exploración por semestre. Muestra tarjetas
//      seleccionables de semestres y sincroniza la selección con
//      el FilterCard. Ruta: /explorar/semestre.
// ============================================================
import 'package:flutter/material.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/app_colors.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/app_text_styles.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/app_buttons.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/app_search_bar.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/background_pattern_painter.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/filter_card.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/semestre_card.dart';

class ExploreSemestres extends StatefulWidget {
  @override
  State<ExploreSemestres> createState() => _ExploreSemestresState();
}

class _ExploreSemestresState extends State<ExploreSemestres> {
  final List<int> _selected = [];

  String _selectedCarrera = 'ISC';
  Set<String> _selectedSemestres = {'5', '7', '9'};
  Set<String> _selectedArea = {'Todas'};

  final _searchController = TextEditingController();
  int _selectedNavIndex = 0;

  static const _semestres = [1, 2, 3, 4, 5, 6, 7, 8];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Agrega o quita un semestre de los sets de selección al hacer toggle.
  void _onCardToggle(int numero, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selected.add(numero);
        _selectedSemestres.remove('Todos');
        _selectedSemestres.add(numero.toString());
      } else {
        _selected.remove(numero);
        _selectedSemestres.remove(numero.toString());
        if (_selectedSemestres.isEmpty) _selectedSemestres = {'Todos'};
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double cardWidth = (screenWidth - 60 - 20) / 3;

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
                          selectedCarreras: {_selectedCarrera},
                          selectedSemestres: _selectedSemestres,
                          selectedArea: _selectedArea,
                          onCarrerasChanged: (set) =>
                              setState(() => _selectedCarrera = set.first),
                          onSemestresChanged: (set) => setState(() {
                            _selectedSemestres = set;
                            _selected
                              ..clear()
                              ..addAll(
                                set.where((s) => s != 'Todos').map(int.parse),
                              );
                          }),
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
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                16,
                                20,
                                20,
                              ),
                              child: Text(
                                'Selecciona los semestres',
                                style: AppTextStyles.headingLarge,
                              ),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: List.generate(
                                  8,
                                  (index) => SizedBox(
                                    width: cardWidth,
                                    child: SemestreCard(
                                      numeroSemestre: index + 1,
                                      isSelected: _selectedSemestres.contains(
                                        (index + 1).toString(),
                                      ),
                                      onToggle: _onCardToggle,
                                      canSelect: () => true,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SliverToBoxAdapter(child: SizedBox(height: 16)),
                        ],
                      ),
                    ),
                    AppPrimaryButton(
                      label: 'Continuar',
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
