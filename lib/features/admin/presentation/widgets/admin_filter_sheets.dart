import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_ets_escom/features/admin/presentation/providers/admin_materia_providers.dart';
import 'package:gestion_ets_escom/features/admin/presentation/providers/admin_salon_providers.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/area_formacion.dart';

// =======================================================================
// BOTTOM SHEET: FILTRO PARA MATERIAS (Semestre y Área)
// =======================================================================
class MateriasFilterSheet extends ConsumerStatefulWidget {
  const MateriasFilterSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize: 0.4,
        maxChildSize: 0.85,
        snap: true,
        builder: (_, sc) => const MateriasFilterSheet(),
      ),
    );
  }

  @override
  ConsumerState<MateriasFilterSheet> createState() =>
      _MateriasFilterSheetState();
}

class _MateriasFilterSheetState extends ConsumerState<MateriasFilterSheet> {
  // Copia local del estado de filtros — se aplica al confirmar.
  late Set<int> _semestres;
  String? _areaId;

  @override
  void initState() {
    super.initState();
    _semestres = Set<int>.from(ref.read(adminMateriaSemestresProvider));
    _areaId = ref.read(adminMateriaAreaProvider);
  }

  void _toggleSemestre(int s) {
    setState(() {
      _semestres.contains(s) ? _semestres.remove(s) : _semestres.add(s);
    });
  }

  void _apply() {
    ref.read(adminMateriaSemestresProvider.notifier).setAll(_semestres);
    ref.read(adminMateriaAreaProvider.notifier).set(_areaId);
    Navigator.pop(context);
  }

  void _clear() {
    setState(() {
      _semestres = {};
      _areaId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final areasAsync = ref.watch(areasFormacionProvider);

    return _BaseFilterSheet(
      title: 'Filtrar Materias',
      onApply: _apply,
      onClear: _clear,
      children: [
        _AdminFilterSection(
          label: 'Semestre',
          options: List.generate(9, (i) => '${i + 1}'),
          isSelected: (o) => _semestres.contains(int.parse(o)),
          onTap: (o) => _toggleSemestre(int.parse(o)),
        ),
        const SizedBox(height: 24),
        areasAsync.when(
          loading: () => const Center(
              child: CircularProgressIndicator(strokeWidth: 2)),
          error: (e, _) => Text('No se pudieron cargar las áreas',
              style: TextStyle(color: Colors.red[400], fontSize: 13)),
          data: (areas) => _ColoredAreaFilterSection(
            areas: areas,
            selectedId: _areaId,
            onTap: (area) => setState(() {
              _areaId = (_areaId == area.id) ? null : area.id;
            }),
          ),
        ),
      ],
    );
  }
}

// =======================================================================
// BOTTOM SHEET: FILTRO PARA SALONES (Piso)
// Usa valores enteros (0, 1, 2) que coinciden con la BD.
// =======================================================================

// Mapeo de número de piso a etiqueta visual.
const _pisoLabels = {0: 'Planta Baja', 1: 'Piso 1', 2: 'Piso 2'};

class SalonesFilterSheet extends ConsumerStatefulWidget {
  const SalonesFilterSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.3,
        maxChildSize: 0.6,
        snap: true,
        builder: (_, sc) => const SalonesFilterSheet(),
      ),
    );
  }

  @override
  ConsumerState<SalonesFilterSheet> createState() =>
      _SalonesFilterSheetState();
}

class _SalonesFilterSheetState extends ConsumerState<SalonesFilterSheet> {
  late Set<int> _pisos;

  @override
  void initState() {
    super.initState();
    _pisos = Set<int>.from(ref.read(adminSalonPisoFilterProvider));
  }

  void _togglePiso(int p) {
    setState(() {
      _pisos.contains(p) ? _pisos.remove(p) : _pisos.add(p);
    });
  }

  void _apply() {
    ref.read(adminSalonPisoFilterProvider.notifier).setAll(_pisos);
    Navigator.pop(context);
  }

  void _clear() {
    setState(() => _pisos = {});
  }

  @override
  Widget build(BuildContext context) {
    return _BaseFilterSheet(
      title: 'Filtrar Salones',
      onApply: _apply,
      onClear: _clear,
      children: [
        _AdminFilterSection(
          label: 'Piso',
          options: _pisoLabels.values.toList(),
          isSelected: (label) {
            final entry =
                _pisoLabels.entries.firstWhere((e) => e.value == label);
            return _pisos.contains(entry.key);
          },
          onTap: (label) {
            final entry =
                _pisoLabels.entries.firstWhere((e) => e.value == label);
            _togglePiso(entry.key);
          },
        ),
      ],
    );
  }
}

// =======================================================================
// COMPONENTES BASE (Reutilizados del código original)
// =======================================================================

class _BaseFilterSheet extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final VoidCallback onApply;
  final VoidCallback? onClear;

  const _BaseFilterSheet({required this.title, required this.children, required this.onApply, this.onClear});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: Column(
        children: [
          Container(margin: const EdgeInsets.symmetric(vertical: 10), width: 36, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: Align(alignment: Alignment.centerLeft, child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600))),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              children: children,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Column(
              children: [
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF00338D), minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: onApply,
                  child: const Text('Aplicar filtros', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                if (onClear != null)
                  TextButton(
                    style: TextButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                    onPressed: onClear,
                    child: const Text('Limpiar filtros', style: TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.bold)),
                  )
                else
                  TextButton(
                    style: TextButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar', style: TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminFilterSection extends StatelessWidget {
  final String label;
  final List<String> options;
  final bool Function(String) isSelected;
  final ValueChanged<String> onTap;

  const _AdminFilterSection({required this.label, required this.options, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade500, letterSpacing: 0.8)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: options.map((opt) {
            final selected = isSelected(opt);
            return GestureDetector(
              onTap: () => onTap(opt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFF00338D) : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: selected ? const Color(0xFF00338D) : Colors.grey.shade300, width: 0.5),
                ),
                child: Text(opt, style: TextStyle(fontSize: 13, fontWeight: selected ? FontWeight.w500 : FontWeight.w400, color: selected ? Colors.white : Colors.grey.shade700)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// Chips de área de formación con el color real del área.
class _ColoredAreaFilterSection extends StatelessWidget {
  final List<AreaFormacion> areas;
  final String? selectedId;
  final void Function(AreaFormacion) onTap;

  const _ColoredAreaFilterSection({
    required this.areas,
    required this.selectedId,
    required this.onTap,
  });

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return Colors.grey;
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ÁREA DE FORMACIÓN',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade500,
                letterSpacing: 0.8)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: areas.map((area) {
            final areaColor = _parseColor(area.color);
            final selected = selectedId == area.id;
            return GestureDetector(
              onTap: () => onTap(area),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? areaColor : Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: selected ? areaColor : areaColor.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!selected)
                      Container(
                        width: 10,
                        height: 10,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                            color: areaColor, shape: BoxShape.circle),
                      ),
                    Text(
                      area.nombre,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w400,
                        color: selected ? Colors.white : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}