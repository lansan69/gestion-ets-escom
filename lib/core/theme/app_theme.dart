// ============================================================
// NOMBRE: app_theme.dart
// USO: Expone los temas claro y oscuro de la aplicación usando
//      Material 3. Consumido por MaterialApp.router en main.dart.
// ============================================================
import 'package:flutter/material.dart';
import 'color_schemes.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: lightColorScheme,
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: darkColorScheme,
      );
}
