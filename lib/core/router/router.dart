// ============================================================
// NOMBRE: router.dart
// USO: Define el GoRouter principal de la aplicación con todas
//      las rutas (splash, onboarding, shell con tabs, detalle de materia).
//      Registrado en main.dart mediante MaterialApp.router.
//      La lógica de redirección inicial vive en SplashPage, que
//      consulta SQLite y navega al destino correcto.
// ============================================================
import 'package:flutter/material.dart';
import 'package:gestion_ets_escom/features/shared/presentation/pages/splash_page.dart';
import 'package:gestion_ets_escom/features/user/presentation/pages/calendario.dart';
import 'package:gestion_ets_escom/features/user/presentation/pages/explore_exams.dart';
import 'package:gestion_ets_escom/features/user/presentation/pages/salones_page.dart';
import 'package:go_router/go_router.dart';
import 'package:gestion_ets_escom/core/router/app_shell.dart';
import 'package:gestion_ets_escom/features/shared/presentation/pages/welcome_page.dart';
import 'package:gestion_ets_escom/features/user/presentation/pages/individual_materia_view.dart';
import 'package:gestion_ets_escom/features/user/presentation/pages/onboarding_carrera.dart';
import 'package:gestion_ets_escom/features/user/presentation/pages/onboarding_semestre.dart';
import 'package:gestion_ets_escom/core/router/admin_shell.dart';
import 'package:gestion_ets_escom/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:gestion_ets_escom/features/admin/presentation/pages/admin_catalogs_page.dart';
import 'package:gestion_ets_escom/features/admin/presentation/pages/admin_login_page.dart';
import 'package:gestion_ets_escom/features/admin/presentation/pages/admin_profile_page.dart';
import 'package:gestion_ets_escom/features/user/presentation/pages/calendar_page.dart';
import 'package:gestion_ets_escom/features/user/presentation/pages/settings_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (_, _) => const SplashPage()),
    GoRoute(path: '/bienvenida', builder: (_, _) => const WelcomePage()),
    
    // 2. Agrega la ruta de login del administrador aquí, en el nivel superior
    GoRoute(
      path: '/admin/login',
      builder: (_, _) => const AdminLoginPage(),
    ),
    // --- NUEVO BLOQUE DEL ADMINISTRADOR ---
    // --- NUEVO BLOQUE DEL ADMINISTRADOR ---
    ShellRoute(
      builder: (_, _, child) => AdminShell(child: child),
      routes: [
        GoRoute(
          path: '/admin/dashboard',
          builder: (_, _) => const AdminDashboardPage(),
        ),
        GoRoute(
          path: '/admin/catalogos',
          builder: (_, _) => const AdminCatalogsPage(),
        ),
        // AQUÍ ESTÁ EL CAMBIO:
        GoRoute(
          path: '/admin/perfil',
          builder: (_, _) => const AdminProfilePage(), // <-- Ahora apunta a tu página real
        ),
      ],
    ),
    // -------------------------------------
    GoRoute(
      path: '/onboarding/carrera',
      builder: (_, _) => const OnBoardingCarrera(),
    ),
    GoRoute(
      path: '/onboarding/semestre',
      builder: (_, state) =>
          OnBoardingSemestre(carreraId: state.extra as String?),
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
          builder: (_, _) => const CalendarPage(), // <-- Reemplazo aquí
        ),
        GoRoute(path: '/salones', builder: (_, _) => const SalonesPage()),
        GoRoute(
          path: '/config',
          builder: (_, _) => const SettingsPage(), // <-- Reemplazo aquí
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