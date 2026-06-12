import 'package:flutter/material.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/app_colors.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/app_buttons.dart';

class FilterCard extends StatefulWidget {
  final Set<String> selectedCarreras;
  final Set<String> selectedSemestres;
  final Set<String> selectedArea;
  final ValueChanged<Set<String>> onCarrerasChanged;
  final ValueChanged<Set<String>> onSemestresChanged;
  final ValueChanged<Set<String>> onAreaChanged;
  final VoidCallback onApply;
  final ScrollController? scrollController;

  const FilterCard({
    super.key,
    required this.selectedCarreras,
    required this.selectedSemestres,
    required this.selectedArea,
    required this.onCarrerasChanged,
    required this.onSemestresChanged,
    required this.onAreaChanged,
    required this.onApply,
    this.scrollController,
  });

  static void show(
    BuildContext context, {
    required Set<String> selectedCarreras,
    required Set<String> selectedSemestres,
    required Set<String> selectedArea,
    required ValueChanged<Set<String>> onCarrerasChanged,
    required ValueChanged<Set<String>> onSemestresChanged,
    required ValueChanged<Set<String>> onAreaChanged,
    required VoidCallback onApply,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize: 0.4,
        maxChildSize: 0.85,
        snap: true,
        snapSizes: const [0.4, 0.55, 0.85],
        builder: (_, scrollController) => FilterCard(
          selectedCarreras: selectedCarreras,
          selectedSemestres: selectedSemestres,
          selectedArea: selectedArea,
          onCarrerasChanged: onCarrerasChanged,
          onSemestresChanged: onSemestresChanged,
          onAreaChanged: onAreaChanged,
          onApply: onApply,
          scrollController: scrollController,
        ),
      ),
    );
  }

  @override
  State<FilterCard> createState() => _FilterCardState();
}

class _FilterCardState extends State<FilterCard>
    with SingleTickerProviderStateMixin {
  static const _carreras = ['Todas', 'ISC 2020', 'IA', 'LCD', 'ISC 2009'];
  static const _semestresOpts = [
    'Todos',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
  ];
  static const _areas = ['Todas', 'Básica', 'Profesional', 'Terminal'];

  late Set<String> _carrera;
  late Set<String> _semestres;
  late Set<String> _area;

  late final AnimationController _entranceCtrl;

  // three staggered intervals: header → carrera → semestre → área
  static const _sections = 3;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;

  @override
  void initState() {
    super.initState();
    _carrera = Set.from(widget.selectedCarreras);
    _semestres = Set.from(widget.selectedSemestres);
    _area = Set.from(widget.selectedArea);

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnims = List.generate(_sections, (i) {
      final start = i * 0.2;
      return CurvedAnimation(
        parent: _entranceCtrl,
        curve: Interval(
          start,
          (start + 0.5).clamp(0.0, 1.0),
          curve: Curves.easeOut,
        ),
      );
    });

    _slideAnims = _fadeAnims
        .map(
          (anim) => Tween<Offset>(
            begin: const Offset(0, 0.25),
            end: Offset.zero,
          ).animate(anim),
        )
        .toList();

    _entranceCtrl.forward();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
  }

  void _toggleSemestre(String v) {
    setState(() {
      if (v == 'Todos') {
        _semestres = {'Todos'};
      } else {
        _semestres.remove('Todos');
        _semestres.contains(v) ? _semestres.remove(v) : _semestres.add(v);
        if (_semestres.isEmpty) _semestres = {'Todos'};
      }
    });
  }

  void _toggleCarrera(String v) {
    setState(() {
      if (v == 'Todas') {
        _carrera = {'Todas'};
      } else {
        _carrera.remove('Todas');
        _carrera.contains(v) ? _carrera.remove(v) : _carrera.add(v);
        if (_carrera.isEmpty) _carrera = {'Todas'};
      }
    });
  }

  void _toggleArea(String v) {
    setState(() {
      if (v == 'Todas') {
        _area = {'Todas'};
      } else {
        _area.remove('Todas');
        _area.contains(v) ? _area.remove(v) : _area.add(v);
        if (_area.isEmpty) _area = {'Todas'};
      }
    });
  }

  void _applyAndClose() {
    widget.onCarrerasChanged(_carrera);
    widget.onSemestresChanged(_semestres);
    widget.onAreaChanged(_area);
    widget.onApply();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // ─── Handle ──────────────────────────────────────────────
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Filtrar ETS',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          // ─── Contenido scrollable ─────────────────────────────────
          Expanded(
            child: ListView(
              controller: widget.scrollController,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              children: [
                _AnimatedSection(
                  fade: _fadeAnims[0],
                  slide: _slideAnims[0],
                  child: _FilterSection(
                    label: 'Carrera',
                    options: _carreras,
                    isSelected: (o) => _carrera.contains(o),
                    onTap: _toggleCarrera,
                  ),
                ),
                const SizedBox(height: 20),
                _AnimatedSection(
                  fade: _fadeAnims[1],
                  slide: _slideAnims[1],
                  child: _FilterSection(
                    label: 'Semestre',
                    options: _semestresOpts,
                    isSelected: (o) => _semestres.contains(o),
                    onTap: _toggleSemestre,
                  ),
                ),
                const SizedBox(height: 20),
                _AnimatedSection(
                  fade: _fadeAnims[2],
                  slide: _slideAnims[2],
                  child: _FilterSection(
                    label: 'Área',
                    options: _areas,
                    isSelected: (o) => _area.contains(o),
                    onTap: _toggleArea,
                  ),
                ),
              ],
            ),
          ),
          // ─── Botones fijos al fondo ───────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Column(
              children: [
                AppPrimaryButton(
                  label: 'Aplicar filtros',
                  width: MediaQuery.of(context).size.width * 0.9,
                  onPressed: _applyAndClose,
                ),
                AppSecondaryButton(
                  label: 'Cancelar',
                  width: MediaQuery.of(context).size.width * 0.9,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Wrapper de animación de entrada ─────────────────────────────────────────
class _AnimatedSection extends StatelessWidget {
  final Animation<double> fade;
  final Animation<Offset> slide;
  final Widget child;

  const _AnimatedSection({
    required this.fade,
    required this.slide,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(position: slide, child: child),
    );
  }
}

// ─── Sección reutilizable de chips ────────────────────────────────────────────
class _FilterSection extends StatelessWidget {
  final String label;
  final List<String> options;
  final bool Function(String) isSelected;
  final ValueChanged<String> onTap;

  const _FilterSection({
    required this.label,
    required this.options,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade500,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((opt) {
            final selected = isSelected(opt);
            return GestureDetector(
              onTap: () => onTap(opt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primaryDarkBlue
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: selected
                        ? AppColors.primaryDarkBlue
                        : Colors.grey.shade300,
                    width: 0.5,
                  ),
                ),
                child: Text(
                  opt,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
                    color: selected ? Colors.white : Colors.grey.shade700,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
