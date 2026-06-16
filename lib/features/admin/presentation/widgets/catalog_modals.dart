import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/area_formacion.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/carrera.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/edificio.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/materia.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/salon.dart';
import 'package:gestion_ets_escom/features/admin/presentation/providers/admin_materia_providers.dart';
import 'package:gestion_ets_escom/features/admin/presentation/providers/admin_salon_providers.dart';
import 'package:gestion_ets_escom/features/admin/presentation/providers/catalog_provider.dart';
import 'package:gestion_ets_escom/features/user/presentation/providers/carrera_providers.dart';
import 'package:gestion_ets_escom/features/user/presentation/providers/edificios_provider.dart';
import 'package:gestion_ets_escom/features/user/presentation/providers/salones_providers.dart';

InputDecoration _inputDecoration({String? hint, IconData? icon}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
    filled: true,
    fillColor: const Color(0xFFF8F9FA),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
    prefixIcon: icon != null ? Icon(icon, size: 20, color: const Color(0xFF00338D).withOpacity(0.6)) : null,
  );
}

Widget _buildSectionTitle(String title, IconData icon) {
  return Row(children: [
    Icon(icon, size: 18, color: const Color(0xFF00338D)),
    const SizedBox(width: 8),
    Text(title.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF00338D), letterSpacing: 1.1)),
  ]);
}

Widget _inlineErrorBox(String message) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.orange[50],
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.orange[300]!),
    ),
    child: Row(children: [
      Icon(Icons.warning_amber_rounded, color: Colors.orange[700], size: 18),
      const SizedBox(width: 8),
      Expanded(child: Text(message, style: TextStyle(color: Colors.orange[800], fontSize: 13))),
    ]),
  );
}

// =====================================================================
// MODAL CARRERA
// =====================================================================
class CarreraFormModal extends ConsumerStatefulWidget {
  final bool isEditing;
  final Carrera? carrera;
  const CarreraFormModal({super.key, this.isEditing = false, this.carrera});
  @override
  ConsumerState<CarreraFormModal> createState() => _CarreraFormModalState();
}

class _CarreraFormModalState extends ConsumerState<CarreraFormModal> {
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _abrevCtrl;
  late final TextEditingController _planCtrl;
  late bool _isActive;
  String? _inlineError;
  final _formKey = GlobalKey<FormState>();

  void _clearError() => setState(() => _inlineError = null);

  @override
  void initState() {
    super.initState();
    final c = widget.carrera;
    _nombreCtrl = TextEditingController(text: c?.nombre ?? '');
    _abrevCtrl  = TextEditingController(text: c?.abreviatura ?? '');
    _planCtrl   = TextEditingController(text: c?.plan.toString() ?? '');
    _isActive   = c?.activo ?? true;
    _abrevCtrl.addListener(_clearError);
    _planCtrl.addListener(_clearError);
    _nombreCtrl.addListener(_clearError);
  }

