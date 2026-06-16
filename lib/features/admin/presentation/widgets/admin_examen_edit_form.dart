// ============================================================
// NOMBRE: admin_examen_edit_form.dart
// USO: Formulario de edición de un examen ETS para el administrador.
//      Carga catálogos frescos de Supabase al abrirse, permite
//      editar todos los campos relevantes y guarda vía
//      UpdateExamenCompleto use case.
// ============================================================
import 'dart:typed_data';
import 'dart:ui';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gestion_ets_escom/core/providers/core_providers.dart';
import 'package:gestion_ets_escom/core/services/launcher_service.dart';
import 'package:gestion_ets_escom/features/admin/domain/entities/examen_update_params.dart';
import 'package:gestion_ets_escom/features/admin/presentation/providers/admin_filter_providers.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/examen.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/app_colors.dart';

Color? _colorFromHex(String? hex) {
  if (hex == null) return null;
  final h = hex.replaceAll('#', '').trim();
  if (h.length != 6) return null;
  return Color(int.parse('FF$h', radix: 16));
}

class _ColorDot extends StatelessWidget {
  final String? colorHex;
  const _ColorDot({this.colorHex});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _colorFromHex(colorHex) ?? Colors.grey[400],
      ),
    );
  }
}

// =============================================================================
// WIDGET PRINCIPAL
// =============================================================================
class AdminExamenEditForm extends ConsumerStatefulWidget {
  final Examen examen;
  final Color colorBarra;

  const AdminExamenEditForm({
    super.key,
    required this.examen,
    required this.colorBarra,
  });

  @override
  ConsumerState<AdminExamenEditForm> createState() =>
      _AdminExamenEditFormState();
}

class _AdminExamenEditFormState extends ConsumerState<AdminExamenEditForm> {
  final _formKey = GlobalKey<FormState>();

  // ── Catalogs ────────────────────────────────────────────────────────────────
  bool _isLoadingCatalogs = true;
  List<Map<String, dynamic>> _carreras = [];
  List<Map<String, dynamic>> _areas = [];
  List<Map<String, dynamic>> _salones = [];

  // ── Form state ──────────────────────────────────────────────────────────────
  late String _selectedCarreraId;
  String? _selectedAreaId;
  late String _selectedSalonId;
  late String _selectedSalonLabel;
  late DateTime _selectedFecha;
  late String _selectedHora;

  late final TextEditingController _profesorNombreCtrl;
  late final TextEditingController _correoCtrl;
  late final TextEditingController _notasCtrl;
  late final TextEditingController _fechaDisplayCtrl;
  late final TextEditingController _horaDisplayCtrl;

  // ── File state ──────────────────────────────────────────────────────────────
  String? _newGuiaFileName;
  Uint8List? _newGuiaBytes;
  String? _newProyectoFileName;
  Uint8List? _newProyectoBytes;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.examen;
    _selectedCarreraId = e.materia.carrera.id;
    _selectedAreaId = e.materia.areaFormacion?.id;
    _selectedSalonId = e.salon.id;
    _selectedSalonLabel = e.salon.etiquetaSalon ?? '';

    // Seed carrera so the dropdown always has at least the current value,
    // even if the Supabase fetch fails or returns nothing.
    _carreras = [
      {
        'id': e.materia.carrera.id,
        'nombre': e.materia.carrera.nombre,
        'abreviatura': e.materia.carrera.abreviatura,
        'plan': e.materia.carrera.plan,
        'color': null,
      },
    ];
    _selectedFecha = e.fecha;
    _selectedHora = e.hora;

    _profesorNombreCtrl = TextEditingController(text: e.profesor.nombre);
    _correoCtrl = TextEditingController(text: e.profesor.correo);
    _notasCtrl = TextEditingController(text: e.notas ?? '');
    _fechaDisplayCtrl = TextEditingController(text: _formatFecha(e.fecha));
    _horaDisplayCtrl = TextEditingController(text: _horaDisplay(e.hora));

