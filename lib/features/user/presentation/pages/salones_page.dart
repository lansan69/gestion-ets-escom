import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_ets_escom/features/shared/presentation/elements/croquis_widget.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/app_colors.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/app_text_styles.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/app_search_bar.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/background_pattern_painter.dart';

class SalonesPage extends ConsumerStatefulWidget {
  const SalonesPage({super.key});

  @override
  ConsumerState<SalonesPage> createState() => _SalonesPageState();
}

class _SalonesPageState extends ConsumerState<SalonesPage> {
  final _searchController = TextEditingController();
  String? _searchedSalon;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topOffset = MediaQuery.of(context).padding.top + 10;

    return Container(
      height: double.infinity,
      width: double.infinity,
      color: AppColors.primaryDarkBlue,
      child: Stack(
        children: [
          CustomPaint(size: Size.infinite, painter: BackgroundPatternPainter()),
          Positioned(
            top: topOffset,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.backgroundWhite,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: CustomScrollView(
                slivers: [
                  // ── Encabezado + barra de búsqueda ───────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Mapa de ESCOM', style: AppTextStyles.headingLarge),
                          const SizedBox(height: 4),
                          Text(
                            'Toca un edificio o busca un salón',
                            style: AppTextStyles.bodySecondary,
                          ),
                          const SizedBox(height: 12),
                          AppSearchBar(
                            controller: _searchController,
                            hint: 'Buscar salón (ej. 1001)...',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(4),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _searchedSalon = value.length == 4 ? value : null;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  // ── Mapa (sliver propio → ancho completo) ─────────
                  SliverToBoxAdapter(
                    child: CrquisWidget(autoSelectSalon: _searchedSalon),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
