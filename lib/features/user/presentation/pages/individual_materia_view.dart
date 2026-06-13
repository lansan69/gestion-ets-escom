// ============================================================
// NOMBRE: individual_materia_view.dart
// USO: Vista de detalle de un examen ETS. Recibe los datos
//      a través de GoRouter extra (MateriaData) y muestra la
//      tarjeta expandida con acciones de calendario y recordatorio.
//      Ruta: /materia.
// ============================================================
import 'package:flutter/material.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/app_colors.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/app_buttons.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/background_pattern_painter.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/card_materia_expanded.dart';
import 'package:go_router/go_router.dart';

class MateriaData {
  final String nombre;
  final String profesor;
  final int semestre;
  final int salon;
  final String fecha;
  final String hora;
  final String turno;
  final EtsStatus status;
  final Color barColor;

  const MateriaData({
    required this.nombre,
    required this.profesor,
    required this.semestre,
    required this.salon,
    required this.fecha,
    required this.hora,
    required this.turno,
    required this.status,
    required this.barColor,
  });
}

class IndividualMateriaView extends StatelessWidget {
  const IndividualMateriaView({super.key, required this.data});

  final MateriaData data;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top; // status bar height
    final topOffset = topPadding + MediaQuery.of(context).size.height * 0.08;

    return Scaffold(
      backgroundColor: data.barColor,
      body: Stack(
        children: [
          // Background pattern covers the full screen
          CustomPaint(size: Size.infinite, painter: BackgroundPatternPainter()),

          // White card content area
          Positioned(
            top: topOffset,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.backgroundWhite,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 32),
                child: Column(
                  children: [
                    CardExamenMateriaExpanded(
                      barColor: data.barColor,
                      nombreMateria: data.nombre,
                      profesor: data.profesor,
                      semestre: data.semestre,
                      salon: data.salon,
                      fecha: data.fecha,
                      hora: data.hora,
                      turno: data.turno,
                      status: data.status,
                    ),
                    const SizedBox(height: 40),
                    AppIconTileButton(
                      width: MediaQuery.of(context).size.width * 0.8,
                      icon: Icons.calendar_month,
                      iconBackground: data.barColor,
                      label: 'Agregar a mi calendario',
                      onPressed: () {},
                    ),
                    const SizedBox(height: 20),
                    AppIconTileButton(
                      width: MediaQuery.of(context).size.width * 0.8,
                      icon: Icons.notification_add,
                      iconBackground: data.barColor,
                      label: 'Agendar recordatorio',
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Back button floating over the colored header area
          Positioned(
            top: topPadding + 8,
            left: 8,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
          ),
        ],
      ),
    );
  }
}
