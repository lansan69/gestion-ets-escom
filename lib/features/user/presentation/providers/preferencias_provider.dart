import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_ets_escom/core/providers/core_providers.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/preferencia.dart';

// Lee la preferencia activa del usuario desde SQLite.
// Devuelve null si el usuario nunca ha completado el onboarding.
final preferenciasPageProvider = FutureProvider.autoDispose<Preferencia?>((ref) async {
  final result = await ref.read(getPreferenciaProvider).call();
  return result.fold(
    (failure) => throw failure.message,
    (preferencia) => preferencia,
  );
});
