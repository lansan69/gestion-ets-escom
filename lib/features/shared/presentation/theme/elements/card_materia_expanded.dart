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
  final String salon;
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
                // ─── Barra de color lateral ──────────────────────────
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
                // ─── Contenido principal ─────────────────────────────
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ─── Nombre + badge ──────────────────────────
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
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),

                        // ─── Fecha + Salón ───────────────────────────
                        Row(
                          children: [
                            MetaChip(
                              icon: Icons.calendar_today_outlined,
                              label: fecha,
                              fontSize: 15,
                              iconSize: 18,
                            ),
                            const SizedBox(width: 30),
                            MetaChip(
                              icon: Icons.meeting_room_outlined,
                              label: 'Salón $salon',
                              fontSize: 15,
                              iconSize: 18,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1),

                        // ─── Horario ─────────────────────────────────
                        _InfoRow(
                          icon: Icons.access_time_outlined,
                          label: 'Horario: $hora AM',
                        ),
                        const Divider(height: 1),

                        // ─── Coordinador ─────────────────────────────
                        _InfoRow(
                          icon: Icons.person_outline,
                          label: 'Coordinador: $profesor',
                        ),
                        const Divider(height: 1),

                        // ─── Correo ───────────────────────────────────
                        _InfoRow(
                          icon: Icons.email_outlined,
                          label: 'profesor@ipn.mx',
                          trailingIcon: Icons.copy,
                          onTrailingTap: () {
                            // TODO: copiar al portapapeles
                          },
                        ),
                        const Divider(height: 1),

                        // ─── Guía PDF ─────────────────────────────────
                        _InfoRow(
                          icon: Icons.description_outlined,
                          label: documentoGuia != null
                              ? documentoGuia!.path.split('/').last
                              : 'Sin guía',
                          trailingIcon: documentoGuia != null
                              ? Icons.download
                              : null,
                        ),
                        const Divider(height: 1),

                        // ─── Proyecto PDF ─────────────────────────────
                        _InfoRow(
                          icon: Icons.insert_drive_file_outlined,
                          label: documentoProyecto != null
                              ? documentoProyecto!.path.split('/').last
                              : 'Sin proyecto',
                          trailingIcon: documentoProyecto != null
                              ? Icons.download
                              : null,
                        ),
                        const Divider(height: 1),

                        // ─── Notas ────────────────────────────────────
                        _InfoRow(
                          icon: Icons.note_outlined,
                          label: notas.isNotEmpty ? notas : 'Sin notas',
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

// ─── Widget auxiliar para filas de información ───────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final IconData? trailingIcon;
  final VoidCallback? onTrailingTap;

  const _InfoRow({
    required this.icon,
    required this.label,
    this.trailingIcon,
    this.onTrailingTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textMuted),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (trailingIcon != null)
            GestureDetector(
              onTap: onTrailingTap,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryDarkBlue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  trailingIcon,
                  size: 16,
                  color: AppColors.primaryDarkBlue,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
