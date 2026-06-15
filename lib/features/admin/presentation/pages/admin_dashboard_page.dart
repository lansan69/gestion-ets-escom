import 'dart:ui';
import 'package:flutter/material.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    const colorPrimario = Color(0xFF00338D);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: colorPrimario,
          foregroundColor: Colors.white,
          elevation: 0,
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Dashboard', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
              Text('ETS ESCOM · Sem. 2026-1', style: TextStyle(fontSize: 12, color: Colors.white70)),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {},
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Container(
              color: Colors.white,
              child: const TabBar(
                labelColor: colorPrimario,
                unselectedLabelColor: Colors.grey,
                indicatorColor: colorPrimario,
                indicatorWeight: 3,
                tabs: [
                  Tab(text: 'Estadísticas'),
                  Tab(text: 'Gestionar'),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            // PESTAÑA 1: Estadísticas
            _buildEstadisticasTab(context),
            
            // PESTAÑA 2: Gestionar (A03)
            _buildGestionarTab(context),
          ],
        ),
      ),
    );
  }

  // =======================================================================
  // PESTAÑA 1: ESTADÍSTICAS (A02)
  // =======================================================================
  Widget _buildEstadisticasTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.amber[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Requieren atención',
                style: TextStyle(color: Colors.amber[800], fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const _AlertCard(label: 'Sin coordinador asignado', count: 12, bgColor: Color(0xFFFFEBEE), textColor: Color(0xFFC62828)),
          const SizedBox(height: 8),
          const _AlertCard(label: 'Sin salón asignado', count: 8, bgColor: Color(0xFFFFF3E0), textColor: Color(0xFFEF6C00)),
          const SizedBox(height: 8),
          const _AlertCard(label: 'Sin fecha asignada', count: 4, bgColor: Color(0xFFFFF3E0), textColor: Color(0xFFEF6C00)),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF00338D),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total ETS programados', style: TextStyle(color: Colors.white70, fontSize: 14)),
                SizedBox(height: 4),
                Text('287', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('ETS registrados este semestre', style: TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text('ETS por Carrera', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          const _StatBar(label: 'ISC 2020', count: 98, maxCount: 150, color: Color(0xFF388E3C)),
          const _StatBar(label: 'ISC 2009', count: 72, maxCount: 150, color: Color(0xFF689F38)),
          const _StatBar(label: 'IIA', count: 64, maxCount: 150, color: Color(0xFF1976D2)),
          const _StatBar(label: 'LCD', count: 43, maxCount: 150, color: Color(0xFFF4511E)),
          const _StatBar(label: 'ISISA', count: 10, maxCount: 150, color: Color(0xFF7B1FA2)),
          const SizedBox(height: 32),
          const Text('ETS por Tipo de Materia', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          const _StatBar(label: 'Profesional', count: 142, maxCount: 150, color: Color(0xFFFB8C00)),
          const _StatBar(label: 'Básica', count: 78, maxCount: 150, color: Color(0xFF388E3C)),
          const _StatBar(label: 'Terminal', count: 48, maxCount: 150, color: Color(0xFFE64A19)),
          const _StatBar(label: 'Institucional', count: 19, maxCount: 150, color: Color(0xFF1E88E5)),
          const SizedBox(height: 80), 
        ],
      ),
    );
  }

  // =======================================================================
  // PESTAÑA 2: GESTIONAR
  // =======================================================================
  Widget _buildGestionarTab(BuildContext context) {
    return Stack(
      children: [
        Container(color: Colors.white),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 100, 
          child: Container(color: const Color(0xFF00338D)),
        ),
        Positioned(
          top: 10,
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Buscar materia...',
                            prefixIcon: const Icon(Icons.search, color: Colors.grey),
                            filled: true,
                            fillColor: Colors.grey[100],
                            contentPadding: const EdgeInsets.symmetric(vertical: 0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFF00338D),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.tune, color: Colors.white),
                          onPressed: () {
                            // TODO: Llamar a FilterCard.show()
                            debugPrint("Abrir filtro");
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Gestión de Exámenes',
                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Administra la oferta de exámenes programados.',
                                style: TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                      
                      SliverList(
                        delegate: SliverChildListDelegate([
                          
                          _ExamListCardAdmin(
                            materia: 'Liderazgo Personal', 
                            profe: 'José Emilio Sánchez Arroyo', 
                            fecha: '19 jun 2026',
                            hora: '10:00:00',
                            salon: 'Salón 1',
                            semestre: 'Semestre 8',
                            status: 'Próximamente', 
                            colorBarra: const Color(0xFFB71C1C) 
                          ),
                          _ExamListCardAdmin(
                            materia: 'Trabajo Terminal II', 
                            profe: 'Elba Mendoza', 
                            fecha: '19 jun 2026',
                            hora: '12:30:00',
                            salon: 'Salón 13',
                            semestre: 'Semestre 8',
                            status: 'Incompleto', 
                            colorBarra: const Color(0xFFB71C1C)
                          ),
                          const SizedBox(height: 80),
                        ]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            backgroundColor: const Color(0xFF00338D),
            foregroundColor: Colors.white,
            shape: const CircleBorder(),
            onPressed: () {
              // NUEVO CÓDIGO: Abre el modal flotante de creación
              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (BuildContext context) {
                  return const _AddExamModal();
                },
              );
            },
            child: const Icon(Icons.add, size: 28),
          ),
        ),
      ],
    );
  }
}

