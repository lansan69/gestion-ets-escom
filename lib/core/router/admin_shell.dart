import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminShell extends StatelessWidget {
  final Widget child;

  const AdminShell({super.key, required this.child});

  // Este método lee la URL actual para saber qué pestaña pintar de azul
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/admin/dashboard')) return 0;
    if (location.startsWith('/admin/catalogos')) return 1;
    if (location.startsWith('/admin/perfil')) return 2;
    return 0; // Por defecto
  }

  // Este método ejecuta la navegación al tocar una pestaña
  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/admin/dashboard');
        break;
      case 1:
        context.go('/admin/catalogos');
        break;
      case 2:
        context.go('/admin/perfil');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // El child será la pantalla que GoRouter inyecte (Dashboard, Catálogos, etc.)
      body: child,
      
      // Componente nativo de Material Design 3
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        selectedIndex: _calculateSelectedIndex(context),
        onDestinationSelected: (int index) => _onItemTapped(index, context),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.circle_outlined), // Ícono temporal (ajusta al de tu Figma)
            selectedIcon: Icon(Icons.circle, color: Color(0xFF00338D)),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.circle_outlined),
            selectedIcon: Icon(Icons.circle, color: Color(0xFF00338D)),
            label: 'Catálogos',
          ),
          NavigationDestination(
            icon: Icon(Icons.circle_outlined),
            selectedIcon: Icon(Icons.circle, color: Color(0xFF00338D)),
            label: 'Mi Cuenta',
          ),
        ],
      ),
    );
  }
}