  @override
  void dispose() {
    _nombreCtrl.dispose(); _abrevCtrl.dispose(); _planCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final abrev = _abrevCtrl.text.trim();
    final plan  = int.tryParse(_planCtrl.text.trim()) ?? 0;
    final allCarreras = ref.read(carrerasProvider).value ?? [];
    final isDuplicate = allCarreras.any((c) =>
        c.abreviatura.trim().toLowerCase() == abrev.toLowerCase() &&
        c.plan == plan &&
        c.id != (widget.carrera?.id ?? ''));
    if (isDuplicate) {
      setState(() => _inlineError = 'Ya existe la carrera $abrev · Plan $plan. Verifica los datos.');
      return;
    }
    final entidad = Carrera(
      id: widget.carrera?.id ?? const Uuid().v4(),
      nombre: _nombreCtrl.text.trim(),
      abreviatura: abrev,
      plan: plan,
      activo: _isActive,
    );
    final notifier = ref.read(catalogMutationProvider.notifier);
    if (widget.isEditing) { await notifier.editCarrera(entidad); } else { await notifier.addCarrera(entidad); }
    final estado = ref.read(catalogMutationProvider);
    if (!mounted) return;
    if (estado.isSuccess) {
      ref.invalidate(carrerasProvider);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.isEditing ? 'Carrera actualizada' : 'Carrera creada'), backgroundColor: Colors.green));
      ref.read(catalogMutationProvider.notifier).resetState();
    } else if (estado.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(estado.errorMessage!), backgroundColor: Colors.red));
      ref.read(catalogMutationProvider.notifier).resetState();
    }
  }

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF00338D);
    final estado = ref.watch(catalogMutationProvider);
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
          child: Form(
            key: _formKey,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              _ModalHeader(title: widget.isEditing ? 'Editar Carrera' : 'Nueva Carrera', subtitle: widget.isEditing ? 'Modifica el plan de estudios' : 'Registra una nueva oferta académica', color: color),
              Flexible(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _buildSectionTitle('Información Académica', Icons.school_outlined),
                const SizedBox(height: 16),
                _FieldLabel('Nombre de la Carrera'),
                TextFormField(controller: _nombreCtrl, decoration: _inputDecoration(hint: 'Ej. Ing. en Sistemas Computacionales'), validator: (v) => (v == null || v.trim().isEmpty) ? 'Campo requerido' : null),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _FieldLabel('Abreviatura'),
                    TextFormField(controller: _abrevCtrl, decoration: _inputDecoration(hint: 'Ej. ISC'), validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null),
                  ])),
                  const SizedBox(width: 16),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _FieldLabel('Año Plan'),
                    TextFormField(controller: _planCtrl, keyboardType: TextInputType.number, decoration: _inputDecoration(hint: 'Ej. 2020'), validator: (v) { if (v == null || v.trim().isEmpty) return 'Requerido'; if (int.tryParse(v.trim()) == null) return 'Solo números'; return null; }),
                  ])),
                ]),
                const SizedBox(height: 24),
                SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Estado de la Carrera', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)), subtitle: Text(_isActive ? 'Activa (Visible en el sistema)' : 'Inactiva (Oculta)', style: TextStyle(fontSize: 12, color: Colors.grey[600])), value: _isActive, activeColor: color, onChanged: (v) => setState(() => _isActive = v)),
                if (_inlineError != null) ...[
                  const SizedBox(height: 12),
                  _inlineErrorBox(_inlineError!),
                ],
              ]))),
              _ModalFooter(label: widget.isEditing ? 'Guardar Cambios' : 'Crear Carrera', isLoading: estado.isLoading, onPressed: _submit),
            ]),
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// MODAL MATERIA — CRUD completo con Supabase
// =====================================================================
class MateriaFormModal extends ConsumerStatefulWidget {
  final Carrera carrera;
  final Materia? materia;

  const MateriaFormModal({super.key, required this.carrera, this.materia});

  @override
  ConsumerState<MateriaFormModal> createState() => _MateriaFormModalState();
}

class _MateriaFormModalState extends ConsumerState<MateriaFormModal> {
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _semestreCtrl;
  late bool _isActive;
  String? _selectedAreaId;
  AreaFormacion? _selectedArea;
  String? _inlineError;
  final _formKey = GlobalKey<FormState>();

  bool get _isEditing => widget.materia != null;

