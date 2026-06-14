// ============================================================
// NOMBRE: router.dart
// USO: Define el GoRouter principal de la aplicación con todas
//      las rutas (onboarding, shell con tabs, detalle de materia).
//      Registrado en main.dart mediante MaterialApp.router.
// ============================================================
import 'package:flutter/material.dart';
import 'package:gestion_ets_escom/features/user/presentation/pages/explore_exams.dart';
import 'package:go_router/go_router.dart';
import 'package:gestion_ets_escom/core/router/app_shell.dart';
import 'package:gestion_ets_escom/features/shared/presentation/welcome_page.dart';
import 'package:gestion_ets_escom/features/user/presentation/pages/individual_materia_view.dart';
import 'package:gestion_ets_escom/features/user/presentation/pages/onboarding_carrera.dart';
import 'package:gestion_ets_escom/features/user/presentation/pages/onboarding_semestre.dart';
import 'package:gestion_ets_escom/core/router/admin_shell.dart';
import 'package:gestion_ets_escom/features/admin/presentation/pages/admin_dashboard_page.dart';

// 1. Agrega la importación de tu nueva pantalla de login administrativo
import 'package:gestion_ets_escom/features/admin/presentation/pages/admin_login_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/bienvenida',
  routes: [
    GoRoute(path: '/bienvenida', builder: (_, _) => const WelcomePage()),
    
    // 2. Agrega la ruta de login del administrador aquí, en el nivel superior
    GoRoute(
      path: '/admin/login',
      builder: (_, _) => const AdminLoginPage(),
    ),
    // --- NUEVO BLOQUE DEL ADMINISTRADOR ---
    ShellRoute(
      builder: (_, _, child) => AdminShell(child: child),
      routes: [
        GoRoute(
          path: '/admin/dashboard',
          builder: (_, _) => const AdminDashboardPage(),
        ),
        // Pantallas "Placeholder" mientras las diseñamos
        GoRoute(
          path: '/admin/catalogos',
          builder: (_, _) => const Center(child: Text('Pantalla de Catálogos (A05)')),
        ),
        GoRoute(
          path: '/admin/perfil',
          builder: (_, _) => const Center(child: Text('Pantalla de Mi Cuenta (A06)')),
        ),
      ],
    ),
    // -------------------------------------
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
        GoRoute(path: '/inicio', builder: (_, _) => ExploreExams()),
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