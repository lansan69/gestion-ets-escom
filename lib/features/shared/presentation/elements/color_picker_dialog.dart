import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/app_colors.dart';

const _kColors = [
  ('#1A3A8F', 'Navy'),
  ('#6D1130', 'Cherry'),
  ('#F9A825', 'Amber'),
  ('#C62828', 'Rojo'),
  ('#4CAF50', 'Verde'),
];

/// Muestra el diálogo de selección de color y devuelve el hex elegido,
/// o null si el usuario cancela.
Future<String?> showColorPickerDialog(
  BuildContext context, {
  String? defaultColor,
}) {
  return showDialog<String>(
    context: context,
    barrierDismissible: true,
    builder: (_) => _ColorPickerDialog(defaultColor: defaultColor),
  );
}

class _ColorPickerDialog extends StatefulWidget {
  const _ColorPickerDialog({this.defaultColor});
  final String? defaultColor;

  @override
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<_ColorPickerDialog> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    // Pre-select the exam's area color if it matches one of the options.
    final match = _kColors.any((c) =>
        c.$1.toLowerCase() == (widget.defaultColor ?? '').toLowerCase());
    _selected = match
        ? widget.defaultColor!.toUpperCase().replaceAll('#', '#')
        : _kColors.first.$1;
    // Normalize to uppercase with #
    _selected = _kColors
        .firstWhere(
          (c) => c.$1.toLowerCase() == _selected.toLowerCase(),
          orElse: () => _kColors.first,
        )
        .$1;
  }

  Color _fromHex(String hex) {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDarkBlue.withValues(alpha: 0.18),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header navy ─────────────────────────────────────
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.primaryDarkBlue,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 20, 12, 20),
                child: Row(
                  children: [
                    const Icon(Icons.palette_outlined, color: Colors.white70, size: 20),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Elige un color para este examen',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // ── Color circles ───────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _kColors.map((entry) {
                    final hex = entry.$1;
                    final isSelected = hex == _selected;
                    final color = _fromHex(hex);
                    return GestureDetector(
                      onTap: () => setState(() => _selected = hex),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 3)
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.5),
                              blurRadius: isSelected ? 10 : 4,
                              spreadRadius: isSelected ? 2 : 0,
                            ),
                          ],
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white, size: 20)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ),
              // ── Buttons ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryDarkBlue,
                          side: const BorderSide(color: AppColors.primaryDarkBlue),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primaryDarkBlue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context, _selected),
                        child: const Text('Guardar'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
