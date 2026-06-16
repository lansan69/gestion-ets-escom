import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_ets_escom/core/providers/core_providers.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/edificio.dart';

final edificiosProvider = FutureProvider<List<Edificio>>((ref) async {
  final result = await ref.read(sharedRepositoryProvider).getEdificios();
  return result.fold(
    (failure) => throw failure.message,
    (edificios) => edificios,
  );
});
