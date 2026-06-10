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
