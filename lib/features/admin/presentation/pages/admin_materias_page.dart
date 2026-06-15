import 'package:flutter/material.dart';
import 'package:gestion_ets_escom/features/admin/presentation/widgets/catalog_modals.dart';
import 'package:gestion_ets_escom/features/admin/presentation/widgets/admin_filter_sheets.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/app_colors.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/background_pattern_painter.dart';

class AdminMateriasPage extends StatelessWidget {
  final String carrera;

  const AdminMateriasPage({super.key, required this.carrera});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDarkBlue,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryDarkBlue,
        shape: const CircleBorder(),
        elevation: 4,
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => MateriaFormModal(carreraDefault: carrera),
          );
        },
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: Stack(
        children: [
          CustomPaint(size: Size.infinite, painter: BackgroundPatternPainter()),
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Header ──────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 4, 16, 20),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Materias',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              carrera,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // ─── Panel blanco ─────────────────────────────────────────────
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.backgroundWhite,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: Column(
                      children: [
                        // BARRA DE BÚSQUEDA Y FILTRO
                        Container(
                          color: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F3F4),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: const TextField(
                                    decoration: InputDecoration(
                                      hintText: 'Buscar materia...',
                                      hintStyle: TextStyle(
                                          color: Colors.grey, fontSize: 15),
                                      prefixIcon: Icon(Icons.search,
                                          color: Colors.grey, size: 22),
                                      border: InputBorder.none,
                                      contentPadding:
                                          EdgeInsets.symmetric(vertical: 12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              InkWell(
                                onTap: () =>
                                    MateriasFilterSheet.show(context),
                                customBorder: const CircleBorder(),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: const BoxDecoration(
                                    color: AppColors.primaryDarkBlue,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.tune_rounded,
                                      color: Colors.white, size: 22),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // LISTA DE MATERIAS
                        Expanded(
                          child: ListView(
                            padding:
                                const EdgeInsets.only(top: 16, bottom: 80),
                            children: [
                              _MateriaCard(
                                title: 'Redes de Computadoras',
                                subtitle: 'Semestre 6 • Profesional',
                                indicatorColor: Colors.blue[700]!,
                                carrera: carrera,
                              ),
                              _MateriaCard(
                                title: 'Compiladores',
                                subtitle:
                                    'Semestre 6 • Ciencias de la Ingeniería',
                                indicatorColor: Colors.purple[600]!,
                                carrera: carrera,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MateriaCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color indicatorColor;
  final String carrera;

  const _MateriaCard({
    required this.title,
    required this.subtitle,
    required this.indicatorColor,
    required this.carrera,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 6,
              decoration: BoxDecoration(
                color: indicatorColor,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16)),
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
                        Text(title,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF222222))),
                        const SizedBox(height: 6),
                        Text(subtitle,
                            style: const TextStyle(
                                fontSize: 13, color: Colors.grey)),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: Colors.grey[100]),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => MateriaFormModal(
                                isEditing: true,
                                carreraDefault: carrera,
                                nombre: title,
                                semestre:
                                    subtitle.split('Semestre ')[1].split(' • ')[0],
                                area: subtitle.split(' • ')[1],
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit_outlined,
                              size: 16, color: AppColors.primaryDarkBlue),
                          label: const Text('Editar',
                              style: TextStyle(
                                  color: AppColors.primaryDarkBlue,
                                  fontSize: 13)),
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => DeleteCatalogModal(
                                  title: title, subtitle: subtitle),
                            );
                          },
                          icon: const Icon(Icons.delete_outline,
                              size: 16, color: Colors.redAccent),
                          label: const Text('Eliminar',
                              style: TextStyle(
                                  color: Colors.redAccent, fontSize: 13)),
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
