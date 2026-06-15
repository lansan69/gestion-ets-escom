// ============================================================
// NOMBRE: croquis_widget.dart
// USO: Widget interactivo del croquis del campus ESCOM.
//      Parsea los <rect> de cada <g id="edificioN"> del SVG en
//      tiempo de ejecución para que cualquier cambio en el archivo
//      se refleje automáticamente. Resalta el edificio tocado en
//      dorado y muestra los salones por piso debajo del mapa.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/building_info.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/app_colors.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/app_text_styles.dart';

// ─── Dimensiones del viewBox del SVG ─────────────────────────────────────────

const double _svgW = 696;
const double _svgH = 405;

// ─── Regiones táctiles (coordenadas SVG hardcodeadas del croquis final) ──────

final List<BuildingRegion> _kRegions = [
  BuildingRegion(
    id: 'edificio1',
    number: 1,
    bounds: Rect.fromLTWH(112.5, 306.5, 213, 97),
  ),
  BuildingRegion(
    id: 'edificio2',
    number: 2,
    bounds: Rect.fromLTWH(112.5, 1.5, 213, 97),
  ),
  BuildingRegion(
    id: 'edificio3',
    number: 3,
    bounds: Rect.fromLTWH(378.5, 306.5, 213, 97),
  ),
  BuildingRegion(
    id: 'edificio4',
    number: 4,
    bounds: Rect.fromLTWH(378.5, 1.5, 213, 97),
  ),
  BuildingRegion(
    id: 'edificio5',
    number: 5,
    bounds: Rect.fromLTWH(465.5, 141.5, 227, 117),
  ),
];

// ─── Metadatos de edificios ───────────────────────────────────────────────────

const Map<int, BuildingInfo> _kBuildingData = {
  1: BuildingInfo(floors: [0, 1, 2], label: 'Edificio 1'),
  2: BuildingInfo(floors: [0, 1, 2], label: 'Edificio 2'),
  3: BuildingInfo(floors: [0, 1, 2], label: 'Edificio 3'),
  4: BuildingInfo(floors: [0, 1, 2], label: 'Edificio 4'),
  5: BuildingInfo(floors: [0, 1, 2], label: 'Edificio 5 (bloques 3 y 4)'),
};

// ─── Salones por edificio y piso ─────────────────────────────────────────────

const Map<int, Map<int, List<String>>> _kRooms = {
  1: {
    0: ['1001', '1002', '1003', '1004', '1005', '1006', '1007'],
    1: ['1101', '1102', '1103', '1104', '1105', '1106', '1107'],
    2: ['1201', '1202', '1203', '1204', '1205', '1206', '1207'],
  },
  2: {
    0: ['2001', '2002', '2003', '2004', '2005', '2006', '2007'],
    1: ['2101', '2102', '2103', '2104', '2105', '2106', '2107'],
    2: ['2201', '2202', '2203', '2204', '2205', '2206', '2207'],
  },
  3: {
    0: ['1008', '1009', '1010', '1011', '1012', '1013', '1014'],
    1: ['1108', '1109', '1110', '1111', '1112', '1113', '1114'],
    2: ['1208', '1209', '1210', '1211', '1212', '1213', '1214'],
  },
  4: {
    0: ['2008', '2009', '2010', '2011', '2012'],
    1: ['2108', '2109', '2110', '2111', '2112', '2113'],
    2: ['2208', '2209', '2210', '2211', '2212', '2213'],
  },
  5: {
    0: [
      '3008',
      '3009',
      '3010',
      '3011',
      '3012',
      '3013',
      '4008',
      '4009',
      '4010',
      '4011',
      '4012',
      '4013',
    ],
    1: [
      '3108',
      '3109',
      '3110',
      '3111',
      '3112',
      '3113',
      '4108',
      '4109',
      '4110',
      '4111',
      '4112',
      '4113',
    ],
    2: [
      '3208',
      '3209',
      '3210',
      '3211',
      '3212',
      '3213',
      '4208',
      '4209',
      '4210',
      '4211',
      '4212',
      '4213',
    ],
  },
};

// ─── Widget principal ─────────────────────────────────────────────────────────

class CrquisWidget extends StatefulWidget {
  /// Código de salón a resaltar en dorado (p.ej. desde la vista de un examen).
  final String? highlightedSalon;

  /// Callback opcional cuando el usuario toca un chip de salón.
  final void Function(String etiqueta)? onRoomSelected;

  /// Código de salón buscado desde la barra de búsqueda de la pantalla de salones.
  /// Cuando se establece, selecciona automáticamente el edificio y piso que contienen el salón.
  final String? autoSelectSalon;

  const CrquisWidget({
    super.key,
    this.highlightedSalon,
    this.onRoomSelected,
    this.autoSelectSalon,
  });

  @override
  State<CrquisWidget> createState() => _CrquisWidgetState();
}

class _CrquisWidgetState extends State<CrquisWidget> {
  BuildingRegion? _selected;
  int _selectedFloor = 0;

  // Escala SVG→widget actualizada en LayoutBuilder; solo usada en gestures.
  double _scaleX = 1.0;
  double _scaleY = 1.0;

