import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_ets_escom/core/providers/core_providers.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/calendario_examen.dart';

// Carga todos los exámenes guardados en el calendario local.
// Se invalida después de add / remove para forzar una recarga.
final calendarioPageProvider = FutureProvider.autoDispose<List<CalendarioExamen>>((ref) async {
  final result = await ref.read(getCalendarioExamenesProvider).call();
  return result.fold(
    (failure) => throw failure.message,
    (list) => list,
  );
});
