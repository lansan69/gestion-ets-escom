// ============================================================
// NOMBRE: filter_card.dart
// USO: Bottom sheet deslizable con chips de filtro para carrera,
//      semestre, área de formación, turno, fecha y salón.
//      Los chips de carrera y área se generan dinámicamente desde
//      los datos del caché local para funcionar sin conexión.
//      Consumido por ExploreExams.
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/area_formacion.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/carrera.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/app_colors.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/app_buttons.dart';

class FilterCard extends StatefulWidget {
  // Listas dinámicas de opciones cargadas desde el caché local.
  final List<Carrera> carreraOptions;
  final List<AreaFormacion> areaFormacionOptions;

  // Selección actual. Carrera y área usan UUIDs; semestres usan strings de número.
  final Set<String> selectedCarreras;
  final Set<String> selectedSemestres;
  final Set<String> selectedArea;
  final String selectedTurno;
  final DateTime? selectedFecha;
  final String? selectedSalon;

  final ValueChanged<Set<String>> onCarrerasChanged;
  final ValueChanged<Set<String>> onSemestresChanged;
  final ValueChanged<Set<String>> onAreaChanged;
  final ValueChanged<String> onTurnoChanged;
  final ValueChanged<DateTime?> onFechaChanged;
  final ValueChanged<String?> onSalonChanged;
  final VoidCallback onApply;
  final ScrollController? scrollController;

  const FilterCard({
    super.key,
    required this.carreraOptions,
    required this.areaFormacionOptions,
    required this.selectedCarreras,
    required this.selectedSemestres,
    required this.selectedArea,
    required this.selectedTurno,
    this.selectedFecha,
    this.selectedSalon,
    required this.onCarrerasChanged,
    required this.onSemestresChanged,
    required this.onAreaChanged,
    required this.onTurnoChanged,
    required this.onFechaChanged,
    required this.onSalonChanged,
    required this.onApply,
    this.scrollController,
  });

