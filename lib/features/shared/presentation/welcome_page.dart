import 'package:flutter/material.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/app_colors.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/app_buttons.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/background_pattern_painter.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    const double avatarRadius = 40;
    final double buttonWidth = MediaQuery.of(context).size.width * 0.9;

    return Scaffold(
      backgroundColor: AppColors.primaryDarkBlue,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ─── Encabezado con patrón de fondo ─────────────────────────────────────────
            Container(
              height: MediaQuery.of(context).size.height * 0.4,
              color: AppColors.primaryDarkBlue,
              child: CustomPaint(
                size: Size.infinite,
                painter: BackgroundPatternPainter(),
              ),
            ),
            // ─── Panel de bienvenida ─────────────────────────────────────────────────────
            Expanded(
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  // ─── Tarjeta blanca de contenido ─────────────────────────────────────────
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppColors.backgroundWhite,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    padding: EdgeInsets.only(
                      top: avatarRadius * 2,
                      left: 30,
                      right: 30,
                      bottom: 30,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'ETS ESCOM',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Gestiona tus Exámenes a Título de Suficiencia de forma fácil y sin complicaciones',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        AppPrimaryButton(
                          label: 'Comenzar',
                          width: buttonWidth,
                          onPressed: () => print('Comenzar pressed'),
                        ),
                        AppSecondaryButton(
                          label: 'Soy personal de Gestión',
                          width: buttonWidth,
                          onPressed: () =>
                              print('Soy personal de Gestión pressed'),
                        ),
                      ],
                    ),
                  ),
                  // ─── Avatar flotante del IPN ─────────────────────────────────────────────
                  Positioned(
                    top: -avatarRadius,
                    child: CircleAvatar(
                      radius: avatarRadius,
                      backgroundColor: AppColors.primaryLightCherry,
                      child: const Text(
                        'IPN',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryCherry,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