// =======================================================================
// WIDGETS PRIVADOS REUTILIZABLES (Estadísticas)
// =======================================================================

class _AlertCard extends StatelessWidget {
  final String label;
  final int count;
  final Color bgColor;
  final Color textColor;
  const _AlertCard({required this.label, required this.count, required this.bgColor, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: textColor.withOpacity(0.3))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
          Text(count.toString(), style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _StatBar extends StatelessWidget {
  final String label;
  final int count;
  final int maxCount;
  final Color color;
  const _StatBar({required this.label, required this.count, required this.maxCount, required this.color});

  @override
  Widget build(BuildContext context) {
    final double percentage = count / maxCount;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 13))),
          Expanded(
            child: Stack(
              children: [
                Container(height: 16, decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8))),
                FractionallySizedBox(
                  widthFactor: percentage.clamp(0.0, 1.0),
                  child: Container(height: 16, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8))),
                ),
              ],
            ),
          ),
          SizedBox(width: 40, child: Text(count.toString(), textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13))),
        ],
      ),
    );
  }
}

// Widget auxiliar para textos con icono
class _InfoIconText extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoIconText({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
      ],
    );
  }
}

// =======================================================================
// WIDGET PRIVADO: Tarjeta Administrativa de Examen
// =======================================================================
class _ExamListCardAdmin extends StatelessWidget {
  final String materia;
  final String profe;
  final String fecha;
  final String hora;
  final String salon;
  final String semestre;
  final String status;
  final Color colorBarra;

