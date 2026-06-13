// ============================================================
// NOMBRE: color_schemes.dart
// USO: Define los esquemas de color claro y oscuro de Material 3
//      a partir del color semilla del IPN. Consumido por AppTheme.
// ============================================================
import 'package:flutter/material.dart';

const Color _seedColor = Color(0xFF0057B8);

final ColorScheme lightColorScheme = ColorScheme.fromSeed(
  seedColor: _seedColor,
  brightness: Brightness.light,
);

final ColorScheme darkColorScheme = ColorScheme.fromSeed(
  seedColor: _seedColor,
  brightness: Brightness.dark,
);
