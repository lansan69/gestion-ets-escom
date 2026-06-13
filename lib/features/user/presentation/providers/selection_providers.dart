// ============================================================
// NOMBRE: selection_providers.dart
// USO: Providers de estado para la selección de carrera y
//      semestre durante el onboarding. Consumidos por las
//      pantallas OnboardingCarrera y OnboardingSemestre, y
//      por cualquier lógica que dependa de la selección activa.
// ============================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

// Notifier que almacena el ID (UUID) de la carrera actualmente seleccionada.
// El estado inicial es null (ninguna carrera seleccionada todavía).
class SelectedCarreraNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  // Establece la carrera seleccionada a partir de su ID.
  void select(String id) => state = id;

  // Limpia la selección, volviendo al estado inicial sin carrera.
  void clear() => state = null;
}

// Provider que expone el Notifier de carrera seleccionada.
// Consumido por OnboardingCarrera y por la lógica de navegación del onboarding.
final selectedCarreraProvider = NotifierProvider<SelectedCarreraNotifier, String?>(
  SelectedCarreraNotifier.new,
);

// Notifier que almacena el número de semestre actualmente seleccionado.
// El estado inicial es null (ningún semestre seleccionado todavía).
class SelectedSemestreNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  // Establece el semestre seleccionado (número entero, del 1 al 9).
  void select(int semestre) => state = semestre;

  // Limpia la selección, volviendo al estado inicial sin semestre.
  void clear() => state = null;
}

// Provider que expone el Notifier de semestre seleccionado.
// Consumido por OnboardingSemestre y por la lógica de navegación del onboarding.
final selectedSemestreProvider =
    NotifierProvider<SelectedSemestreNotifier, int?>(
      SelectedSemestreNotifier.new,
    );
