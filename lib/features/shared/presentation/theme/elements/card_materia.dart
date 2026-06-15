// ============================================================
// NOMBRE: card_materia.dart
// USO: Tarjeta compacta para mostrar un examen ETS en la lista
//      del dashboard. Incluye barra lateral de color según estado
//      cronológico. Consumida por DashboardMaterias y
//      ExploreMateriasSelection.
// ============================================================
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/app_colors.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/app_buttons.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/card_materia_expanded.dart';

class CardExamenMateria extends StatelessWidget {
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
  final Color? barColor;
  final VoidCallback? onTap;

  const CardExamenMateria({
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
    this.barColor,
    this.onTap,
  });

  Color get _barColor => barColor ?? switch (status) {
    EtsStatus.today    => AppColors.statusTodayForeground,
    EtsStatus.tomorrow => AppColors.statusTomorrowForeground,
    EtsStatus.soon     => AppColors.statusSoonForeground,
    EtsStatus.far      => AppColors.statusFarForeground,
  };

  Color get _badgeBackground => switch (status) {
    EtsStatus.today    => AppColors.statusTodayBackground,
    EtsStatus.tomorrow => AppColors.statusTomorrowBackground,
    EtsStatus.soon     => AppColors.statusSoonBackground,
    EtsStatus.far      => AppColors.statusFarBackground,
  };

  String get _statusLabel => switch (status) {
    EtsStatus.today   => 'Hoy',
    EtsStatus.tomorrow  => 'Mañana',
    EtsStatus.soon => 'Próximamente',
    EtsStatus.far => 'Lejano',
  };

  @override
  Widget build(BuildContext context) {
    return AppAnimatedPress(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
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
                  width: 5,
                  decoration: BoxDecoration(
                    color: _barColor,
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
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
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
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: _barColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // ─── Profesor ────────────────────────────────────
                        Text(
                          profesor,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // ─── Fecha · hora · salón · semestre ────────────
                        Wrap(
                          spacing: 12,
                          runSpacing: 4,
                          children: [
                            _MetaChip(icon: Icons.calendar_today_outlined, label: fecha),
                            _MetaChip(icon: Icons.access_time_outlined, label: hora),
                            _MetaChip(icon: Icons.meeting_room_outlined, label: 'Salón $salon'),
                            _MetaChip(icon: Icons.school_outlined, label: 'Semestre $semestre'),
                          ],
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

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
      ],
    );
  }
}
