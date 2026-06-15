import 'dart:ui';
import 'package:flutter/material.dart';

// =======================================================================
// COMPONENTES REUTILIZABLES (Diseño Homologado y Anti-Overflow)
// =======================================================================

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
  return Row(
    children: [
      Icon(icon, size: 18, color: const Color(0xFF00338D)),
      const SizedBox(width: 8),
      Text(title.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF00338D), letterSpacing: 1.1)),
    ],
  );
}

Widget _buildTextField(String label, {String? initialValue, IconData? icon, String? hint, TextInputType? keyboardType}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF444444))),
      const SizedBox(height: 8),
      TextFormField(
        initialValue: initialValue,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        keyboardType: keyboardType,
        decoration: _inputDecoration(hint: hint, icon: icon),
      ),
    ],
  );
}

// =======================================================================
// MODAL DE CARRERAS (Tabla: carrera)
// =======================================================================
class CarreraFormModal extends StatefulWidget {
  final bool isEditing;
  final String? nombre;
  final String? abreviatura;
  final String? plan;
  final bool activo;

  const CarreraFormModal({
    super.key, 
    this.isEditing = false,
    this.nombre,
    this.abreviatura,
    this.plan,
    this.activo = true,
  });

  @override
  State<CarreraFormModal> createState() => _CarreraFormModalState();
}

class _CarreraFormModalState extends State<CarreraFormModal> {
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _isActive = widget.activo;
  }

  @override
  Widget build(BuildContext context) {
    const colorPrimario = Color(0xFF00338D);
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ModalHeader(
                title: widget.isEditing ? 'Editar Carrera' : 'Nueva Carrera',
                subtitle: widget.isEditing ? 'Modifica el plan de estudios' : 'Registra una nueva oferta académica',
                color: colorPrimario,
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _buildSectionTitle('Información Académica', Icons.school_outlined),
                      const SizedBox(height: 16),
                      _buildTextField('Nombre de la Carrera', initialValue: widget.nombre, hint: 'Ej. Ing. en Sistemas Computacionales'),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildTextField('Abreviatura', initialValue: widget.abreviatura, hint: 'Ej. ISC')),
                          const SizedBox(width: 16),
                          Expanded(child: _buildTextField('Año Plan', initialValue: widget.plan, keyboardType: TextInputType.number, hint: 'Ej. 2020')),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Estado de la Carrera', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        subtitle: Text(_isActive ? 'Activa (Visible en el sistema)' : 'Inactiva (Oculta)', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        value: _isActive,
                        activeColor: colorPrimario,
                        onChanged: (bool value) {
                          setState(() {
                            _isActive = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              _ModalFooter(
                label: widget.isEditing ? 'Guardar Cambios' : 'Crear Carrera',
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// =======================================================================
// MODAL MATERIA (Tabla: materia)
// =======================================================================
class MateriaFormModal extends StatefulWidget {
  final bool isEditing;
  final String carreraDefault;
  final String? nombre;
  final String? semestre;
  final String? area;
  final bool activo;

  const MateriaFormModal({
    super.key, 
    this.isEditing = false, 
    required this.carreraDefault, 
    this.nombre, 
    this.semestre, 
    this.area, 
    this.activo = true
  });

  @override
  State<MateriaFormModal> createState() => _MateriaFormModalState();
}

class _MateriaFormModalState extends State<MateriaFormModal> {
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _isActive = widget.activo;
  }

  @override
  Widget build(BuildContext context) {
    const colorPrimario = Color(0xFF00338D);
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ModalHeader(title: widget.isEditing ? 'Editar Materia' : 'Nueva Materia', subtitle: widget.carreraDefault, color: colorPrimario),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _buildTextField('Nombre de la Materia', initialValue: widget.nombre, hint: 'Ej. Redes de Computadoras'),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildTextField('Semestre', initialValue: widget.semestre, keyboardType: TextInputType.number, hint: '1 - 9')),
                          const SizedBox(width: 16),
                          Expanded(child: _buildTextField('Área', initialValue: widget.area, hint: 'Ej. Profesional')),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Estado de la Materia', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        subtitle: Text(_isActive ? 'Activa' : 'Inactiva', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        value: _isActive,
                        activeColor: colorPrimario,
                        onChanged: (val) => setState(() => _isActive = val),
                      ),
                    ],
                  ),
                ),
              ),
              _ModalFooter(label: widget.isEditing ? 'Guardar Cambios' : 'Registrar Materia', onPressed: () => Navigator.pop(context)),
            ],
          ),
        ),
      ),
    );
  }
}

