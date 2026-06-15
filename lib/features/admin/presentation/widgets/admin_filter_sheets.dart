import 'package:flutter/material.dart';

// =======================================================================
// BOTTOM SHEET: FILTRO PARA MATERIAS (Semestre y Área)
// =======================================================================
class MateriasFilterSheet extends StatefulWidget {
  const MateriasFilterSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.4,
        maxChildSize: 0.8,
        snap: true,
        builder: (_, scrollController) => const MateriasFilterSheet(),
      ),
    );
  }

  @override
  State<MateriasFilterSheet> createState() => _MateriasFilterSheetState();
}

class _MateriasFilterSheetState extends State<MateriasFilterSheet> {
  final List<String> _semestresOpts = ['Todos', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  final List<String> _areasOpts = ['Todas', 'Institucional', 'Científica Básica', 'Profesional', 'Especialidad'];
  
  Set<String> _semestres = {'Todos'};
  Set<String> _area = {'Todas'};

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

  @override
  Widget build(BuildContext context) {
    return _BaseFilterSheet(
      title: 'Filtrar Materias',
      onApply: () => Navigator.pop(context), // Aquí iría la lógica de filtrado real
      children: [
        _AdminFilterSection(label: 'Semestre', options: _semestresOpts, isSelected: (o) => _semestres.contains(o), onTap: _toggleSemestre),
        const SizedBox(height: 24),
        _AdminFilterSection(label: 'Área de Formación', options: _areasOpts, isSelected: (o) => _area.contains(o), onTap: _toggleArea),
      ],
    );
  }
}

// =======================================================================
// BOTTOM SHEET: FILTRO PARA SALONES (Piso)
// =======================================================================
class SalonesFilterSheet extends StatefulWidget {
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
        builder: (_, scrollController) => const SalonesFilterSheet(),
      ),
    );
  }

  @override
  State<SalonesFilterSheet> createState() => _SalonesFilterSheetState();
}

class _SalonesFilterSheetState extends State<SalonesFilterSheet> {
  final List<String> _pisosOpts = ['Todos', 'Planta Baja', 'Piso 1', 'Piso 2'];
  Set<String> _pisos = {'Todos'};

  void _togglePiso(String v) {
    setState(() {
      if (v == 'Todos') {
        _pisos = {'Todos'};
      } else {
        _pisos.remove('Todos');
        _pisos.contains(v) ? _pisos.remove(v) : _pisos.add(v);
        if (_pisos.isEmpty) _pisos = {'Todos'};
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _BaseFilterSheet(
      title: 'Filtrar Salones',
      onApply: () => Navigator.pop(context),
      children: [
        _AdminFilterSection(label: 'Piso', options: _pisosOpts, isSelected: (o) => _pisos.contains(o), onTap: _togglePiso),
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

  const _BaseFilterSheet({required this.title, required this.children, required this.onApply});

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