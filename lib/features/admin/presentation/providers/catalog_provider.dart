import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gestion_ets_escom/features/shared/domain/entities/carrera.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/edificio.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/salon.dart';
import 'package:gestion_ets_escom/features/admin/domain/usecases/catalogs/create_carrera.dart';
import 'package:gestion_ets_escom/features/admin/domain/usecases/catalogs/update_carrera.dart';
import 'package:gestion_ets_escom/features/admin/domain/usecases/catalogs/delete_carrera.dart';
import 'package:gestion_ets_escom/features/admin/domain/usecases/catalogs/create_salon.dart';
import 'package:gestion_ets_escom/features/admin/domain/usecases/catalogs/update_salon.dart';
import 'package:gestion_ets_escom/features/admin/domain/usecases/catalogs/delete_salon.dart';
import 'package:gestion_ets_escom/core/providers/core_providers.dart';

// ============================================================
// ESTADO
// ============================================================
class CatalogMutationState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  const CatalogMutationState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  CatalogMutationState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return CatalogMutationState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

// ============================================================
// NOTIFIER  (Riverpod 3: Notifier en lugar de StateNotifier)
// ============================================================
class CatalogMutationNotifier extends Notifier<CatalogMutationState> {
  @override
  CatalogMutationState build() => const CatalogMutationState();

  // Helpers internos para obtener usecases desde ref
  CreateCarrera get _createCarrera => CreateCarrera(ref.read(adminRepositoryProvider));
  UpdateCarrera get _updateCarrera => UpdateCarrera(ref.read(adminRepositoryProvider));
  DeleteCarrera get _deleteCarrera => DeleteCarrera(ref.read(adminRepositoryProvider));
  CreateSalon get _createSalon => CreateSalon(ref.read(adminRepositoryProvider));
  UpdateSalon get _updateSalon => UpdateSalon(ref.read(adminRepositoryProvider));
  DeleteSalon get _deleteSalon => DeleteSalon(ref.read(adminRepositoryProvider));

  // --- CARRERAS ---
  Future<void> addCarrera(Carrera carrera) async {
    state = state.copyWith(isLoading: true);
    final result = await _createCarrera.call(carrera);
    _handleResult(result);
  }

  Future<void> editCarrera(Carrera carrera) async {
    state = state.copyWith(isLoading: true);
    final result = await _updateCarrera.call(carrera);
    _handleResult(result);
  }

  Future<void> removeCarrera(String id) async {
    state = state.copyWith(isLoading: true);
    final result = await _deleteCarrera.call(id);
    _handleResult(result);
  }

  // --- SALONES ---
  Future<void> addSalon(Salon salon) async {
    state = state.copyWith(isLoading: true);
    final result = await _createSalon.call(salon);
    _handleResult(result);
  }

  Future<void> editSalon(Salon salon) async {
    state = state.copyWith(isLoading: true);
    final result = await _updateSalon.call(salon);
    _handleResult(result);
  }

  Future<void> removeSalon(String id) async {
    state = state.copyWith(isLoading: true);
    final result = await _deleteSalon.call(id);
    _handleResult(result);
  }

  // --- EDIFICIOS ---
  Future<void> addEdificio(Edificio edificio) async {
    state = state.copyWith(isLoading: true);
    final result = await ref.read(adminRepositoryProvider).createEdificio(edificio);
    _handleResult(result);
  }

  Future<void> editEdificio(Edificio edificio, int oldNumero) async {
    state = state.copyWith(isLoading: true);
    final result = await ref.read(adminRepositoryProvider).updateEdificio(edificio, oldNumero);
    _handleResult(result);
  }

  Future<void> removeEdificio(String id, int numero) async {
    state = state.copyWith(isLoading: true);
    final result = await ref.read(adminRepositoryProvider).deleteEdificio(id, numero);
    _handleResult(result);
  }

  void _handleResult(dynamic result) {
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, errorMessage: failure.message),
      (_) => state = state.copyWith(isLoading: false, isSuccess: true),
    );
  }

  void resetState() {
    state = const CatalogMutationState();
  }
}

// ============================================================
// PROVIDER GLOBAL  (Riverpod 3: NotifierProvider)
// ============================================================
final catalogMutationProvider =
    NotifierProvider<CatalogMutationNotifier, CatalogMutationState>(
  CatalogMutationNotifier.new,
);