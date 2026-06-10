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
