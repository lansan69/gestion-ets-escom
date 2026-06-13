// ============================================================
// NOMBRE: app_shell.dart
// USO: Shell persistente que envuelve las rutas principales con
//      AppBar y BottomNavigationBar. Consumido como builder del
//      ShellRoute en router.dart.
// ============================================================
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/app_colors.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/background_pattern_painter.dart';
import 'package:gestion_ets_escom/features/user/presentation/pages/individual_materia_view.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  static const _tabs = [
    (
      path: '/inicio',
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Inicio',
    ),
    (
      path: '/explorar',
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore,
      label: 'Explorar',
    ),
    (
      path: '/calendario',
      icon: Icons.calendar_month_outlined,
      activeIcon: Icons.calendar_month,
      label: 'Calendario',
    ),
    (
      path: '/config',
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      label: 'Config',
    ),
  ];

  // Devuelve el índice del tab activo según el path actual.
  int _selectedIndex(String location) {
    final idx = _tabs.indexWhere((t) => location.startsWith(t.path));
    return idx >= 0 ? idx : 0;
  }

  // Resuelve el título del AppBar según la ruta activa y los datos extra pasados.
  String _title(String location, Object? extra) {
    if (location.startsWith('/inicio')) return 'Mis Materias';
    if (location.startsWith('/explorar')) return 'Explorar';
    if (location.startsWith('/calendario')) return 'Calendario';
    if (location.startsWith('/config')) return 'Configuración';
    if (location.startsWith('/materia') && extra is MateriaData) {
      return extra.nombre;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final state = GoRouterState.of(context);
    final location = state.uri.path;
    final selectedIndex = _selectedIndex(location);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        automaticallyImplyLeading: false,
        title: Text(_title(location, state.extra)),
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: CustomPaint(
          painter: BackgroundPatternPainter(),
          child: const SizedBox.expand(),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (i) => context.push(_tabs[i].path),
        selectedItemColor: AppColors.navBarActiveItem,
        unselectedItemColor: AppColors.navBarInactiveItem,
        backgroundColor: AppColors.navBarBackground,
        type: BottomNavigationBarType.fixed,
        items: _tabs
            .map(
              (t) => BottomNavigationBarItem(
                icon: Icon(t.icon),
                activeIcon: Icon(t.activeIcon),
                label: t.label,
              ),
            )
            .toList(),
      ),
      body: child,
    );
  }
}