  Color _parseAreaColor(String? hex) {
    if (hex == null || hex.isEmpty) return Colors.grey;
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return Colors.grey;
    }
  }

  @override
  void initState() {
    super.initState();
    final m = widget.materia;
    _nombreCtrl  = TextEditingController(text: m?.nombre ?? '');
    _semestreCtrl = TextEditingController(text: m?.semestre.toString() ?? '');
    _isActive     = m?.activo ?? true;
    _selectedArea = m?.areaFormacion;
    _selectedAreaId = m?.areaFormacion?.id;
    _nombreCtrl.addListener(() => setState(() => _inlineError = null));
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _semestreCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final nombre = _nombreCtrl.text.trim();
    final allMaterias = ref.read(adminMateriasRawProvider(widget.carrera.id)).value ?? [];
    final isDuplicate = allMaterias.any((m) =>
        m.nombre.trim().toLowerCase() == nombre.toLowerCase() &&
        m.id != (widget.materia?.id ?? ''));
    if (isDuplicate) {
      setState(() => _inlineError = 'Ya existe una materia con el nombre "$nombre" en esta carrera.');
      return;
    }
    final entidad = Materia(
      id: widget.materia?.id ?? const Uuid().v4(),
      nombre: _nombreCtrl.text.trim(),
      carrera: widget.carrera,
      semestre: int.tryParse(_semestreCtrl.text.trim()) ?? 1,
      activo: _isActive,
      areaFormacion: _selectedArea,
    );
    final notifier = ref.read(adminMateriaMutationProvider.notifier);
    if (_isEditing) {
      await notifier.editMateria(entidad);
    } else {
      await notifier.addMateria(entidad);
    }
    final estado = ref.read(adminMateriaMutationProvider);
    if (!mounted) return;
    if (estado.isSuccess) {
      ref.invalidate(adminMateriasRawProvider(widget.carrera.id));
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_isEditing ? 'Materia actualizada' : 'Materia creada'),
        backgroundColor: Colors.green,
      ));
      ref.read(adminMateriaMutationProvider.notifier).resetState();
    } else if (estado.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(estado.errorMessage!),
        backgroundColor: Colors.red,
      ));
      ref.read(adminMateriaMutationProvider.notifier).resetState();
    }
  }

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF00338D);
    final estado = ref.watch(adminMateriaMutationProvider);
    final areasAsync = ref.watch(areasFormacionProvider);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
          child: Form(
            key: _formKey,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              _ModalHeader(
                title: _isEditing ? 'Editar Materia' : 'Nueva Materia',
                subtitle: '${widget.carrera.abreviatura} · Plan ${widget.carrera.plan}',
                color: color,
              ),
              Flexible(child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _buildSectionTitle('Información de la Materia', Icons.book_outlined),
                  const SizedBox(height: 16),
                  _FieldLabel('Nombre de la Materia'),
                  TextFormField(
                    controller: _nombreCtrl,
                    decoration: _inputDecoration(hint: 'Ej. Redes de Computadoras'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  _FieldLabel('Semestre'),
                  TextFormField(
                    controller: _semestreCtrl,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration(hint: '1 – 9'),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Requerido';
                      final n = int.tryParse(v.trim());
                      if (n == null || n < 1 || n > 9) return 'Ingresa un número del 1 al 9';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _FieldLabel('Área de Formación'),
                  areasAsync.when(
                    loading: () => const SizedBox(
                      height: 56,
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                    error: (e, _) => Text('Error al cargar áreas', style: TextStyle(color: Colors.red[600])),
                    data: (areas) {
                      // Sync _selectedArea reference once areas load during editing
                      if (_selectedAreaId != null && _selectedArea == null) {
                        try {
                          _selectedArea = areas.firstWhere((a) => a.id == _selectedAreaId);
                        } catch (_) {}
                      }
                      return DropdownButtonFormField<String?>(
                        key: ValueKey(_selectedAreaId),
                        initialValue: _selectedAreaId,
                        decoration: _inputDecoration(hint: 'Selecciona un área'),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Row(children: [
                              SizedBox(width: 16, height: 16),
                              SizedBox(width: 10),
                              Text('Sin área de formación'),
                            ]),
                          ),
                          ...areas.map((a) {
                            final areaColor = _parseAreaColor(a.color);
                            return DropdownMenuItem<String?>(
                              value: a.id,
                              child: Row(children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: areaColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(a.nombre),
                              ]),
                            );
                          }),
                        ],
                        onChanged: (id) {
                          setState(() {
                            _selectedAreaId = id;
                            _selectedArea = id == null
                                ? null
                                : areas.firstWhere((a) => a.id == id);
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Estado de la Materia', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: Text(_isActive ? 'Activa (Visible en el sistema)' : 'Inactiva (Oculta)', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    value: _isActive,
                    activeThumbColor: color,
                    activeTrackColor: color.withValues(alpha: 0.3),
                    onChanged: (v) => setState(() => _isActive = v),
                  ),
                  if (_inlineError != null) ...[
                    const SizedBox(height: 12),
                    _inlineErrorBox(_inlineError!),
                  ],
                ]),
              )),
              _ModalFooter(
                label: _isEditing ? 'Guardar Cambios' : 'Crear Materia',
                isLoading: estado.isLoading,
                onPressed: _submit,
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// MODAL SALÓN
// =====================================================================
class SalonFormModal extends ConsumerStatefulWidget {
  final bool isEditing;
  final Salon? salon;
  final String edificioFijo;
  final bool isForEdificio;
  const SalonFormModal({super.key, this.isEditing = false, this.salon, required this.edificioFijo, this.isForEdificio = false});
  @override
  ConsumerState<SalonFormModal> createState() => _SalonFormModalState();
}

class _SalonFormModalState extends ConsumerState<SalonFormModal> {
  late final TextEditingController _edificioCtrl;
  late final TextEditingController _pisoCtrl;
  late final TextEditingController _numeroCtrl;
  late bool _isActive;
  String? _inlineError;
  final _formKey = GlobalKey<FormState>();

  void _onFieldChange() => setState(() => _inlineError = null);

  @override
  void initState() {
    super.initState();
    final s = widget.salon;
    _edificioCtrl = TextEditingController(text: s?.edificio.toString() ?? widget.edificioFijo);
    _pisoCtrl     = TextEditingController(text: s?.piso.toString() ?? '');
    _numeroCtrl   = TextEditingController(text: s?.numeroSalon.toString() ?? '');
    _isActive     = s?.activo ?? true;
    // Rebuild on each keystroke so the live etiqueta preview updates; also clear error.
    _edificioCtrl.addListener(_onFieldChange);
    _pisoCtrl.addListener(_onFieldChange);
    _numeroCtrl.addListener(_onFieldChange);
  }

  @override
  void dispose() {
    _edificioCtrl.dispose();
    _pisoCtrl.dispose();
    _numeroCtrl.dispose();
    super.dispose();
  }

  // Etiqueta generada automáticamente (igual que la columna GENERATED de Supabase).
  String get _computedEtiqueta {
    final e = _edificioCtrl.text.trim();
    final p = _pisoCtrl.text.trim();
    final n = _numeroCtrl.text.trim();
    if (e.isEmpty || p.isEmpty || n.isEmpty) return '—';
    final num = int.tryParse(n);
    if (num == null) return '—';
    return '$e$p${num.toString().padLeft(2, '0')}';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final edificio = int.tryParse(_edificioCtrl.text.trim()) ?? 0;
    final piso     = int.tryParse(_pisoCtrl.text.trim()) ?? 0;
    final numero   = int.tryParse(_numeroCtrl.text.trim()) ?? 0;

    // Verificar duplicado contra el caché local de salonesProvider.
    final allSalones = ref.read(salonesProvider).asData?.value ?? [];
    final isDuplicate = allSalones.any((s) =>
        s.edificio == edificio &&
        s.piso == piso &&
        s.numeroSalon == numero &&
        s.id != (widget.salon?.id ?? ''));
    if (isDuplicate) {
      setState(() => _inlineError = 'El salón $_computedEtiqueta ya existe. Verifica edificio, piso y número.');
      return;
    }

    final entidad = Salon(
      id: widget.salon?.id ?? const Uuid().v4(),
      edificio: edificio,
      piso: piso,
      numeroSalon: numero,
      etiquetaSalon: null, // Columna GENERATED en Supabase — no se envía.
      activo: _isActive,
    );
    final notifier = ref.read(catalogMutationProvider.notifier);
    if (widget.isEditing) {
      await notifier.editSalon(entidad);
    } else {
      await notifier.addSalon(entidad);
    }
    final estado = ref.read(catalogMutationProvider);
    if (!mounted) return;
    if (estado.isSuccess) {
      ref.invalidate(salonesProvider);
      ref.invalidate(adminSalonesInactivosProvider);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(widget.isEditing
            ? 'Salón actualizado exitosamente'
            : 'Salón $_computedEtiqueta creado exitosamente'),
        backgroundColor: Colors.green,
      ));
      ref.read(catalogMutationProvider.notifier).resetState();
    } else if (estado.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(estado.errorMessage!),
        backgroundColor: Colors.red,
      ));
      ref.read(catalogMutationProvider.notifier).resetState();
    }
  }

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF00338D);
    final estado = ref.watch(catalogMutationProvider);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(28)),
          child: Form(
            key: _formKey,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              _ModalHeader(
                title: widget.isForEdificio
                    ? (widget.isEditing ? 'Editar Edificio' : 'Nuevo Edificio')
                    : (widget.isEditing ? 'Editar Salón' : 'Nuevo Salón'),
                subtitle: widget.isForEdificio
                    ? 'Registra el primer salón del nuevo edificio'
                    : (widget.edificioFijo.isEmpty
                        ? 'Especifica el Edificio'
                        : 'Edificio ${widget.edificioFijo}'),
                color: color,
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    if (widget.edificioFijo.isEmpty) ...[
                      _FieldLabel('Edificio'),
                      TextFormField(
                        controller: _edificioCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration(hint: 'Ej. 1, 4'),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Requerido'
                            : null,
                      ),
                      const SizedBox(height: 16),
                    ],
                    Row(children: [
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          _FieldLabel('Piso'),
                          TextFormField(
                            controller: _pisoCtrl,
                            keyboardType: TextInputType.number,
                            decoration:
                                _inputDecoration(hint: '0 (PB), 1 o 2'),
                            validator: (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Requerido'
                                    : null,
                          ),
                        ]),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          _FieldLabel('N° Salón'),
                          TextFormField(
                            controller: _numeroCtrl,
                            keyboardType: TextInputType.number,
                            decoration: _inputDecoration(hint: 'Ej. 4 → 04'),
                            validator: (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Requerido'
                                    : null,
                          ),
                        ]),
                      ),
                    ]),
                    const SizedBox(height: 16),
                    _FieldLabel('Código del salón (generado automáticamente)'),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F4FF),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: color.withValues(alpha: 0.25)),
                      ),
                      child: Text(
                        _computedEtiqueta,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF00338D),
                          letterSpacing: 3,
                        ),
                      ),
                    ),
                    if (_inlineError != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange[300]!),
                        ),
                        child: Row(children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.orange[700], size: 18),
                          const SizedBox(width: 8),
                          Expanded(child: Text(_inlineError!, style: TextStyle(color: Colors.orange[800], fontSize: 13))),
                        ]),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Disponibilidad',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                      subtitle: Text(
                          _isActive ? 'Salón en uso' : 'Mantenimiento',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey[600])),
                      value: _isActive,
                      activeThumbColor: color,
                      activeTrackColor: color.withValues(alpha: 0.3),
                      onChanged: (v) => setState(() => _isActive = v),
                    ),
                  ]),
                ),
              ),
              _ModalFooter(
                label: widget.isEditing ? 'Guardar Cambios' : 'Crear Salón',
                isLoading: estado.isLoading,
                onPressed: _submit,
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// MODAL ELIMINAR
// =====================================================================
class DeleteCatalogModal extends ConsumerWidget {
  final String title;
  final String subtitle;
  final String entityId;
  final bool isCarrera;
  const DeleteCatalogModal({super.key, required this.title, required this.subtitle, required this.entityId, required this.isCarrera});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(catalogMutationProvider);
    return BackdropFilter(filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8), child: Dialog(backgroundColor: Colors.transparent, child: Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32)), child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.delete_sweep_rounded, size: 48, color: Colors.red[600]),
      const SizedBox(height: 16),
      const Text('¿Eliminar registro?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Text('Esta acción no se puede deshacer.', style: TextStyle(color: Colors.grey[600])),
      const SizedBox(height: 20),
      Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(12)), child: Row(children: [
        const Icon(Icons.warning_amber_rounded, color: Colors.red), const SizedBox(width: 10),
        Expanded(child: Text('$title\n$subtitle', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
      ])),
      const SizedBox(height: 24),
      Row(children: [
        Expanded(child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar'))),
        Expanded(child: FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Colors.red[600]),
          onPressed: estado.isLoading ? null : () async {
            final notifier = ref.read(catalogMutationProvider.notifier);
            if (isCarrera) { await notifier.removeCarrera(entityId); } else { await notifier.removeSalon(entityId); }
            final s = ref.read(catalogMutationProvider);
            if (!context.mounted) return;
            if (s.isSuccess) {
              if (isCarrera) {
                ref.invalidate(carrerasProvider);
              } else {
                ref.invalidate(salonesProvider);
                ref.invalidate(adminSalonesInactivosProvider);
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registro eliminado'), backgroundColor: Colors.green));
              ref.read(catalogMutationProvider.notifier).resetState();
            } else if (s.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.errorMessage!), backgroundColor: Colors.red));
              ref.read(catalogMutationProvider.notifier).resetState();
            }
          },
          child: estado.isLoading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Eliminar'),
        )),
      ]),
    ]))));
  }
}

