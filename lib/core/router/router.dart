// ============================================================
// NOMBRE: router.dart
// USO: Define el GoRouter principal de la aplicación con todas
//      las rutas (onboarding, shell con tabs, detalle de materia).
//      Registrado en main.dart mediante MaterialApp.router.
// ============================================================
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gestion_ets_escom/core/router/app_shell.dart';
import 'package:gestion_ets_escom/features/shared/presentation/welcome_page.dart';
import 'package:gestion_ets_escom/features/user/presentation/pages/dashboard_materias.dart';
import 'package:gestion_ets_escom/features/user/presentation/pages/explore_materias_carrera.dart';
import 'package:gestion_ets_escom/features/user/presentation/pages/explore_materias_semestre.dart';
import 'package:gestion_ets_escom/features/user/presentation/pages/explore_materias_selection.dart';
import 'package:gestion_ets_escom/features/user/presentation/pages/individual_materia_view.dart';
import 'package:gestion_ets_escom/features/user/presentation/pages/onboarding_carrera.dart';
import 'package:gestion_ets_escom/features/user/presentation/pages/onboarding_semestre.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/bienvenida',
  routes: [
    GoRoute(path: '/bienvenida', builder: (_, _) => const WelcomePage()),
    GoRoute(
      path: '/onboarding/semestre',
      builder: (_, _) => const OnBoardingSemestre(),
    ),
    GoRoute(
      path: '/onboarding/carrera',
      builder: (_, _) => const OnBoardingCarrera(),
    ),
    GoRoute(
      path: '/materia',
      builder: (_, state) =>
          IndividualMateriaView(data: state.extra as MateriaData),
    ),
    ShellRoute(
      builder: (_, _, child) => AppShell(child: child),
      routes: [
        GoRoute(path: '/inicio', builder: (_, _) => DashboardMaterias()),
        GoRoute(
          path: '/explorar',
          builder: (_, _) => const _PlaceholderTab(label: 'Explorar'),
          routes: [
            GoRoute(
              path: 'carrera',
              builder: (_, _) => ExploreMateriasCarrera(),
            ),
            GoRoute(path: 'semestre', builder: (_, _) => ExploreSemestres()),
            GoRoute(
              path: 'seleccion',
              builder: (_, _) => ExploreMateriasSelection(),
            ),
          ],
        ),
        GoRoute(
          path: '/calendario',
          builder: (_, _) => const _PlaceholderTab(label: 'Calendario'),
        ),
        GoRoute(
          path: '/config',
          builder: (_, _) => const _PlaceholderTab(label: 'Configuración'),
        ),
      ],
    ),
  ],
);

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Próximamente: $label',
        style: const TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }
}
