import 'dart:ui';
import 'package:flutter/material.dart';

class AddExamModal extends StatelessWidget {
  const AddExamModal({super.key});

  @override
  Widget build(BuildContext context) {
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
              BoxShadow(color: const Color(0xFF00338D).withOpacity(0.15), blurRadius: 30, offset: const Offset(0, 15)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // HEADER
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue[50]?.withOpacity(0.4),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  border: Border(bottom: BorderSide(color: Colors.blue[100]!)),
                ),
                padding: const EdgeInsets.fromLTRB(24, 24, 16, 24),
                child: Row(
                  children: [
                    Container(width: 6, height: 46, decoration: BoxDecoration(color: const Color(0xFF00338D), borderRadius: BorderRadius.circular(6))),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Nuevo Examen ETS', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A))),
                          Text('Completa la información para dar de alta la oferta', style: TextStyle(fontSize: 12, color: Colors.blue[700], fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.close_rounded, color: Colors.grey), onPressed: () => Navigator.pop(context))
                  ],
                ),
              ),
              // CUERPO
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Asignatura y Clasificación', Icons.menu_book_outlined),
                      const SizedBox(height: 16),
                      _buildAutocomplete('Unidad de Aprendizaje (Materia)', '', ['Redes de Computadoras', 'Compiladores', 'Liderazgo Personal']),
                      const SizedBox(height: 16),
                      Row(children: [
                        Expanded(child: _buildDropdown('Carrera', 'ISC 2020', ['ISC 2020', 'IIA', 'LCD'], Icons.school_outlined)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildDropdown('Turno', 'Matutino', ['Matutino', 'Vespertino'], Icons.wb_sunny_outlined)),
                      ]),
                      const SizedBox(height: 32),
                      _buildSectionTitle('Programación', Icons.event_available_outlined),
                      const SizedBox(height: 16),
                      Row(children: [
                        Expanded(child: _buildTextField('Fecha', '', icon: Icons.calendar_today_rounded)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildTextField('Horario', '', icon: Icons.access_time_rounded)),
                      ]),
                      const SizedBox(height: 32),
                      _buildSectionTitle('Recursos', Icons.folder_open_outlined),
                      const SizedBox(height: 16),
                      _buildFilePicker('Proyecto (Opcional)', null),
                    ],
                  ),
                ),
              ),
              // FOOTER
              Container(
                padding: const EdgeInsets.all(24),
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF00338D), minimumSize: const Size(double.infinity, 52)),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Crear Examen'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- MÉTODOS HELPER ---

  InputDecoration _inputDecoration({String? hint, IconData? icon}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF8F9FA),
      // Esto aprieta los márgenes internos para dar más espacio al texto
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      // Hacemos el ícono de la izquierda un poco más pequeño (de 20 a 18)
      prefixIcon: icon != null ? Icon(icon, size: 18, color: const Color(0xFF00338D)) : null,
      // Le quitamos el ancho por defecto que roba mucho espacio
      prefixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 36),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(children: [Icon(icon, size: 18, color: const Color(0xFF00338D)), const SizedBox(width: 8), Text(title.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF00338D)))]);
  }

  Widget _buildTextField(String label, String initialValue, {IconData? icon, int maxLines = 1, String? hint}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      TextFormField(initialValue: initialValue, maxLines: maxLines, decoration: _inputDecoration(hint: hint, icon: icon)),
    ]);
  }

 Widget _buildDropdown(String label, String currentValue, List<String> items, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color.fromARGB(255, 112, 110, 110))),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: items.contains(currentValue) ? currentValue : items.first,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey[500], size: 20),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            // 1. Ya NO usamos prefixIcon aquí para que Flutter no reserve 48px muertos
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
          // 2. Construimos la vista personalizada del ítem seleccionado
          selectedItemBuilder: (BuildContext context) {
            return items.map<Widget>((String val) {
              return Row(
                children: [
                  // Ponemos el ícono manualmente
                  Icon(icon, size: 18, color: const Color(0xFF00338D)),
                  const SizedBox(width: 8),
                  // 3. Este Expanded obliga al texto a cortarse ("...") si no cabe
                  Expanded(
                    child: Text(
                      val,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              );
            }).toList();
          },
          // Esta es la lista desplegable normal
          items: items.map((String val) => DropdownMenuItem(
            value: val, 
            child: Text(val, style: const TextStyle(fontSize: 13)),
          )).toList(),
          onChanged: (val) {},
        ),
      ],
    );
  }


  Widget _buildAutocomplete(String label, String initialValue, List<String> options) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      Autocomplete<String>(
        optionsBuilder: (value) => value.text.isEmpty ? const Iterable<String>.empty() : options.where((o) => o.toLowerCase().contains(value.text.toLowerCase())),
        fieldViewBuilder: (context, controller, focusNode, onEditingComplete) => TextFormField(controller: controller, focusNode: focusNode, decoration: _inputDecoration(hint: 'Buscar...', icon: Icons.search)),
      ),
    ]);
  }

  Widget _buildFilePicker(String label, String? fileName) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(16)),
        child: const Row(children: [Icon(Icons.upload_file), SizedBox(width: 10), Text('Seleccionar archivo')]),
      ),
    ]);
  }
}