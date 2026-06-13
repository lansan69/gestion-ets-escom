// ============================================================
// NOMBRE: explore_materias_selection.dart
// USO: Pantalla de resultados de exploración. Muestra la lista
//      de exámenes filtrada por la selección de carrera y semestre
//      elegida en los pasos anteriores. Ruta: /explorar/seleccion.
// ============================================================
import 'package:flutter/material.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/app_colors.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/app_text_styles.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/app_buttons.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/app_search_bar.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/background_pattern_painter.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/card_materia.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/card_materia_expanded.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/filter_card.dart';

class ExploreMateriasSelection extends StatefulWidget {
  @override
  State<ExploreMateriasSelection> createState() =>
      _ExploreMateriasSelectionState();
}

class _ExploreMateriasSelectionState extends State<ExploreMateriasSelection> {
  Set<String> _selectedCarreras = {'ISC'};
  Set<String> _selectedSemestres = {'5', '7', '9'};
  Set<String> _selectedArea = {'Todas'};

  final _searchController = TextEditingController();
  int _selectedNavIndex = 0;

  static const List<_MateriaStub> _materias = [
    _MateriaStub(
      'Cálculo Diferencial e Integral',
      'Dr. Ramírez Torres',
      5,
      302,
      '5 jun 2026',
      '08:00',
      'Matutino',
      EtsStatus.today,
    ),
    _MateriaStub(
      'Cálculo Diferencial e Integral',
      'Dr. Ramírez Torres',
      5,
      302,
      '5 jun 2026',
      '08:00',
      'Matutino',
      EtsStatus.today,
    ),
    _MateriaStub(
      'Estructuras de Datos',
      'M.C. López Hernández',
      5,
      201,
      '6 jun 2026',
      '10:00',
      'Matutino',
      EtsStatus.tomorrow,
    ),
    _MateriaStub(
      'Álgebra Lineal',
      'Dra. Morales Reyes',
      5,
      204,
      '8 jun 2026',
      '09:00',
      'Matutino',
      EtsStatus.soon,
    ),
    _MateriaStub(
      'Probabilidad y Estadística',
      'M.C. Fuentes Nava',
      5,
      310,
      '9 jun 2026',
      '11:00',
      'Matutino',
      EtsStatus.soon,
    ),
    _MateriaStub(
      'Programación Orientada a Objetos',
      'Ing. García Mendoza',
      7,
      405,
      '15 jun 2026',
      '08:00',
      'Matutino',
      EtsStatus.far,
    ),
    _MateriaStub(
      'Sistemas Operativos',
      'Dr. Vázquez Ruiz',
      7,
      108,
      '17 jun 2026',
      '16:00',
      'Vespertino',
      EtsStatus.far,
    ),
    _MateriaStub(
      'Cálculo Diferencial e Integral',
      'Dr. Ramírez Torres',
      5,
      302,
      '5 jun 2026',
      '08:00',
      'Matutino',
      EtsStatus.today,
    ),
    _MateriaStub(
      'Cálculo Diferencial e Integral',
      'Dr. Ramírez Torres',
      5,
      302,
      '5 jun 2026',
      '08:00',
      'Matutino',
      EtsStatus.today,
    ),
    _MateriaStub(
      'Cálculo Diferencial e Integral',
      'Dr. Ramírez Torres',
      5,
      302,
      '5 jun 2026',
      '08:00',
      'Matutino',
      EtsStatus.today,
    ),
    _MateriaStub(
      'Redes de Computadoras',
      'M.C. Pérez Castro',
      9,
      310,
      '20 jun 2026',
      '12:00',
      'Matutino',
      EtsStatus.far,
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
            // ─── Fondo decorativo ──────────────────────────────────
            CustomPaint(
              size: Size.infinite,
              painter: BackgroundPatternPainter(),
            ),
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
                          selectedCarreras: _selectedCarreras,
                          selectedSemestres: _selectedSemestres,
                          selectedArea: _selectedArea,
                          onCarrerasChanged: (set) =>
                              setState(() => _selectedCarreras = set),
                          onSemestresChanged: (set) =>
                              setState(() => _selectedSemestres = set),
                          onAreaChanged: (v) =>
                              setState(() => _selectedArea = v),
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
                                    'Tu selección',
                                    style: AppTextStyles.headingLarge,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Esta selección no es guardada al cerrar la app. Para guardar dirígete a Inicio y aplica los filtros.',
                                    style: AppTextStyles.bodySecondary,
                                  ),
                                  const SizedBox(height: 4),
                                ],
                              ),
                            ),
                          ),
                          SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final materia = _materias[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 6,
                                ),
                                child: CardExamenMateria(
                                  nombreMateria: materia.nombre,
                                  profesor: materia.profesor,
                                  semestre: materia.semestre,
                                  salon: materia.salon,
                                  fecha: materia.fecha,
                                  hora: materia.hora,
                                  turno: materia.turno,
                                  status: materia.status,
                                ),
                              );
                            }, childCount: _materias.length),
                          ),
                          const SliverToBoxAdapter(child: SizedBox(height: 16)),
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
      ),
    );
  }
}

class _MateriaStub {
  final String nombre;
  final String profesor;
  final int semestre;
  final int salon;
  final String fecha;
  final String hora;
  final String turno;
  final EtsStatus status;

  const _MateriaStub(
    this.nombre,
    this.profesor,
    this.semestre,
    this.salon,
    this.fecha,
    this.hora,
    this.turno,
    this.status,
  );
}
