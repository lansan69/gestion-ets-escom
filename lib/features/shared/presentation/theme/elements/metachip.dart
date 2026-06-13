// ============================================================
// NOMBRE: metachip.dart
// USO: Widget pequeño de icono + texto para mostrar metadatos
//      de un examen (fecha, salón, hora, profesor). Consumido
//      por CardExamenMateriaExpanded.
// ============================================================
import 'package:flutter/material.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/app_colors.dart';

class MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final double fontSize;
  final double iconSize;
  final Color iconColor;
  final Color textColor;

  const MetaChip({
    required this.icon,
    required this.label,
    this.fontSize = 13,
    this.iconSize = 13,
    this.iconColor = AppColors.textMuted,
    this.textColor = AppColors.textMuted,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: iconSize, color: iconColor),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: fontSize, color: textColor),
        ),
      ],
    );
  }
}
