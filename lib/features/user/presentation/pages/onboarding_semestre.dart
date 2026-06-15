// ============================================================
// NOMBRE: onboarding_semestre.dart
// USO: Paso 2 del onboarding. Permite al usuario seleccionar
//      hasta 3 semestres. Al confirmar, persiste las preferencias
//      (carreraId × semestre) en SQLite y navega a /inicio.
//      Recibe carreraId desde OnBoardingCarrera vía GoRouter extra.
//      Ruta: /onboarding/semestre.
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gestion_ets_escom/core/utils/snackbar_helper.dart';
import 'package:gestion_ets_escom/features/shared/data/datasources/local/database_helper.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/app_colors.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/app_buttons.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/background_pattern_painter.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/semestre_card.dart';
import 'package:gestion_ets_escom/features/user/presentation/providers/filter_providers.dart';
import 'package:gestion_ets_escom/features/user/presentation/providers/preferencias_provider.dart';
import 'package:sqflite/sqflite.dart'; // ConflictAlgorithm

class OnBoardingSemestre extends ConsumerStatefulWidget {
  // UUID de la carrera seleccionada en el paso anterior; null si se omitió.
  final String? carreraId;
  final bool isEditing;

  const OnBoardingSemestre({super.key, this.carreraId, this.isEditing = false});

  @override
  ConsumerState<OnBoardingSemestre> createState() => _OnBoardingSemestreState();
}

class _OnBoardingSemestreState extends ConsumerState<OnBoardingSemestre> {
  final List<int> _selected = [];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  // Loads previously saved semester selections for the given carrera so
  // that returning users see their current configuration pre-filled.
  Future<void> _loadPreferences() async {
    final cid = widget.carreraId;
    if (cid == null) return;
    final db = await DatabaseHelper().database;
    final rows = await db.query(
      'preferencia',
      where: 'carrera_id = ? AND omitir = 0',
      whereArgs: [cid],
    );
    if (!mounted || rows.isEmpty) return;
    final row = rows.first;
    final sems = <int>[];
    for (final key in [
      'seleccion1_semestre',
      'seleccion2_semestre',
      'seleccion3_semestre',
    ]) {
      final v = row[key] as int?;
      if (v != null) sems.add(v);
    }
    setState(() {
      _selected
        ..clear()
        ..addAll(sems);
    });
  }

  // Persiste la selección como una única fila por carrera y navega al inicio.
  Future<void> _saveAndContinue() async {
    final cid = widget.carreraId;
    if (cid != null && _selected.isNotEmpty) {
      final db = await DatabaseHelper().database;
      _selected.sort();
      
      await db.insert('preferencia', {
        'carrera_id': cid,
        'omitir': 0,
        'seleccion1_semestre': _selected[0],
        'seleccion2_semestre': _selected.length > 1 ? _selected[1] : null,
        'seleccion3_semestre': _selected.length > 2 ? _selected[2] : null,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    if (!mounted) return;
    if (widget.isEditing) {
      ref.invalidate(preferenciasPageProvider);
      final semsNotifier = ref.read(filterSemestresProvider.notifier);
      semsNotifier.clear();
      for (final s in _selected) { semsNotifier.add(s); }
      SnackbarHelper.showSuccess(context, 'Preferencias actualizadas');
    }
    context.go('/config');
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double buttonWidth = screenWidth * 0.9;
    final double cardWidth = (screenWidth - 60 - 20) / 3;

    return Scaffold(
      backgroundColor: AppColors.primaryDarkBlue,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(
          widget.isEditing ? 'Cambiar semestres' : 'Configura tu perfil',
        ),
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: CustomPaint(
          painter: BackgroundPatternPainter(),
          child: const SizedBox.expand(),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.backgroundWhite,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: EdgeInsets.only(
                  top: 10,
                  left: 30,
                  right: 30,
                  bottom: MediaQuery.of(context).padding.bottom + 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          height: 6,
                          width: double.infinity,
                          color: AppColors.screenBackground,
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FractionallySizedBox(
                            widthFactor: 0.5,
                            child: Container(
                              height: 6,
                              color: AppColors.notificationBadge,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Paso 2 de 2',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      '¿Cuál es tu semestre?',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Puedes seleccionar hasta 3 semestres',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: List.generate(
                        8,
                        (index) => SizedBox(
                          width: cardWidth,
                          child: SemestreCard(
                            numeroSemestre: index + 1,
                            isSelected: _selected.contains(index + 1),
                            onToggle: (numero, isSelected) {
                              setState(() {
                                if (isSelected) {
                                  if (_selected.length < 3) {
                                    _selected.add(numero);
                                  }
                                } else {
                                  _selected.remove(numero);
                                }
                              });
                            },
                            canSelect: () => _selected.length < 3,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (i) {
                        final filled = i < _selected.length;
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: filled
                                ? AppColors.primaryDarkBlue
                                : AppColors.semesterChipUnselectedBackground,
                          ),
                        );
                      }),
                    ),
                    const Spacer(),
                    AppPrimaryButton(
                      label: widget.isEditing ? 'Guardar' : 'Continuar',
                      width: buttonWidth,
                      onPressed: _saveAndContinue,
                    ),
                    if (!widget.isEditing)
                      AppSecondaryButton(
                        label: 'Omitir',
                        width: buttonWidth,
                        onPressed: () => context.go('/inicio'),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
