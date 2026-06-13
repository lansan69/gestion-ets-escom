import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_ets_escom/features/user/presentation/providers/carrera_providers.dart';
import 'package:go_router/go_router.dart';
import 'package:gestion_ets_escom/features/user/presentation/providers/selection_providers.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/app_colors.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/app_buttons.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/background_pattern_painter.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/selectable_career_card.dart';

// Lista de colores que se aplican de forma cíclica a cada tarjeta de carrera.
const List<Color> _carreraColors = [
  AppColors.primaryDarkBlue,
  AppColors.statusComingSoonForeground,
  AppColors.primaryCherry,
  AppColors.statusAvailableForeground,
];

class OnBoardingCarrera extends ConsumerWidget {
  // Widget sin estado que obtiene sus datos de los providers de Riverpod.
  const OnBoardingCarrera({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ancho dinámico de los botones basado en el ancho de la pantalla.
    final double buttonWidth = MediaQuery.of(context).size.width * 0.9;

    // Observa el provider que carga la lista de carreras de forma asíncrona.
    final carrerasAsync = ref.watch(carrerasProvider);
    // Observa el provider que almacena la carrera seleccionada por el usuario.
    final selectedId = ref.watch(selectedCarreraProvider);
    
    return Scaffold(
      backgroundColor: AppColors.primaryDarkBlue,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Encabezado superior con fondo decorativo y texto de bienvenida.
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

            // Contenido principal con tarjeta blanca y bordes redondeados.
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
                    // Barra de progreso que indica el paso actual del onboarding.
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
                      'Paso 1 de 2',
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
                      'Podrás cambiarla después en configuración',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Maneja los estados de carga, error y datos de la lista de carreras.
                    carrerasAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) =>
                          const Center(child: Text('Error al cargar carreras')),
                      data: (carreras) => Column(
                        children: [
                          for (int i = 0; i < carreras.length; i++) ...[
                            SelectableCareerCard(
                              abreviatura: carreras[i].abreviatura,
                              nombre: carreras[i].nombre,
                              colorBarra:
                                  _carreraColors[i % _carreraColors.length],
                              // Ajusta el estado seleccionado según el provider.
                              isSelected: selectedId == carreras[i].id,
                              onToggle: (_, selected) {
                                // Actualiza el provider de selección cuando el usuario toca la tarjeta.
                                if (selected) {
                                  ref
                                      .read(selectedCarreraProvider.notifier)
                                      .select(carreras[i].id);
                                } else {
                                  ref
                                      .read(selectedCarreraProvider.notifier)
                                      .clear();
                                }
                              },
                              canSelect: () => true,
                            ),
                            if (i < carreras.length - 1)
                              const SizedBox(height: 20),
                          ],
                        ],
                      ),
                    ),

                    const Spacer(),
                    AppPrimaryButton(
                      label: 'Continuar',
                      width: buttonWidth,
                      onPressed: () => context.push('/onboarding/semestre'),
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