// =====================================================================
// MODAL EDIFICIO
// =====================================================================
class EdificioFormModal extends ConsumerStatefulWidget {
  final bool isEditing;
  final Edificio? edificio;
  const EdificioFormModal({super.key, this.isEditing = false, this.edificio});
  @override
  ConsumerState<EdificioFormModal> createState() => _EdificioFormModalState();
}

class _EdificioFormModalState extends ConsumerState<EdificioFormModal> {
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _numeroCtrl;
  String? _inlineError;
  final _formKey = GlobalKey<FormState>();

  void _clearError() => setState(() => _inlineError = null);

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.edificio?.nombre ?? '');
    _numeroCtrl = TextEditingController(text: widget.edificio?.numero.toString() ?? '');
    _nombreCtrl.addListener(_clearError);
    _numeroCtrl.addListener(_clearError);
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _numeroCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final numero = int.tryParse(_numeroCtrl.text.trim()) ?? 0;
    final allEdificios = ref.read(edificiosProvider).value ?? [];
    final isDuplicate = allEdificios.any((e) =>
        e.numero == numero && e.id != (widget.edificio?.id ?? ''));
    if (isDuplicate) {
      setState(() => _inlineError = 'Ya existe un edificio con el número $numero. Elige un número diferente.');
      return;
    }
    final entidad = Edificio(
      id: widget.edificio?.id ?? const Uuid().v4(),
      nombre: _nombreCtrl.text.trim(),
      numero: numero,
      activo: widget.edificio?.activo ?? true,
    );
    final notifier = ref.read(catalogMutationProvider.notifier);
    if (widget.isEditing) {
      await notifier.editEdificio(entidad, widget.edificio!.numero);
    } else {
      await notifier.addEdificio(entidad);
    }
    final estado = ref.read(catalogMutationProvider);
    if (!mounted) return;
    if (estado.isSuccess) {
      ref.invalidate(edificiosProvider);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(widget.isEditing ? 'Edificio actualizado' : 'Edificio creado'),
        backgroundColor: Colors.green,
      ));
      ref.read(catalogMutationProvider.notifier).resetState();
    } else if (estado.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(estado.errorMessage!),
        backgroundColor: Colors.red,
      ));
      ref.read(catalogMutationProvider.notifier).resetState();
    }
  }

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF00338D);
    final estado = ref.watch(catalogMutationProvider);
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
          child: Form(
            key: _formKey,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              _ModalHeader(
                title: widget.isEditing ? 'Editar Edificio' : 'Nuevo Edificio',
                subtitle: widget.isEditing ? 'Modifica los datos del edificio' : 'Registra un nuevo edificio',
                color: color,
              ),
              Flexible(child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _buildSectionTitle('Datos del Edificio', Icons.business_outlined),
                  const SizedBox(height: 16),
                  _FieldLabel('Nombre'),
                  TextFormField(
                    controller: _nombreCtrl,
                    decoration: _inputDecoration(hint: 'Ej. Edificio 1'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  _FieldLabel('Número'),
                  TextFormField(
                    controller: _numeroCtrl,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration(hint: 'Ej. 1, 2, 3, 4'),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Requerido';
                      if (int.tryParse(v.trim()) == null) return 'Solo números enteros';
                      return null;
                    },
                  ),
                  if (_inlineError != null) ...[
                    const SizedBox(height: 12),
                    _inlineErrorBox(_inlineError!),
                  ],
                ]),
              )),
              _ModalFooter(
                label: widget.isEditing ? 'Guardar Cambios' : 'Crear Edificio',
                isLoading: estado.isLoading,
                onPressed: _submit,
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// MODAL ELIMINAR EDIFICIO
// =====================================================================
class DeleteEdificioModal extends ConsumerWidget {
  final Edificio edificio;
  const DeleteEdificioModal({super.key, required this.edificio});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(catalogMutationProvider);
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32)),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.delete_sweep_rounded, size: 48, color: Colors.red[600]),
            const SizedBox(height: 16),
            const Text('¿Eliminar edificio?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Los salones de este edificio quedarán inactivos.', style: TextStyle(color: Colors.grey[600]), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.red),
                const SizedBox(width: 10),
                Expanded(child: Text(
                  '${edificio.nombre} (Edificio ${edificio.numero})',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                )),
              ]),
            ),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar'))),
              Expanded(child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.red[600]),
                onPressed: estado.isLoading ? null : () async {
                  await ref.read(catalogMutationProvider.notifier).removeEdificio(edificio.id, edificio.numero);
                  final s = ref.read(catalogMutationProvider);
                  if (!context.mounted) return;
                  if (s.isSuccess) {
                    ref.invalidate(edificiosProvider);
                    ref.invalidate(salonesProvider);
                    ref.invalidate(adminSalonesInactivosProvider);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Edificio eliminado'),
                      backgroundColor: Colors.green,
                    ));
                    ref.read(catalogMutationProvider.notifier).resetState();
                  } else if (s.errorMessage != null) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(s.errorMessage!),
                      backgroundColor: Colors.red,
                    ));
                    ref.read(catalogMutationProvider.notifier).resetState();
                  }
                },
                child: estado.isLoading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Eliminar'),
              )),
            ]),
          ]),
        ),
      ),
    );
  }
}

// =====================================================================
// WIDGETS INTERNOS
// =====================================================================
class _ModalHeader extends StatelessWidget {
  final String title, subtitle; final Color color;
  const _ModalHeader({required this.title, required this.subtitle, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 16, 24),
      decoration: BoxDecoration(color: Colors.blue[50]?.withOpacity(0.4), borderRadius: const BorderRadius.vertical(top: Radius.circular(28)), border: Border(bottom: BorderSide(color: Colors.blue[100]!))),
      child: Row(children: [
        Container(width: 6, height: 44, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.blue[800], fontWeight: FontWeight.w600)),
        ])),
        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
      ]),
    );
  }
}

class _ModalFooter extends StatelessWidget {
  final String label; final VoidCallback onPressed; final bool isLoading;
  const _ModalFooter({required this.label, required this.onPressed, this.isLoading = false});
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.all(24), child: FilledButton(
      style: FilledButton.styleFrom(backgroundColor: const Color(0xFF00338D), minimumSize: const Size(double.infinity, 54), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
      onPressed: isLoading ? null : onPressed,
      child: isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    ));
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF444444))));
}
