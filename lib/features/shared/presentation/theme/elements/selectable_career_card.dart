import 'package:flutter/material.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/app_colors.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/app_buttons.dart';

class SelectableCareerCard extends StatefulWidget {
  final String abreviatura;
  final String nombre;
  final Color colorBarra;
  final bool isSelected;
  final void Function(String abrev, bool isSelected)? onToggle;
  final bool Function()? canSelect;

  const SelectableCareerCard({
    super.key,
    required this.abreviatura,
    required this.nombre,
    required this.colorBarra,
    this.isSelected = false,
    this.onToggle,
    this.canSelect,
  });

  @override
  State<SelectableCareerCard> createState() => _SelectableCareerCardState();
}

class _SelectableCareerCardState extends State<SelectableCareerCard> {
  late bool _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.isSelected;
  }

  @override
  void didUpdateWidget(SelectableCareerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSelected != widget.isSelected) {
      _selected = widget.isSelected;
    }
  }

  void _toggle() {
    if (!_selected && (widget.canSelect?.call() == false)) return;
    setState(() => _selected = !_selected);
    widget.onToggle?.call(widget.abreviatura, _selected);
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
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 5,
                  decoration: BoxDecoration(
                    color: _selected ? widget.colorBarra : Colors.grey.shade300,
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
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.abreviatura,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _selected
                                ? widget.colorBarra
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.nombre,
                          style: const TextStyle(
                            fontSize: 13,
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
