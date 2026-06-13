// ============================================================
// NOMBRE: app_buttons.dart
// USO: Botones reutilizables de la aplicación (primario,
//      secundario, icono-tile y animación de presión). Consumidos
//      por todas las pantallas de la app.
// ============================================================
import 'package:flutter/material.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/app_colors.dart';

class AppPrimaryButton extends StatelessWidget {
  final String label;
  final Widget? child;
  final VoidCallback? onPressed;
  final double? width;
  final Color backgroundColor;

  const AppPrimaryButton({
    super.key,
    this.label = '',
    this.child,
    this.onPressed,
    this.width,
    this.backgroundColor = AppColors.primaryDarkBlue,
  });

  @override
  Widget build(BuildContext context) {
    return AppAnimatedPress(
      child: SizedBox(
        width: width,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: AppColors.backgroundWhite,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: child ?? Text(label),
        ),
      ),
    );
  }
}

class AppSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final double? width;

  const AppSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return AppAnimatedPress(
      child: SizedBox(
        width: width,
        child: TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(label),
        ),
      ),
    );
  }
}

class AppIconTileButton extends StatelessWidget {
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String label;
  final VoidCallback? onPressed;
  final double? width;

  const AppIconTileButton({
    super.key,
    required this.icon,
    required this.iconBackground,
    required this.label,
    this.iconColor = Colors.white,
    this.onPressed,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return AppAnimatedPress(
      child: SizedBox(
        width: width,
        child: Material(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: iconBackground,
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(11),
                      ),
                    ),
                    child: Icon(icon, color: iconColor, size: 26),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AppAnimatedPress extends StatefulWidget {
  final Widget child;
  const AppAnimatedPress({super.key, required this.child});

  @override
  State<AppAnimatedPress> createState() => _AppAnimatedPressState();
}

class _AppAnimatedPressState extends State<AppAnimatedPress> {
  bool _pressed = false;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Listener(
        onPointerDown: (_) => setState(() => _pressed = true),
        onPointerUp: (_) => setState(() => _pressed = false),
        onPointerCancel: (_) => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.96 : (_hovered ? 1.02 : 1.0),
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}
