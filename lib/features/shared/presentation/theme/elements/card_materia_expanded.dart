// ============================================================
// NOMBRE: card_materia_expanded.dart
// USO: Tarjeta expandida con todos los detalles de un examen
//      ETS (horario, salón, profesor, documentos, notas).
//      Consumida por IndividualMateriaView.
// ============================================================
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/app_colors.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/app_buttons.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/metachip.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/pdf_chip.dart';

enum EtsStatus { today, tomorrow, soon, far }

class CardExamenMateriaExpanded extends StatelessWidget {
  final String nombreMateria;
  final String profesor;
  final int semestre;
  final int salon;
  final String fecha;
  final String hora;
  final String turno;
  final File? documentoGuia;
  final File? documentoProyecto;
  final String notas;
  final EtsStatus status;
  final VoidCallback? onTap;
  final Color barColor;

  const CardExamenMateriaExpanded({
    super.key,
    required this.nombreMateria,
    required this.profesor,
    required this.semestre,
    required this.salon,
    required this.fecha,
    required this.hora,
    required this.turno,
    this.documentoGuia,
    this.documentoProyecto,
    this.notas = '',
    required this.status,
    this.onTap,
    this.barColor = AppColors.buttonPrimaryBackground,
  });

  Color get _badgeBackground => switch (status) {
    EtsStatus.today => AppColors.statusTodayBackground,
    EtsStatus.tomorrow => AppColors.statusTomorrowBackground,
    EtsStatus.soon => AppColors.statusSoonBackground,
    EtsStatus.far => AppColors.statusFarBackground,
  };

  String get _statusLabel => switch (status) {
    EtsStatus.today => 'Hoy',
    EtsStatus.tomorrow => 'Mañana',
    EtsStatus.soon => 'Próximamente',
    EtsStatus.far => 'Lejano',
  };

  @override
  Widget build(BuildContext context) {
    return AppAnimatedPress(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(left: 30, right: 30, top: 16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 10,
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      bottomLeft: Radius.circular(6),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ─── Nombre + badge ──────────────────────────────
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                nombreMateria,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: barColor,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: _badgeBackground,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _statusLabel,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // ─── Date and classroom ──────────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            MetaChip(
                              icon: Icons.calendar_today_outlined,
                              label: fecha,
                              fontSize: 18,
                              iconSize: 18,
                            ),
                            SizedBox(width: 30),
                            MetaChip(
                              icon: Icons.meeting_room_outlined,
                              label: 'Salón $salon',
                              fontSize: 18,
                              iconSize: 18,
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        // ─── Horario ────────────────────────────────────
                        MetaChip(
                          icon: Icons.access_time_outlined,
                          label: 'Horario: ${hora} AM',
                          fontSize: 18,
                          iconSize: 18,
                        ),
                        const SizedBox(height: 2),

                        // ─── Profesor ────────────────────────────────────
                        MetaChip(
                          icon: Icons.person,
                          label: 'Coordinador: ${profesor}',
                          fontSize: 18,
                          iconSize: 18,
                        ),
                        const SizedBox(height: 2),

                        MetaChip(
                          icon: Icons.email,
                          label: 'Correo: profesor@gmail.com',
                          fontSize: 18,
                          iconSize: 18,
                        ),
                        const SizedBox(height: 2),

                        Row(
                          children: [
                            MetaChip(
                              icon: Icons.picture_as_pdf,
                              label: 'Guía: ',
                              fontSize: 18,
                              iconSize: 18,
                            ),
                            const SizedBox(width: 8),
                            PdfFileChip(file: documentoGuia),
                          ],
                        ),
                        const SizedBox(height: 2),

                        Row(
                          children: [
                            MetaChip(
                              icon: Icons.picture_as_pdf,
                              label: 'Proyecto: ',
                              fontSize: 18,
                              iconSize: 18,
                            ),
                            const SizedBox(width: 8),
                            PdfFileChip(file: documentoGuia),
                          ],
                        ),
                        const SizedBox(height: 2),

                        MetaChip(
                          icon: Icons.note,
                          label: 'Notas : ',
                          fontSize: 18,
                          iconSize: 18,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 22, right: 22),
                            child: Text(
                              "Asegurense de acudir de manera presencial al cubículo del profesor antes del examen",
                              textAlign: TextAlign.justify,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
