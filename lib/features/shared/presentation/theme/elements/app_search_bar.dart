// ============================================================
// NOMBRE: app_search_bar.dart
// USO: Barra de búsqueda con botones de búsqueda y filtro
//      animados. Consumida por DashboardMaterias,
//      ExploreMateriasCarrera, ExploreSemestres y
//      ExploreMateriasSelection.
// ============================================================
import 'package:flutter/material.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/app_colors.dart';

class AppSearchBar extends StatefulWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String hint;
  final VoidCallback? onSearchTap;
  final VoidCallback? onFilterTap;

  const AppSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.hint = 'Buscar materia...',
    this.onSearchTap,
    this.onFilterTap,
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar>
    with TickerProviderStateMixin {
  late final AnimationController _searchCtrl;
  late final AnimationController _filterCtrl;
  late final Animation<double> _searchScale;
  late final Animation<double> _filterScale;

  @override
  void initState() {
    super.initState();
    _searchCtrl = _makeCtrl();
    _filterCtrl = _makeCtrl();
    _searchScale = _makeScale(_searchCtrl);
    _filterScale = _makeScale(_filterCtrl);
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
    _searchCtrl.dispose();
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
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: const TextStyle(
                color: AppColors.textHint,
                fontSize: 14,
              ),
              prefixIcon: const Icon(Icons.search, color: AppColors.textHint),
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
        const SizedBox(width: 10),
        _PressButton(
          controller: _searchCtrl,
          scale: _searchScale,
          icon: Icons.search,
          onTap: widget.onSearchTap,
        ),
        const SizedBox(width: 8),
        _PressButton(
          controller: _filterCtrl,
          scale: _filterScale,
          icon: Icons.tune,
          onTap: widget.onFilterTap,
        ),
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