  const _ExamListCardAdmin({
    required this.materia,
    required this.profe,
    required this.fecha,
    required this.hora,
    required this.salon,
    required this.semestre,
    required this.status,
    required this.colorBarra,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16, left: 20, right: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 6,
              decoration: BoxDecoration(
                color: colorBarra,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                materia,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: status.toLowerCase() == 'incompleto' ? Colors.amber[50] : Colors.orange[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                status,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: status.toLowerCase() == 'incompleto' ? Colors.amber[800] : Colors.orange[800],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(profe, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 16,
                          runSpacing: 8,
                          children: [
                            _InfoIconText(icon: Icons.calendar_today_outlined, text: fecha),
                            _InfoIconText(icon: Icons.access_time, text: hora),
                            _InfoIconText(icon: Icons.meeting_room_outlined, text: salon),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _InfoIconText(icon: Icons.school_outlined, text: semestre),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: Colors.grey[200]),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              barrierDismissible: true,
                              builder: (BuildContext context) {
                                return _EditExamModal(
                                  materia: materia,
                                  profe: profe,
                                  fecha: fecha,
                                  hora: hora,
                                  salon: salon,
                                  semestre: semestre,
                                  status: status,
                                  colorBarra: colorBarra,
                                );
                              },
                            );
                          },
                          icon: Icon(Icons.edit_outlined, size: 18, color: Colors.blue[700]),
                          label: Text('Editar', style: TextStyle(color: Colors.blue[700])),
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: () {
                          showDialog(
                              context: context,
                              barrierDismissible: true,
                              builder: (BuildContext context) {
                                return _DeleteExamModal(
                                  materia: materia,
                                  profe: profe,
                                  fecha: fecha,
                                );
                              },
                            );
                          },
                          icon: Icon(Icons.delete_outline, size: 18, color: Colors.red[600]),
                          label: Text('Eliminar', style: TextStyle(color: Colors.red[600])),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =======================================================================
// WIDGET PRIVADO: Modal de Edición (Diseño Premium + Autocompletado)
// =======================================================================
class _EditExamModal extends StatelessWidget {
  final String materia;
  final String profe;
  final String correo;
  final String fecha;
  final String hora;
  final String salon;
  final String semestre;
  final String turno;
  final String carrera;
  final String tipoMateria;
  final String proyecto;
  final String guia;
  final String nota;
  final String status;
  final Color colorBarra;

  const _EditExamModal({
    required this.materia,
    required this.profe,
    this.correo = 'profesor@ipn.mx', 
    required this.fecha,
    required this.hora,
    required this.salon,
    required this.semestre,
    this.turno = 'Matutino',
    this.carrera = 'ISC 2020',
    this.tipoMateria = 'Profesional',
    this.proyecto = '',
    this.guia = '',
    this.nota = '',
    required this.status,
    required this.colorBarra,
  });

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
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue[50]?.withOpacity(0.4),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  border: Border(bottom: BorderSide(color: Colors.blue[100]!)),
                ),
                padding: const EdgeInsets.fromLTRB(24, 24, 16, 24),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 46,
                      decoration: BoxDecoration(color: colorBarra, borderRadius: BorderRadius.circular(6)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(materia, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A))),
                          const SizedBox(height: 2),
                          Text('Editando detalles del ETS', style: TextStyle(fontSize: 13, color: Colors.blue[700], fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)
                      ]),
                      child: IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.grey, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    )
                  ],
                ),
              ),

              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Clasificación Académica', Icons.category_outlined),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildDropdown('Carrera', carrera, ['ISC 2020', 'ISC 2009', 'IIA', 'LCD', 'ISISA'], Icons.school_outlined)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildDropdown('Turno', turno, ['Matutino', 'Vespertino'], Icons.wb_sunny_outlined)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildDropdown('Área de Formación', tipoMateria, ['Científica Básica', 'Profesional', 'Institucional', 'Terminal y de integración'], Icons.account_tree_outlined),
                      const SizedBox(height: 32),

                      _buildSectionTitle('Programación y Espacio', Icons.event_available_outlined),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildTextField('Fecha', fecha, icon: Icons.calendar_today_rounded)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildTextField('Horario', hora, icon: Icons.access_time_rounded)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildAutocomplete('Salón / Laboratorio', salon, ['1203', '1204', '2201', '4003', '4103', 'Laboratorio de Redes']),
                      const SizedBox(height: 32),

                      _buildSectionTitle('Coordinador Evaluador', Icons.badge_outlined),
                      const SizedBox(height: 16),
                      _buildTextField('Nombre completo', profe, icon: Icons.person_outline_rounded),
                      const SizedBox(height: 16),
                      _buildTextField('Correo Institucional', correo, icon: Icons.alternate_email_rounded),
                      const SizedBox(height: 32),

                      _buildSectionTitle('Recursos Adicionales', Icons.folder_open_outlined),
                      const SizedBox(height: 16),
                      _buildFilePicker('Proyecto (Opcional)', null),
                      const SizedBox(height: 16),
                      _buildFilePicker('Guía de Estudio (Opcional)', null),
                      const SizedBox(height: 16),
                      _buildTextField('Nota para el alumno', nota, maxLines: 3, hint: 'Instrucciones especiales para el examen...'),
                    ],
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, -5))
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.check_circle_outline),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF00338D),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    label: const Text('Guardar Cambios', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint, IconData? icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
      filled: true,
      fillColor: const Color(0xFFF8F9FA), 
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[200]!)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[200]!)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF00338D), width: 1.5)),
      prefixIcon: icon != null ? Icon(icon, size: 20, color: const Color(0xFF00338D).withOpacity(0.6)) : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF00338D)),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF00338D), letterSpacing: 1.0),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, String initialValue, {IconData? icon, int maxLines = 1, String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[700])),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          decoration: _inputDecoration(hint: hint, icon: icon),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String currentValue, List<String> items, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[700])),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: items.contains(currentValue) ? currentValue : items.first,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey[500]),
          style: const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500),
          decoration: _inputDecoration(icon: icon),
          items: items.map((String val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
          onChanged: (val) {},
        ),
      ],
    );
  }

  Widget _buildAutocomplete(String label, String initialValue, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[700])),
        const SizedBox(height: 8),
        Autocomplete<String>(
          initialValue: TextEditingValue(text: initialValue),
          optionsBuilder: (TextEditingValue textValue) {
            if (textValue.text.isEmpty) return const Iterable<String>.empty();
            return options.where((opt) => opt.toLowerCase().contains(textValue.text.toLowerCase()));
          },
          fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              onEditingComplete: onEditingComplete,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              decoration: _inputDecoration(hint: 'Escribe para buscar...', icon: Icons.meeting_room_outlined),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(16),
                clipBehavior: Clip.antiAlias,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width - 80,
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      return ListTile(
                        leading: const Icon(Icons.location_on_outlined, size: 18, color: Colors.grey),
                        title: Text(option, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                        onTap: () => onSelected(option),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFilePicker(String label, String? fileName) {
    final hasFile = fileName != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[700])),
        const SizedBox(height: 8),
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // TODO: Lógica para abrir FilePicker
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: hasFile ? Colors.green[50] : const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: hasFile ? Colors.green[300]! : Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Icon(hasFile ? Icons.check_circle : Icons.upload_file_rounded, size: 20, color: hasFile ? Colors.green[600] : const Color(0xFF00338D).withOpacity(0.6)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    fileName ?? 'Toca para explorar archivos...',
                    style: TextStyle(color: hasFile ? Colors.green[800] : Colors.grey[500], fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
// =======================================================================
// WIDGET PRIVADO: Modal de Confirmación para Eliminar (Diseño Premium)
// =======================================================================
class _DeleteExamModal extends StatelessWidget {
  final String materia;
  final String profe;
  final String fecha;

  const _DeleteExamModal({
    required this.materia,
    required this.profe,
    required this.fecha,
  });

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8), // Mismo desenfoque elegante
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32), // Curvas amplias y modernas
            boxShadow: [
              BoxShadow(color: Colors.red.withOpacity(0.15), blurRadius: 40, offset: const Offset(0, 20)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ícono de advertencia flotante
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.delete_sweep_rounded, size: 36, color: Colors.red[600]),
              ),
              const SizedBox(height: 20),
              
              // Título
              const Text(
                '¿Eliminar examen?',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1A1A1A)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              
              // Subtítulo
              Text(
                'Esta acción es irreversible y los alumnos inscritos (si los hay) perderán su registro.',
                style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.4),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // "Mini-tarjeta" recordatoria de lo que se va a borrar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
                      child: Icon(Icons.warning_amber_rounded, size: 20, color: Colors.red[400]),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(materia, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 2),
                          Text('$profe • $fecha', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.grey[300]!, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () => Navigator.pop(context), // Cierra sin hacer nada
                      child: Text('Cancelar', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey[700])),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        // TODO: Lógica para borrar de la base de datos
                        Navigator.pop(context); // Cierra el modal
                      },
                      child: const Text('Sí, eliminar', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =======================================================================
// WIDGET PRIVADO: Modal para Crear Nuevo ETS (A04 - Versión Premium)
// =======================================================================
class _AddExamModal extends StatelessWidget {
  const _AddExamModal();

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
              // --- HEADER DEL MODAL ---
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue[50]?.withOpacity(0.4),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  border: Border(bottom: BorderSide(color: Colors.blue[100]!)),
                ),
                padding: const EdgeInsets.fromLTRB(24, 24, 16, 24),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 46,
                      decoration: BoxDecoration(color: const Color(0xFF00338D), borderRadius: BorderRadius.circular(6)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Nuevo Examen ETS', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A))),
                          const SizedBox(height: 2),
                          Text('Completa la información para dar de alta la oferta', style: TextStyle(fontSize: 12, color: Colors.blue[700], fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)
                      ]),
                      child: IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.grey, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    )
                  ],
                ),
              ),

              // --- CUERPO SCROLLABLE (Formulario Vacío) ---
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // SECCIÓN 1: Materia y Clasificación
                      _buildSectionTitle('Asignatura y Clasificación', Icons.menu_book_outlined),
                      const SizedBox(height: 16),
                      // El campo de materia ahora es un buscador predictivo
                      _buildAutocomplete('Unidad de Aprendizaje (Materia)', '', ['Redes de Computadoras', 'Compiladores', 'Análisis y Diseño de Sistemas', 'Arquitectura de Computadoras', 'Liderazgo Personal', 'Trabajo Terminal II']),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildDropdown('Carrera', 'ISC 2020', ['ISC 2020', 'ISC 2009', 'IIA', 'LCD', 'ISISA'], Icons.school_outlined)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildDropdown('Turno', 'Matutino', ['Matutino', 'Vespertino'], Icons.wb_sunny_outlined)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildDropdown('Área de Formación', 'Profesional', ['Científica Básica', 'Profesional', 'Institucional', 'Terminal y de integración'], Icons.account_tree_outlined),
                      const SizedBox(height: 32),

                      // SECCIÓN 2: Programación
                      _buildSectionTitle('Programación y Espacio', Icons.event_available_outlined),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildTextField('Fecha', '', icon: Icons.calendar_today_rounded, hint: 'Ej. 19 jun 2026')),
                          const SizedBox(width: 16),
                          Expanded(child: _buildTextField('Horario', '', icon: Icons.access_time_rounded, hint: 'Ej. 10:00:00')),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildAutocomplete('Salón / Laboratorio', '', ['1203', '1204', '2201', '4003', '4103', 'Laboratorio de Redes']),
                      const SizedBox(height: 32),

                      // SECCIÓN 3: Contacto
                      _buildSectionTitle('Coordinador Evaluador', Icons.badge_outlined),
                      const SizedBox(height: 16),
                      _buildTextField('Nombre completo', '', icon: Icons.person_outline_rounded, hint: 'Nombre del profesor de ESCOM'),
                      const SizedBox(height: 16),
                      _buildTextField('Correo Institucional', '', icon: Icons.alternate_email_rounded, hint: 'ejemplo@ipn.mx'),
                      const SizedBox(height: 32),

                      // SECCIÓN 4: Recursos
                      _buildSectionTitle('Recursos Adicionales', Icons.folder_open_outlined),
                      const SizedBox(height: 16),
                      _buildFilePicker('Proyecto (Opcional)', null),
                      const SizedBox(height: 16),
                      _buildFilePicker('Guía de Estudio (Opcional)', null),
                      const SizedBox(height: 16),
                      _buildTextField('Nota para el alumno', '', maxLines: 3, hint: 'Instrucciones especiales para el examen...'),
                    ],
                  ),
                ),
              ),

              // --- FOOTER FIJO (Botón Crear) ---
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, -5))
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.add_circle_outline_rounded),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF00338D),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      // TODO: Lógica para enviar el INSERT a Supabase
                      Navigator.pop(context);
                    },
                    label: const Text('Crear Examen', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- MÉTODOS DE REUTILIZACIÓN DE DISEÑO (Duplicados de forma local para compatibilidad) ---

  InputDecoration _inputDecoration({String? hint, IconData? icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
      filled: true,
      fillColor: const Color(0xFFF8F9FA),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[200]!)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[200]!)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF00338D), width: 1.5)),
      prefixIcon: icon != null ? Icon(icon, size: 20, color: const Color(0xFF00338D).withOpacity(0.6)) : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF00338D)),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF00338D), letterSpacing: 1.0),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, String initialValue, {IconData? icon, int maxLines = 1, String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[700])),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue.isEmpty ? null : initialValue,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          decoration: _inputDecoration(hint: hint, icon: icon),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String currentValue, List<String> items, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[700])),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: currentValue,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey[500]),
          style: const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500),
          decoration: _inputDecoration(icon: icon),
          items: items.map((String val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
          onChanged: (val) {},
        ),
      ],
    );
  }

  Widget _buildAutocomplete(String label, String initialValue, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[700])),
        const SizedBox(height: 8),
        Autocomplete<String>(
          initialValue: TextEditingValue(text: initialValue),
          optionsBuilder: (TextEditingValue textValue) {
            if (textValue.text.isEmpty) return const Iterable<String>.empty();
            return options.where((opt) => opt.toLowerCase().contains(textValue.text.toLowerCase()));
          },
          fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              onEditingComplete: onEditingComplete,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              decoration: _inputDecoration(hint: 'Escribe para buscar...', icon: Icons.search_rounded),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(16),
                clipBehavior: Clip.antiAlias,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width - 80,
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      return ListTile(
                        leading: const Icon(Icons.label_important_outline_rounded, size: 18, color: Colors.grey),
                        title: Text(option, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                        onTap: () => onSelected(option),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFilePicker(String label, String? fileName) {
    final hasFile = fileName != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[700])),
        const SizedBox(height: 8),
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: hasFile ? Colors.green[50] : const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: hasFile ? Colors.green[300]! : Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Icon(hasFile ? Icons.check_circle : Icons.upload_file_rounded, size: 20, color: hasFile ? Colors.green[600] : const Color(0xFF00338D).withOpacity(0.6)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    fileName ?? 'Toca para explorar archivos...',
                    style: TextStyle(color: hasFile ? Colors.green[800] : Colors.grey[500], fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}