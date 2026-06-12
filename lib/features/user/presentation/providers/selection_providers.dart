import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectedCarreraNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String id) => state = id;
  void clear() => state = null;
}

final selectedCarreraProvider =
    NotifierProvider<SelectedCarreraNotifier, String?>(
      SelectedCarreraNotifier.new,
    );

class SelectedSemestreNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  void select(int semestre) => state = semestre;
  void clear() => state = null;
}

final selectedSemestreProvider =
    NotifierProvider<SelectedSemestreNotifier, int?>(
      SelectedSemestreNotifier.new,
    );
