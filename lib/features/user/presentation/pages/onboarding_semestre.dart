// ============================================================
// NOMBRE: onboarding_semestre.dart
// USO: Paso 2 del onboarding. Permite al usuario seleccionar
//      hasta 3 semestres mediante SemestreCard. Navega a /inicio
//      al continuar. Ruta: /onboarding/semestre.
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gestion_ets_escom/features/user/presentation/providers/selection_providers.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/app_colors.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/app_buttons.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/background_pattern_painter.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/semestre_card.dart';

class OnBoardingSemestre extends ConsumerWidget {
  const OnBoardingSemestre({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double buttonWidth = screenWidth * 0.9;
    final double cardWidth = (screenWidth - 60 - 20) / 3;

    // Observa la lista de semestres seleccionados desde el provider.
    final selected = ref.watch(selectedSemestresProvider);

    return Scaffold(
      backgroundColor: AppColors.primaryDarkBlue,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ─── Encabezado con patrón de fondo ─────────────────────────────────────────
            Container(
              height: MediaQuery.of(context).size.height * 0.08,
              color: AppColors.primaryDarkBlue,
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  CustomPaint(
                    size: Size.infinite,
                    painter: BackgroundPatternPainter(),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10, left: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        Spacer(),
                        Text(
                          'Configura tu perfil',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ─── Contenido principal ────────────────────────────────────────────────────
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.backgroundWhite,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.only(
                  top: 10,
                  left: 30,
                  right: 30,
                  bottom: 30,
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
                            onToggle: (numero, isSelected) {
                              if (isSelected) {
                                ref
                                    .read(selectedSemestresProvider.notifier)
                                    .add(numero);
                              } else {
                                ref
                                    .read(selectedSemestresProvider.notifier)
                                    .remove(numero);
                              }
                            },
                            canSelect: () => selected.length < 3,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (i) {
                        final filled = i < selected.length;
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
                      label: 'Continuar',
                      width: buttonWidth,
                      onPressed: () => context.push('/inicio'),
                    ),
                    AppSecondaryButton(
                      label: 'Omitir',
                      width: buttonWidth,
                      onPressed: () => context.push('/inicio'),
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
