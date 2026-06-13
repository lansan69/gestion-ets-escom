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

// Notifier que almacena la lista de semestres seleccionados (máximo 3).
// El estado inicial es una lista vacía (ningún semestre seleccionado todavía).
class SelectedSemestresNotifier extends Notifier<List<int>> {
  @override
  List<int> build() => [];

  // Agrega un semestre si no supera el límite de 3.
  void add(int semestre) {
    if (state.length < 3 && !state.contains(semestre)) {
      state = [...state, semestre];
    }
  }

  // Quita un semestre de la lista.
  void remove(int semestre) => state = state.where((s) => s != semestre).toList();

  // Limpia toda la selección.
  void clear() => state = [];
}

// Provider que expone el Notifier de semestres seleccionados.
// Consumido por OnboardingSemestre y por la lógica de navegación del onboarding.
final selectedSemestresProvider =
    NotifierProvider<SelectedSemestresNotifier, List<int>>(
      SelectedSemestresNotifier.new,
    );
