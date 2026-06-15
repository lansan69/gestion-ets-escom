// ============================================================
// NOMBRE: app_search_bar.dart
// USO: Barra de búsqueda con botón de filtro animado.
//      Consumida por DashboardMaterias, ExploreMateriasCarrera,
//      ExploreSemestres y ExploreMateriasSelection.
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/app_colors.dart';

class AppSearchBar extends StatefulWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String hint;
  final VoidCallback? onSearchTap;
  final VoidCallback? onFilterTap;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;

  const AppSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.hint = 'Buscar materia...',
    this.onSearchTap,
    this.onFilterTap,
    this.inputFormatters,
    this.keyboardType,
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _filterCtrl;
  late final Animation<double> _filterScale;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _filterCtrl = _makeCtrl();
    _filterScale = _makeScale(_filterCtrl);
    widget.controller?.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = (widget.controller?.text.isNotEmpty) ?? false;
    if (hasText != _hasText) setState(() => _hasText = hasText);
  }

  AnimationController _makeCtrl() => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 100),
      );

  Animation<double> _makeScale(AnimationController ctrl) =>
      Tween<double>(begin: 1.0, end: 0.85).animate(
        CurvedAnimation(parent: ctrl, curve: Curves.easeInOut),
      );

  @override
  void dispose() {
    widget.controller?.removeListener(_onTextChanged);
    _filterCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: widget.controller,
            onChanged: widget.onChanged,
            inputFormatters: widget.inputFormatters,
            keyboardType: widget.keyboardType,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: const TextStyle(
                color: AppColors.textHint,
                fontSize: 14,
              ),
              prefixIcon: const Icon(Icons.search, color: AppColors.textHint),
              suffixIcon: _hasText
                  ? IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      color: AppColors.textHint,
                      onPressed: () {
                        widget.controller?.clear();
                        widget.onChanged?.call('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.searchBarBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: AppColors.searchBarBorderFocused,
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        if (widget.onFilterTap != null) ...[
          const SizedBox(width: 10),
          _PressButton(
            controller: _filterCtrl,
            scale: _filterScale,
            icon: Icons.tune,
            onTap: widget.onFilterTap,
          ),
        ],
      ],
    );
  }
}

class _PressButton extends StatelessWidget {
  final AnimationController controller;
  final Animation<double> scale;
  final IconData icon;
  final VoidCallback? onTap;

  const _PressButton({
    required this.controller,
    required this.scale,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => controller.forward(),
      onTapUp: (_) {
        controller.reverse();
        onTap?.call();
      },
      onTapCancel: () => controller.reverse(),
      child: ScaleTransition(
        scale: scale,
        child: Material(
          color: AppColors.primaryDarkBlue,
          shape: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(icon, color: AppColors.buttonPrimaryText, size: 20),
          ),
        ),
      ),
    );
  }
}