  @override
  void didUpdateWidget(CrquisWidget old) {
    super.didUpdateWidget(old);
    if (widget.autoSelectSalon != old.autoSelectSalon) {
      _applyAutoSelect(widget.autoSelectSalon);
    }
  }

  void _applyAutoSelect(String? salon) {
    if (salon == null) {
      setState(() => _selected = null);
      return;
    }
    for (final buildingEntry in _kRooms.entries) {
      for (final floorEntry in buildingEntry.value.entries) {
        if (floorEntry.value.contains(salon)) {
          final region = _kRegions.firstWhere(
            (r) => r.number == buildingEntry.key,
          );
          setState(() {
            _selected = region;
            _selectedFloor = floorEntry.key;
          });
          return;
        }
      }
    }
    setState(() => _selected = null);
  }

  void _onTapUp(TapUpDetails details) {
    final tap = Offset(
      details.localPosition.dx / _scaleX,
      details.localPosition.dy / _scaleY,
    );

    for (final region in _kRegions) {
      if (region.path.contains(tap)) {
        setState(() {
          if (_selected?.id == region.id) {
            _selected = null;
          } else {
            _selected = region;
            _selectedFloor = 0;
          }
        });
        return;
      }
    }
    setState(() => _selected = null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMap(),
        const SizedBox(height: 10),
        if (_selected != null) _buildDetail(_selected!),
      ],
    );
  }

  // ── Mapa ──────────────────────────────────────────────────────────────────

  Widget _buildMap() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: AspectRatio(
        aspectRatio: _svgW / _svgH,
        child: GestureDetector(
          onTapUp: _onTapUp,
          child: LayoutBuilder(
            builder: (context, constraints) {
              _scaleX = constraints.maxWidth / _svgW;
              _scaleY = constraints.maxHeight / _svgH;
              return Stack(
                fit: StackFit.expand,
                children: [
                  SvgPicture.asset(
                    'assets/images/croquis.svg',
                    fit: BoxFit.fill,
                  ),
                  CustomPaint(
                    painter: _HighlightPainter(
                      selected: _selected,
                      scaleX: _scaleX,
                      scaleY: _scaleY,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ── Detalle del edificio seleccionado ─────────────────────────────────────

  Widget _buildDetail(BuildingRegion region) {
    final info = _kBuildingData[region.number]!;
    final rooms = _kRooms[region.number]?[_selectedFloor] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Encabezado navy
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          color: AppColors.primaryDarkBlue,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  info.label,
                  style: AppTextStyles.sectionTitle.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                '${info.floors.length} pisos',
                style: AppTextStyles.caption.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Pills de piso
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: info.floors.map((f) {
              final active = f == _selectedFloor;
              final label = f == 0 ? 'PB' : 'P$f';
              return GestureDetector(
                onTap: () => setState(() => _selectedFloor = f),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: active
                        ? AppColors.primaryDarkBlue
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primaryDarkBlue),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: active ? Colors.white : AppColors.primaryDarkBlue,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        // Grid de salones
        if (region.number == 5)
          _buildEdificio5Rooms(rooms)
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildRoomWrap(rooms),
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  // Chips del bloque 3 arriba y bloque 4 abajo, cada uno en su propio Wrap.
  Widget _buildEdificio5Rooms(List<String> rooms) {
    final bloque3 = rooms.where((c) => c.startsWith('3')).toList();
    final bloque4 = rooms.where((c) => c.startsWith('4')).toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bloque 3', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600, color: AppColors.primaryDarkBlue)),
          const SizedBox(height: 6),
          _buildRoomWrap(bloque3),
          const SizedBox(height: 12),
          Text('Bloque 4', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600, color: AppColors.primaryDarkBlue)),
          const SizedBox(height: 6),
          _buildRoomWrap(bloque4),
        ],
      ),
    );
  }

  Widget _buildRoomWrap(List<String> codes) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: codes.map((code) {
        final isHighlighted = code == widget.highlightedSalon;
        return GestureDetector(
          onTap: () => widget.onRoomSelected?.call(code),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isHighlighted ? const Color(0xFFFFCC00) : AppColors.semesterChipUnselectedBackground,
              borderRadius: BorderRadius.circular(8),
              border: isHighlighted
                  ? null
                  : Border.all(color: AppColors.primaryDarkBlue.withValues(alpha: 0.2)),
            ),
            child: Text(
              code,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primaryDarkBlue),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Painter del resaltado ────────────────────────────────────────────────────

class _HighlightPainter extends CustomPainter {
  final BuildingRegion? selected;
  final double scaleX;
  final double scaleY;

  const _HighlightPainter({
    required this.selected,
    required this.scaleX,
    required this.scaleY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (selected == null) return;
    final b = selected!.bounds;
    final scaled = Rect.fromLTWH(
      b.left * scaleX,
      b.top * scaleY,
      b.width * scaleX,
      b.height * scaleY,
    );
    canvas.drawRect(
      scaled,
      Paint()
        ..color = const Color(0xFFFFCC00).withValues(alpha: 0.8)
        ..style = PaintingStyle.fill,
    );
    canvas.drawRect(
      scaled,
      Paint()
        ..color = const Color(0xFFFFCC00)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(_HighlightPainter old) =>
      old.selected != selected || old.scaleX != scaleX || old.scaleY != scaleY;
}
