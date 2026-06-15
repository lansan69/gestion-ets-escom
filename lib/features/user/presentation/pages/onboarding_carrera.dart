// ============================================================
// NOMBRE: onboarding_carrera.dart
// USO: Paso 1 del onboarding. Permite al usuario seleccionar su
//      carrera de la lista cargada desde Supabase. Navega a
//      onboarding_semestre pasando el UUID seleccionado como extra.
//      Ruta: /onboarding/carrera.
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_ets_escom/core/utils/snackbar_helper.dart';
import 'package:gestion_ets_escom/features/shared/data/datasources/local/database_helper.dart';
import 'package:gestion_ets_escom/features/user/presentation/providers/filter_providers.dart';
import 'package:gestion_ets_escom/features/user/presentation/providers/preferencias_provider.dart';
import 'package:sqflite/sqflite.dart'; // ConflictAlgorithm
import 'package:gestion_ets_escom/features/user/presentation/providers/carrera_providers.dart';
import 'package:go_router/go_router.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/app_colors.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/app_buttons.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/background_pattern_painter.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/selectable_career_card.dart';

const List<Color> _carreraColors = [
  AppColors.primaryDarkBlue,
  AppColors.statusComingSoonForeground,
  AppColors.primaryCherry,
  AppColors.statusAvailableForeground,
];

class OnBoardingCarrera extends ConsumerStatefulWidget {
  final bool isEditing;
  const OnBoardingCarrera({super.key, this.isEditing = false});

  @override
  ConsumerState<OnBoardingCarrera> createState() => _OnBoardingCarreraState();
}

class _OnBoardingCarreraState extends ConsumerState<OnBoardingCarrera> {
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) _loadCurrentCarrera();
  }

  Future<void> _loadCurrentCarrera() async {
    final db = await DatabaseHelper().database;
    final rows = await db.query('preferencia', where: 'omitir = 0', limit: 1);
    if (!mounted || rows.isEmpty) return;
    final cid = rows.first['carrera_id'] as String?;
    if (cid != null && cid.isNotEmpty) {
      setState(() => _selectedId = cid);
    }
  }

  Future<void> _saveEditing() async {
    if (_selectedId == null) return;
    final db = await DatabaseHelper().database;
    final rows = await db.query('preferencia', where: 'omitir = 0', limit: 1);
    final existing = rows.isNotEmpty ? rows.first : null;

    // Delete all rows first — updating a PRIMARY KEY in-place violates constraints
    // when the new carrera_id might already exist in another row.
    await db.delete('preferencia');
    await db.insert(
      'preferencia',
      {
        'carrera_id': _selectedId,
        'omitir': 0,
        'seleccion1_semestre': existing?['seleccion1_semestre'],
        'seleccion2_semestre': existing?['seleccion2_semestre'],
        'seleccion3_semestre': existing?['seleccion3_semestre'],
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    if (!mounted) return;
    ref.invalidate(preferenciasPageProvider);
    ref.read(filterCarreraProvider.notifier).select(_selectedId!);
    SnackbarHelper.showSuccess(context, 'Carrera actualizada');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final double buttonWidth = MediaQuery.of(context).size.width * 0.9;
    final carrerasAsync = ref.watch(carrerasProvider);

    return Scaffold(
      backgroundColor: AppColors.primaryDarkBlue,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(
          widget.isEditing ? 'Cambiar carrera' : 'Configura tu perfil',
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
                    Expanded(
                      child: SingleChildScrollView(
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
                                  alignment: Alignment.centerLeft,
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
                              widget.isEditing ? 'Cambio de carrera' : 'Paso 1 de 2',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 30),
                            Text(
                              '¿Cuál es tu carrera?',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              widget.isEditing
                                  ? 'Tus semestres se mantendrán igual'
                                  : 'Podrás cambiarla después en configuración',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 20),
                            carrerasAsync.when(
                              loading: () => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              error: (e, _) => const Center(
                                child: Text('Error al cargar carreras'),
                              ),
                              data: (carreras) => Column(
                                children: [
                                  for (int i = 0; i < carreras.length; i++) ...[
                                    SelectableCareerCard(
                                      abreviatura: carreras[i].abreviatura,
                                      nombre: carreras[i].nombre,
                                      colorBarra: _carreraColors[i % _carreraColors.length],
                                      isSelected: _selectedId == carreras[i].id,
                                      onToggle: (_, selected) {
                                        setState(() {
                                          _selectedId = selected ? carreras[i].id : null;
                                        });
                                      },
                                      canSelect: () => true,
                                    ),
                                    if (i < carreras.length - 1)
                                      const SizedBox(height: 20),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    AppPrimaryButton(
                      label: widget.isEditing ? 'Guardar' : 'Continuar',
                      width: buttonWidth,
                      onPressed: widget.isEditing
                          ? _saveEditing
                          : () => context.push(
                                '/onboarding/semestre',
                                extra: _selectedId,
                              ),
                    ),
                    if (!widget.isEditing)
                      AppSecondaryButton(
                        label: 'Omitir',
                        width: buttonWidth,
                        onPressed: () async {
                          final db = await DatabaseHelper().database;
                          await db.insert(
                            'preferencia',
                            {'omitir': 1, 'carrera_id': ''},
                            conflictAlgorithm: ConflictAlgorithm.replace,
                          );
                          if (!context.mounted) return;
                          context.go('/inicio');
                        },
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
