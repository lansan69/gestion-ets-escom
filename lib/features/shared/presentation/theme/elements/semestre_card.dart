import 'package:flutter/material.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/app_colors.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/app_buttons.dart';

class SemestreCard extends StatefulWidget {
  final int numeroSemestre;
  final bool isSelected;
  final void Function(int numero, bool isSelected)? onToggle;
  final bool Function()? canSelect;

  const SemestreCard({
    super.key,
    required this.numeroSemestre,
    this.isSelected = false,
    this.onToggle,
    this.canSelect,
  });

  @override
  State<SemestreCard> createState() => SemestreCardState();
}

class SemestreCardState extends State<SemestreCard> {
  late bool _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.isSelected;
  }

  @override
  void didUpdateWidget(SemestreCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSelected != widget.isSelected) {
      _selected = widget.isSelected;
    }
  }

  void setColorBarra(Color? color) {
    setState(() => _selected = color != null);
  }

  void _toggle() {
    if (!_selected && (widget.canSelect?.call() == false)) return;
    setState(() => _selected = !_selected);
    widget.onToggle?.call(widget.numeroSemestre, _selected);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: AppAnimatedPress(
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_selected)
                  Container(
                    width: 5,
                    decoration: const BoxDecoration(
                      color: AppColors.statusComingSoonForeground,
                      borderRadius: BorderRadius.only(
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
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '${widget.numeroSemestre}',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: _selected
                                ? AppColors.primaryDarkBlue
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Sem.",
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColors.textSecondary,
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