    _loadCatalogs();
  }

  @override
  void dispose() {
    _profesorNombreCtrl.dispose();
    _correoCtrl.dispose();
    _notasCtrl.dispose();
    _fechaDisplayCtrl.dispose();
    _horaDisplayCtrl.dispose();
    super.dispose();
  }

  // ── Catalog fetch ────────────────────────────────────────────────────────────
  Future<void> _loadCatalogs() async {
    try {
      final datasource = ref.read(adminRemoteDatasourceProvider);
      final results = await Future.wait([
        datasource.getCatalogCarreras(),
        datasource.getCatalogAreas(),
        datasource.getCatalogSalonesActivos(),
      ]);
      if (!mounted) return;

      Map<String, Map<String, dynamic>> dedup(List<Map<String, dynamic>> raw) {
        final m = <String, Map<String, dynamic>>{};
        for (final row in raw) {
          m[row['id'] as String] = row;
        }
        return m;
      }

      final carreras = dedup(results[0]).values.toList();
      final areas = dedup(results[1]).values.toList();
      final salones = dedup(results[2]).values.toList();

      setState(() {
        // Never overwrite with an empty list — keep seed/prior data on empty fetch
        if (carreras.isNotEmpty) _carreras = carreras;
        if (areas.isNotEmpty) _areas = areas;
        if (salones.isNotEmpty) _salones = salones;
        _isLoadingCatalogs = false;
        // Clamp carrera selection if the stored ID fell out of the fetched list
        if (!_carreras.any((c) => c['id'] == _selectedCarreraId)) {
          _selectedCarreraId = _carreras.first['id'] as String;
        }
      });
    } catch (_) {
      if (mounted) setState(() => _isLoadingCatalogs = false);
    }
  }

  // ── Date / time helpers ──────────────────────────────────────────────────────
  String _formatFecha(DateTime d) {
    const meses = [
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
    return '${d.day} ${meses[d.month - 1]} ${d.year}';
  }

  String _horaDisplay(String hora) {
    final parts = hora.split(':');
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  }

  // Fix 3 — date picker
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedFecha,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedFecha = picked;
        _fechaDisplayCtrl.text = _formatFecha(picked);
      });
    }
  }

  // Fix 4 — time picker
  Future<void> _pickTime() async {
    final parts = _selectedHora.split(':');
    final initial = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null && mounted) {
      final h = picked.hour.toString().padLeft(2, '0');
      final m = picked.minute.toString().padLeft(2, '0');
      setState(() {
        _selectedHora = '$h:$m:00';
        _horaDisplayCtrl.text = '$h:$m';
      });
    }
  }

  // ── File picker ──────────────────────────────────────────────────────────────
  Future<void> _pickFile(bool isGuia) async {
    const typeGroup = XTypeGroup(
      label: 'PDFs',
      extensions: ['pdf'],
      mimeTypes: ['application/pdf'],
    );
    final file = await openFile(acceptedTypeGroups: [typeGroup]);
    if (file == null || !mounted) return;
    final bytes = await file.readAsBytes();
    setState(() {
      if (isGuia) {
        _newGuiaFileName = file.name;
        _newGuiaBytes = bytes;
      } else {
        _newProyectoFileName = file.name;
        _newProyectoBytes = bytes;
      }
    });
  }

  // ── Save ─────────────────────────────────────────────────────────────────────
  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSaving = true);

    // Upload guía if a new file was selected
    String? guiaToSave = widget.examen.documentoGuia;
    if (_newGuiaFileName != null && _newGuiaBytes != null) {
      final result = await ref
          .read(adminRepositoryProvider)
          .uploadExamenFile(_newGuiaFileName!, _newGuiaBytes!);
      if (!mounted) return;
      bool failed = false;
      result.fold((f) {
        failed = true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al subir guía: ${f.message}'),
            backgroundColor: Colors.red[700],
          ),
        );
      }, (fileName) => guiaToSave = fileName);
      if (failed) {
        setState(() => _isSaving = false);
        return;
      }
    }

    // Upload proyecto if a new file was selected
    String? proyectoToSave = widget.examen.documentoProyecto;
    if (_newProyectoFileName != null && _newProyectoBytes != null) {
      final result = await ref
          .read(adminRepositoryProvider)
          .uploadExamenFile(_newProyectoFileName!, _newProyectoBytes!);
      if (!mounted) return;
      bool failed = false;
      result.fold((f) {
        failed = true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al subir proyecto: ${f.message}'),
            backgroundColor: Colors.red[700],
          ),
        );
      }, (fileName) => proyectoToSave = fileName);
      if (failed) {
        setState(() => _isSaving = false);
        return;
      }
    }

    final params = ExamenUpdateParams(
      examenId: widget.examen.id,
      materiaId: widget.examen.materia.id,
      carreraId: _selectedCarreraId,
      areaFormacionId: _selectedAreaId,
      profesorId: widget.examen.profesor.id,
      salonId: _selectedSalonId,
      fecha: _selectedFecha,
      hora: _selectedHora,
      documentoGuia: guiaToSave,
      documentoProyecto: proyectoToSave,
      notas: _notasCtrl.text.trim().isEmpty ? null : _notasCtrl.text.trim(),
    );

    final result = await ref.read(updateExamenCompletoProvider).call(params);
    if (!mounted) return;

    result.fold(
      (f) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: ${f.message}'),
            backgroundColor: Colors.red[700],
          ),
        );
      },
      (_) {
        ref.invalidate(adminExamenesProvider);
        final messenger = ScaffoldMessenger.of(context);
        Navigator.pop(context);
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Examen actualizado correctamente'),
            backgroundColor: AppColors.primaryDarkBlue,
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final turno =
        widget.examen.turno.name[0].toUpperCase() +
        widget.examen.turno.name.substring(1);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00338D).withValues(alpha: 0.15),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              Flexible(
                child: _isLoadingCatalogs
                    ? const SizedBox(
                        height: 200,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryDarkBlue,
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle(
                                'Clasificación Académica',
                                Icons.category_outlined,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(child: _buildCarreraDropdown()),
                                  const SizedBox(width: 16),
                                  Expanded(child: _buildTurnoField(turno)),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildAreaDropdown(),
                              const SizedBox(height: 32),
                              _buildSectionTitle(
                                'Programación y Espacio',
                                Icons.event_available_outlined,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(child: _buildDatePickerField()),
                                  const SizedBox(width: 16),
                                  Expanded(child: _buildTimePickerField()),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildSalonAutocomplete(),
                              const SizedBox(height: 32),
                              _buildSectionTitle(
                                'Coordinador Evaluador',
                                Icons.badge_outlined,
                              ),
                              const SizedBox(height: 16),
                              _buildLabeledField(
                                'Nombre',
                                _profesorNombreCtrl,
                                Icons.person_outline_rounded,
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                    ? 'Ingresa el nombre del coordinador'
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              _buildLabeledField(
                                'Correo Institucional',
                                _correoCtrl,
                                Icons.alternate_email_rounded,
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                    ? 'Ingresa el correo institucional'
                                    : null,
                              ),
                              const SizedBox(height: 32),
                              _buildSectionTitle(
                                'Recursos Adicionales',
                                Icons.folder_open_outlined,
                              ),
                              const SizedBox(height: 16),
                              _buildFilePicker(
                                'Guía de Estudio (Opcional)',
                                widget.examen.documentoGuia,
                                _newGuiaFileName,
                                isGuia: true,
                              ),
                              const SizedBox(height: 16),
                              _buildFilePicker(
                                'Proyecto (Opcional)',
                                widget.examen.documentoProyecto,
                                _newProyectoFileName,
                                isGuia: false,
                              ),
                              const SizedBox(height: 16),
                              _buildNotasField(),
                            ],
                          ),
                        ),
                      ),
              ),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // HEADER
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue[50]?.withValues(alpha: 0.4),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(bottom: BorderSide(color: Colors.blue[100]!)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 24, 16, 24),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 46,
            decoration: BoxDecoration(
              color: widget.colorBarra,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.examen.materia.nombre,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Editando detalles del ETS',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(
                Icons.close_rounded,
                color: Colors.grey,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // FOOTER
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: FilledButton.icon(
          icon: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.check_circle_outline),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF00338D),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          onPressed: _isSaving ? null : _save,
          label: Text(
            _isSaving ? 'Guardando...' : 'Guardar Cambios',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // SHARED HELPERS
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF00338D)),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Color(0xFF00338D),
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.grey[700],
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint, IconData? icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
      filled: true,
      fillColor: const Color(0xFFF8F9FA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF00338D), width: 1.5),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      prefixIcon: icon != null
          ? Icon(
              icon,
              size: 20,
              color: const Color(0xFF00338D).withValues(alpha: 0.6),
            )
          : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // STANDARD FIELDS
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildTurnoField(String turno) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Turno'),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: turno,
          readOnly: true,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
          decoration: _inputDecoration(icon: Icons.wb_sunny_outlined),
        ),
      ],
    );
  }

  Widget _buildLabeledField(
    String label,
    TextEditingController controller,
    IconData? icon, {
    int maxLines = 1,
    String? hint,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          decoration: _inputDecoration(hint: hint, icon: icon),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildNotasField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Nota para el alumno'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _notasCtrl,
          maxLines: 4,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          decoration: _inputDecoration(
            hint: 'Instrucciones especiales para el examen...',
          ),
        ),
      ],
    );
  }

  // Fix 3 — date picker field
  Widget _buildDatePickerField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Fecha'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _fechaDisplayCtrl,
          readOnly: true,
          onTap: _pickDate,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
          decoration: _inputDecoration(icon: Icons.calendar_today_rounded),
        ),
      ],
    );
  }

  // Fix 4 — time picker field
  Widget _buildTimePickerField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Horario'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _horaDisplayCtrl,
          readOnly: true,
          onTap: _pickTime,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
          decoration: _inputDecoration(icon: Icons.access_time_rounded),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Fix 1 — CARRERA DROPDOWN (value-controlled, color chip per item)
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildCarreraDropdown() {
    final validId = _carreras.any((c) => c['id'] == _selectedCarreraId)
        ? _selectedCarreraId
        : (_carreras.first['id'] as String);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Carrera'),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          key: ValueKey(validId),
          initialValue: validId,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.grey[500],
          ),
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
          decoration: _inputDecoration(icon: Icons.school_outlined),
          selectedItemBuilder: (context) => _carreras
              .map(
                (c) => Row(
                  children: [
                    _ColorDot(colorHex: c['color'] as String?),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${c['abreviatura']} ${c['plan']}',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
          items: _carreras
              .map(
                (c) => DropdownMenuItem<String>(
                  value: c['id'] as String,
                  child: Row(
                    children: [
                      _ColorDot(colorHex: c['color'] as String?),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${c['abreviatura']} ${c['plan']} — ${c['nombre']}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedCarreraId = val);
          },
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Fix 2 — ÁREA DROPDOWN (value-controlled, color chip per item)
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildAreaDropdown() {
    final effectiveAreaId = _areas.any((a) => a['id'] == _selectedAreaId)
        ? _selectedAreaId
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Área de Formación'),
        const SizedBox(height: 8),
        DropdownButtonFormField<String?>(
          key: ValueKey(effectiveAreaId),
          initialValue: effectiveAreaId,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.grey[500],
          ),
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
          decoration: _inputDecoration(icon: Icons.account_tree_outlined),
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Text(
                'Sin área',
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
              ),
            ),
            ..._areas.map(
              (a) => DropdownMenuItem<String?>(
                value: a['id'] as String,
                child: Row(
                  children: [
                    _ColorDot(colorHex: a['color'] as String?),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        a['nombre'] as String,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          onChanged: (val) => setState(() => _selectedAreaId = val),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Fix 5 — SALÓN AUTOCOMPLETE (constrained overlay, filters already-fetched list)
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildSalonAutocomplete() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Salón / Laboratorio'),
        const SizedBox(height: 8),
        Autocomplete<Map<String, dynamic>>(
          initialValue: TextEditingValue(text: _selectedSalonLabel),
          optionsBuilder: (tv) {
            if (_salones.isEmpty) return const [];
            if (tv.text.isEmpty) return _salones;
            final term = tv.text.toLowerCase();
            return _salones.where((s) {
              final label = (s['etiqueta_salon'] as String? ?? '')
                  .toLowerCase();
              final raw = '${s['edificio']}${s['piso']}${s['numero_salon']}';
              return label.contains(term) || raw.contains(term);
            });
          },
          displayStringForOption: (s) =>
              s['etiqueta_salon'] as String? ??
              '${s['edificio']}-${s['piso']}-${s['numero_salon']}',
          onSelected: (s) => setState(() {
            _selectedSalonId = s['id'] as String;
            _selectedSalonLabel = s['etiqueta_salon'] as String? ?? '';
          }),
          fieldViewBuilder: (ctx, ctrl, focusNode, onDone) => TextFormField(
            controller: ctrl,
            focusNode: focusNode,
            onEditingComplete: onDone,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            decoration: _inputDecoration(
              hint: 'Buscar salón...',
              icon: Icons.meeting_room_outlined,
            ),
          ),
          optionsViewBuilder: (ctx, onSelected, options) => Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(16),
              clipBehavior: Clip.antiAlias,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 250),
                child: SizedBox(
                  width: MediaQuery.of(ctx).size.width - 80,
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (_, i) {
                      final s = options.elementAt(i);
                      final label =
                          s['etiqueta_salon'] as String? ??
                          '${s['edificio']}-${s['piso']}-${s['numero_salon']}';
                      return ListTile(
                        leading: const Icon(
                          Icons.meeting_room_outlined,
                          size: 18,
                          color: Colors.grey,
                        ),
                        title: Text(
                          label,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onTap: () => onSelected(s),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // FILE PICKER ROW
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildFilePicker(
    String label,
    String? currentFileName,
    String? newFileName, {
    required bool isGuia,
  }) {
    final displayFileName = newFileName ?? currentFileName;
    final hasNew = newFileName != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: displayFileName != null
                  ? GestureDetector(
                      onTap: !hasNew
                          ? () => LauncherService().openPdf(displayFileName)
                          : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: hasNew ? Colors.amber[50] : Colors.green[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: hasNew
                                ? Colors.amber[300]!
                                : Colors.green[300]!,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.picture_as_pdf,
                              size: 18,
                              color: hasNew
                                  ? Colors.amber[700]
                                  : Colors.green[700],
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                displayFileName,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: hasNew
                                      ? Colors.amber[800]
                                      : Colors.green[800],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (hasNew) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber[700],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Nuevo',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    )
                  : Text(
                      'Sin archivo',
                      style: TextStyle(color: Colors.grey[500], fontSize: 13),
                    ),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: () => _pickFile(isGuia),
              icon: const Icon(Icons.upload_file, size: 16),
              label: Text(displayFileName != null ? 'Cambiar' : 'Seleccionar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryDarkBlue,
                side: const BorderSide(color: AppColors.primaryDarkBlue),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                textStyle: const TextStyle(fontSize: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
