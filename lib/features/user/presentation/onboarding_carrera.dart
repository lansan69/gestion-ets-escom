import 'package:dartz/dartz.dart' show Either;
import 'package:flutter/material.dart';
import 'package:gestion_ets_escom/core/errors/failures.dart';
import 'package:gestion_ets_escom/features/shared/data/datasources/shared_remote_datasource_impl.dart';
import 'package:gestion_ets_escom/features/shared/data/repositories/shared_repository_impl.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/carrera.dart';
import 'package:gestion_ets_escom/features/shared/domain/usecases/catalogs/get_carreras.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/selectable_career_card.dart';
import 'package:go_router/go_router.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/app_colors.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/app_buttons.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/background_pattern_painter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OnBoardingCarrera extends StatefulWidget {
  const OnBoardingCarrera({super.key});

  @override
  State<OnBoardingCarrera> createState() => _OnBoardingCarreraState();
}

const List<Color> _carreraColors = [
  AppColors.primaryDarkBlue,
  AppColors.statusComingSoonForeground,
  AppColors.primaryCherry,
  AppColors.statusAvailableForeground,
];

class _OnBoardingCarreraState extends State<OnBoardingCarrera> {
  String selectedCarrera = "none";
  late Future<Either<Failure, List<Carrera>>> _futureCarreras;

  @override
  @override
  void initState() {
    super.initState();
    final repository = SharedRepositoryImpl(
      datasource: SharedRemoteDatasourceImpl(
        supabaseClient: Supabase.instance.client,
      ),
    );
    final getCarrerasUseCase = GetCarreras(repository);
    _futureCarreras = getCarrerasUseCase.call();
  }

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
              height: MediaQuery.of(context).size.height * 0.08,
              color: AppColors.primaryDarkBlue,
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  // ─── Fondo decorativo ─────────────────────────────────────────────────────
                  CustomPaint(
                    size: Size.infinite,
                    painter: BackgroundPatternPainter(),
                  ),
                  // ─── Texto del encabezado ─────────────────────────────────────────────────
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
                padding: EdgeInsets.only(
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
                        // Full width rectangle
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
                    SizedBox(height: 5),
                    Text(
                      'Paso 1 de 2',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 30),

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
                    SizedBox(height: 20),

                    FutureBuilder<Either<Failure, List<Carrera>>>(
                      future: _futureCarreras,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (!snapshot.hasData) {
                          return const Center(
                            child: Text('Error al cargar carreras'),
                          );
                        }
                        return snapshot.data!.fold(
                          (_) => const Center(
                            child: Text('Error al cargar carreras'),
                          ),
                          (carreras) => Column(
                            children: [
                              for (int i = 0; i < carreras.length; i++) ...[
                                SelectableCareerCard(
                                  abreviatura: carreras[i].abreviatura,
                                  nombre: carreras[i].nombre,
                                  colorBarra:
                                      _carreraColors[i % _carreraColors.length],
                                  isSelected: selectedCarrera == carreras[i].id,
                                  onToggle: (_, seleccionado) => setState(
                                    () => selectedCarrera = seleccionado
                                        ? carreras[i].id
                                        : "none",
                                  ),
                                  canSelect: () => true,
                                ),
                                if (i < carreras.length - 1)
                                  const SizedBox(height: 20),
                              ],
                            ],
                          ),
                        );
                      },
                    ),

                    const Spacer(),
                    AppPrimaryButton(
                      label: 'Continuar',
                      width: buttonWidth,
                      onPressed: () => context.go('/onboarding/semestre'),
                    ),
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