  // Muestra el FilterCard como DraggableScrollableSheet. Recibe los filtros
  // actuales, las listas de opciones y callbacks para notificar cambios al padre.
  static void show(
    BuildContext context, {
    required List<Carrera> carreraOptions,
    required List<AreaFormacion> areaFormacionOptions,
    required Set<String> selectedCarreras,
    required Set<String> selectedSemestres,
    required Set<String> selectedArea,
    required String selectedTurno,
    DateTime? selectedFecha,
    String? selectedSalon,
    required ValueChanged<Set<String>> onCarrerasChanged,
    required ValueChanged<Set<String>> onSemestresChanged,
    required ValueChanged<Set<String>> onAreaChanged,
    required ValueChanged<String> onTurnoChanged,
    required ValueChanged<DateTime?> onFechaChanged,
    required ValueChanged<String?> onSalonChanged,
    required VoidCallback onApply,
  }) {
    // Unfocus whatever was focused before (e.g. search bar) so closing the
    // sheet doesn't restore focus to it and pop the keyboard up again.
    FocusManager.instance.primaryFocus?.unfocus();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        snap: true,
        snapSizes: const [0.4, 0.65, 0.92],
        builder: (_, scrollController) => FilterCard(
          carreraOptions: carreraOptions,
          areaFormacionOptions: areaFormacionOptions,
          selectedCarreras: selectedCarreras,
          selectedSemestres: selectedSemestres,
          selectedArea: selectedArea,
          selectedTurno: selectedTurno,
          selectedFecha: selectedFecha,
          selectedSalon: selectedSalon,
          onCarrerasChanged: onCarrerasChanged,
          onSemestresChanged: onSemestresChanged,
          onAreaChanged: onAreaChanged,
          onTurnoChanged: onTurnoChanged,
          onFechaChanged: onFechaChanged,
          onSalonChanged: onSalonChanged,
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
  static const _turnos = ['Todos', 'Matutino', 'Vespertino'];
  static const _meses = [
    'ene',
    'feb',
    'mar',
    'abr',
    'may',
    'jun',
    'jul',
    'ago',
    'sep',
    'oct',
    'nov',
    'dic',
  ];

  // Estado interno. Carrera y área usan UUIDs como valores.
  late Set<String> _carrera;
  late Set<String> _semestres;
  late Set<String> _area;
  late String _turno;
  DateTime? _fecha;
  late final TextEditingController _salonController;
  late final FocusNode _salonFocusNode;

  late final AnimationController _entranceCtrl;

  // six staggered intervals: carrera → semestre → área → turno → fecha → salón
  static const _sections = 6;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;

  @override
  void initState() {
    super.initState();
    _carrera = Set.from(widget.selectedCarreras);
    _semestres = Set.from(widget.selectedSemestres);
    _area = Set.from(widget.selectedArea);
    _turno = widget.selectedTurno;
    _fecha = widget.selectedFecha;
    _salonController = TextEditingController(text: widget.selectedSalon ?? '');
    _salonFocusNode = FocusNode(skipTraversal: true)
      ..addListener(_onSalonFocus);

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnims = List.generate(_sections, (i) {
      final start = i * 0.12;
      return CurvedAnimation(
        parent: _entranceCtrl,
        curve: Interval(
          start,
          (start + 0.4).clamp(0.0, 1.0),
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
    _salonController.dispose();
    _salonFocusNode.dispose();
    super.dispose();
  }

  // Alterna la selección de un semestre; 'Todos' limpia las demás selecciones.
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

  // Alterna la selección de una carrera por UUID; 'Todas' limpia las demás.
  void _toggleCarrera(String id) {
    setState(() {
      if (id == 'Todas') {
        _carrera = {'Todas'};
      } else {
        _carrera.remove('Todas');
        _carrera.contains(id) ? _carrera.remove(id) : _carrera.add(id);
        if (_carrera.isEmpty) _carrera = {'Todas'};
      }
    });
  }

  // Alterna la selección de un área por UUID; 'Todas' limpia las demás.
  void _toggleArea(String id) {
    setState(() {
      if (id == 'Todas') {
        _area = {'Todas'};
      } else {
        _area.remove('Todas');
        _area.contains(id) ? _area.remove(id) : _area.add(id);
        if (_area.isEmpty) _area = {'Todas'};
      }
    });
  }

  void _selectTurno(String v) => setState(() => _turno = v);

  Future<void> _pickFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fecha ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _fecha = picked);
  }

  void _clearFecha() => setState(() => _fecha = null);

  void _onSalonFocus() {
    if (!_salonFocusNode.hasFocus) return;
    // Wait for the keyboard animation to finish (~300 ms on most devices),
    // then queue a post-frame callback so the layout has rebuilt with the
    // updated viewInsets.bottom padding before we read maxScrollExtent.
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctrl = widget.scrollController;
        if (ctrl != null && ctrl.hasClients) {
          ctrl.animateTo(
            ctrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  String _formatDate(DateTime d) => '${d.day} ${_meses[d.month - 1]} ${d.year}';

  // Notifica los filtros seleccionados al padre y cierra el bottom sheet.
  void _applyAndClose() {
    widget.onCarrerasChanged(_carrera);
    widget.onSemestresChanged(_semestres);
    widget.onAreaChanged(_area);
    widget.onTurnoChanged(_turno);
    widget.onFechaChanged(_fecha);
    widget.onSalonChanged(
      _salonController.text.isEmpty ? null : _salonController.text,
    );
    debugPrint('carrera: ${_carrera}');
    debugPrint('semestres: ${_semestres}');
    debugPrint('area: ${_area}');
    debugPrint('turno : ${_turno}');
    debugPrint('fecha: ${_fecha}');
    debugPrint('salon: ${_salonController.text}');
    widget.onApply();
    Navigator.pop(context);
  }

  // Construye las opciones de carrera para el chip dinámico.
  // Incluye el plan en la etiqueta cuando varias carreras comparten la abreviatura.
  List<({String id, String label})> _buildCarreraChips() {
    final abbrevCount = <String, int>{};
    for (final c in widget.carreraOptions) {
      abbrevCount[c.abreviatura] = (abbrevCount[c.abreviatura] ?? 0) + 1;
    }
    return [
      (id: 'Todas', label: 'Todas'),
      for (final c in widget.carreraOptions)
        (
          id: c.id,
          label: (abbrevCount[c.abreviatura] ?? 1) > 1
              ? '${c.abreviatura} ${c.plan}'
              : c.abreviatura,
        ),
    ];
  }

  // Construye las opciones de área para el chip dinámico.
  // Usa nombre como etiqueta ya que AreaFormacion no tiene campo abreviatura.
  List<({String id, String label})> _buildAreaChips() {
    return [
      (id: 'Todas', label: 'Todas'),
      for (final af in widget.areaFormacionOptions)
        (id: af.id, label: af.nombre),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final carreraChips = _buildCarreraChips();
    final areaChips = _buildAreaChips();

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
              padding: EdgeInsets.fromLTRB(
                20,
                0,
                20,
                MediaQuery.of(context).viewInsets.bottom * 0.7,
              ),
              children: [
                _AnimatedSection(
                  fade: _fadeAnims[0],
                  slide: _slideAnims[0],
                  child: _FilterDynamicSection(
                    label: 'Carrera',
                    options: carreraChips,
                    isSelected: (id) => _carrera.contains(id),
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
                  child: _FilterDynamicSection(
                    label: 'Área',
                    options: areaChips,
                    isSelected: (id) => _area.contains(id),
                    onTap: _toggleArea,
                  ),
                ),
                const SizedBox(height: 20),
                _AnimatedSection(
                  fade: _fadeAnims[3],
                  slide: _slideAnims[3],
                  child: _FilterSection(
                    label: 'Turno',
                    options: _turnos,
                    isSelected: (o) => _turno == o,
                    onTap: _selectTurno,
                  ),
                ),
                const SizedBox(height: 20),
                _AnimatedSection(
                  fade: _fadeAnims[4],
                  slide: _slideAnims[4],
                  child: _FilterDateSection(
                    selected: _fecha,
                    onPick: _pickFecha,
                    onClear: _clearFecha,
                    formatDate: _formatDate,
                  ),
                ),
                const SizedBox(height: 20),
                _AnimatedSection(
                  fade: _fadeAnims[5],
                  slide: _slideAnims[5],
                  child: _FilterSalonSection(
                    controller: _salonController,
                    focusNode: _salonFocusNode,
                  ),
                ),
              ],
            ),
          ),
          // ─── Botones fijos al fondo ───────────────────────────────
          Padding(
            padding: EdgeInsets.only(
              top: 8,
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).padding.bottom + 8,
            ),
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

// ─── Sección de chips con valor == etiqueta (semestres, turno) ───────────────
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

// ─── Sección de chips dinámicos donde valor (UUID) difiere de etiqueta ────────
// Usada para carrera y área de formación. Cada opción tiene un id (UUID)
// que se usa como valor interno y un label que se muestra al usuario.
class _FilterDynamicSection extends StatelessWidget {
  final String label;
  final List<({String id, String label})> options;
  final bool Function(String id) isSelected;
  final ValueChanged<String> onTap;

  const _FilterDynamicSection({
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
            final selected = isSelected(opt.id);
            return GestureDetector(
              onTap: () => onTap(opt.id),
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
                  opt.label,
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

// ─── Sección de selección de fecha ───────────────────────────────────────────
class _FilterDateSection extends StatelessWidget {
  final DateTime? selected;
  final VoidCallback onPick;
  final VoidCallback onClear;
  final String Function(DateTime) formatDate;

  const _FilterDateSection({
    required this.selected,
    required this.onPick,
    required this.onClear,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FECHA',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade500,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            if (selected == null)
              GestureDetector(
                onTap: onPick,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.grey.shade300, width: 0.5),
                  ),
                  child: Text(
                    'Cualquiera',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              )
            else ...[
              GestureDetector(
                onTap: onPick,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDarkBlue,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: AppColors.primaryDarkBlue,
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    formatDate(selected!),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onClear,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Icon(
                    Icons.close,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
            const Spacer(),
            GestureDetector(
              onTap: onPick,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: AppColors.primaryDarkBlue,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Sección de número de salón ───────────────────────────────────────────────
class _FilterSalonSection extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;

  const _FilterSalonSection({
    required this.controller,
    required this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SALÓN',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade500,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) => TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: TextInputType.text,
            inputFormatters: [LengthLimitingTextInputFormatter(20)],
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Cualquiera',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              suffixIcon: value.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Colors.grey.shade500,
                        size: 18,
                      ),
                      splashRadius: 16,
                      onPressed: controller.clear,
                    )
                  : Icon(
                      Icons.meeting_room_outlined,
                      color: Colors.grey.shade400,
                      size: 18,
                    ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 0.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 0.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primaryDarkBlue,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