// =======================================================================
// MODAL SALÓN (Tabla: salon)
// =======================================================================
class SalonFormModal extends StatefulWidget {
  final bool isEditing;
  final String edificioFijo;
  final String? piso; // '0', '1', '2'
  final String? numero; // '04'
  final String? etiqueta;
  final bool activo;

  const SalonFormModal({
    super.key, 
    this.isEditing = false, 
    required this.edificioFijo, 
    this.piso, 
    this.numero, 
    this.etiqueta, 
    this.activo = true
  });

  @override
  State<SalonFormModal> createState() => _SalonFormModalState();
}

class _SalonFormModalState extends State<SalonFormModal> {
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _isActive = widget.activo;
  }

  @override
  Widget build(BuildContext context) {
    const colorPrimario = Color(0xFF00338D);
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ModalHeader(
                title: widget.isEditing ? 'Editar Salón' : 'Nuevo Salón', 
                subtitle: widget.edificioFijo.isEmpty ? 'Especifica el Edificio' : 'Edificio ${widget.edificioFijo}', 
                color: colorPrimario
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Si no traemos un edificio fijo (creando desde catálogo raíz), lo pedimos.
                      if (widget.edificioFijo.isEmpty) ...[
                        _buildTextField('Edificio', hint: 'Ej. 1, 4', keyboardType: TextInputType.number),
                        const SizedBox(height: 16),
                      ],
                      Row(
                        children: [
                          Expanded(child: _buildTextField('Piso', initialValue: widget.piso, hint: '0(PB), 1 o 2', keyboardType: TextInputType.number)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildTextField('N° Salón', initialValue: widget.numero, hint: 'Ej. 04', keyboardType: TextInputType.number)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTextField('Etiqueta', initialValue: widget.etiqueta, hint: 'Ej. Aula General'),
                      const SizedBox(height: 24),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Disponibilidad', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        subtitle: Text(_isActive ? 'Salón en uso' : 'Mantenimiento', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        value: _isActive,
                        activeColor: colorPrimario,
                        onChanged: (val) => setState(() => _isActive = val),
                      ),
                    ],
                  ),
                ),
              ),
              _ModalFooter(label: widget.isEditing ? 'Guardar Cambios' : 'Crear Salón', onPressed: () => Navigator.pop(context)),
            ],
          ),
        ),
      ),
    );
  }
}

// =======================================================================
// MODAL ELIMINAR (Genérico para Catálogos)
// =======================================================================
class DeleteCatalogModal extends StatelessWidget {
  final String title;
  final String subtitle;

  const DeleteCatalogModal({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.delete_sweep_rounded, size: 48, color: Colors.red[600]),
              const SizedBox(height: 16),
              const Text('¿Eliminar registro?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Esta acción no se puede deshacer.', style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.red),
                  const SizedBox(width: 10),
                  Expanded(child: Text('$title\n$subtitle', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                ]),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar'))),
                  Expanded(child: FilledButton(style: FilledButton.styleFrom(backgroundColor: Colors.red[600]), onPressed: () => Navigator.pop(context), child: const Text('Eliminar'))),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

// =======================================================================
// COMPONENTES INTERNOS DE APOYO
// =======================================================================
class _ModalHeader extends StatelessWidget {
  final String title, subtitle;
  final Color color;
  const _ModalHeader({required this.title, required this.subtitle, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 16, 24),
      decoration: BoxDecoration(
        color: Colors.blue[50]?.withOpacity(0.4),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(bottom: BorderSide(color: Colors.blue[100]!)),
      ),
      child: Row(
        children: [
          Container(width: 6, height: 44, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.blue[800], fontWeight: FontWeight.w600)),
          ])),
          IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
        ],
      ),
    );
  }
}

class _ModalFooter extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _ModalFooter({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: FilledButton(
        style: FilledButton.styleFrom(backgroundColor: const Color(0xFF00338D), minimumSize: const Size(double.infinity, 54), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
        onPressed: onPressed,
        child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}