// ============================================================
// NOMBRE: pdf_chip.dart
// USO: Widget que muestra el nombre de un archivo PDF con icono
//      de descarga. Si no hay archivo, no renderiza nada.
//      Consumido por CardExamenMateriaExpanded.
// ============================================================
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/app_colors.dart';

class PdfFileChip extends StatelessWidget {
  final File? file;

  const PdfFileChip({this.file});

  @override
  Widget build(BuildContext context) {
    if (file == null) {
      return const Text(
        '',
        style: TextStyle(fontSize: 14, color: AppColors.textMuted),
      );
    }

    final fileName = file!.path.split(RegExp(r'[/\\]')).last;

    return GestureDetector(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.download_outlined,
            size: 16,
            color: AppColors.textPrimary,
          ),
          const SizedBox(width: 4),
          Text(
            fileName,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }
}
