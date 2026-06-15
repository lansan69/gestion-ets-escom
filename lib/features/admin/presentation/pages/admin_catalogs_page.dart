import 'package:flutter/material.dart';
// Importamos los modales
import 'package:gestion_ets_escom/features/admin/presentation/widgets/catalog_modals.dart';
// Importamos las dos nuevas pantallas de detalle
import 'package:gestion_ets_escom/features/admin/presentation/pages/admin_materias_page.dart';
import 'package:gestion_ets_escom/features/admin/presentation/pages/admin_salones_page.dart';

class AdminCatalogsPage extends StatelessWidget {
  const AdminCatalogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    const colorPrimario = Color(0xFF00338D);

    return DefaultTabController(
      length: 2, 
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8F9FA),
            appBar: AppBar(
              backgroundColor: colorPrimario,
              foregroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text('Catálogos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400)),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  color: Colors.white,
                  child: const TabBar(
                    labelColor: colorPrimario,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: colorPrimario,
                    indicatorWeight: 3,
                    labelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                    tabs: [
                      Tab(text: 'Carreras'),
                      Tab(text: 'Edificios'),
                    ],
                  ),
                ),
              ),
            ),
            body: const TabBarView(
              children: [
                _CarrerasTab(),
                _EdificiosTab(),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: colorPrimario,
              shape: const CircleBorder(),
              elevation: 4,
              onPressed: () {
                final tabIndex = DefaultTabController.of(context).index;
                showDialog(
                  context: context,
                  builder: (context) => tabIndex == 0 ? const CarreraFormModal() : const SalonFormModal(edificioFijo: ''),
                );
              },
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            ),
          );
        }
      ),
    );
  }
}

// =======================================================================
// PESTAÑA 1: CARRERAS
// =======================================================================
class _CarrerasTab extends StatelessWidget {
  const _CarrerasTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 16, bottom: 80),
      children: [
        _FigmaCatalogCard(
          title: 'ISC · Plan 2020',
          subtitle: 'Ing. en Sistemas Computacionales',
          countText: '98 Materias',
          indicatorColor: const Color(0xFF388E3C),
          isCarrera: true,
          onTapGeneral: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminMateriasPage(carrera: 'ISC · Plan 2020')));
          },
        ),
        _FigmaCatalogCard(
          title: 'ISC · Plan 2009',
          subtitle: 'Ing. en Sistemas Computacionales',
          countText: '72 Materias',
          indicatorColor: const Color(0xFF689F38),
          isCarrera: true,
          onTapGeneral: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminMateriasPage(carrera: 'ISC · Plan 2009')));
          },
        ),
      ],
    );
  }
}

// =======================================================================
// PESTAÑA 2: EDIFICIOS
// =======================================================================
class _EdificiosTab extends StatelessWidget {
  const _EdificiosTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 16, bottom: 80),
      children: [
        _FigmaCatalogCard(
          title: 'Edificio 1',
          subtitle: 'Aulas de uso general',
          countText: '36 Salones',
          indicatorColor: Colors.blueGrey,
          isCarrera: false,
          onTapGeneral: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminSalonesPage(edificio: 'Edificio 1')));
          },
        ),
        _FigmaCatalogCard(
          title: 'Edificio 4',
          subtitle: 'Laboratorios pesados',
          countText: '12 Salones',
          indicatorColor: Colors.teal,
          isCarrera: false,
          onTapGeneral: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminSalonesPage(edificio: 'Edificio 4')));
          },
        ),
      ],
    );
  }
}

// =======================================================================
// WIDGET: TARJETA MAESTRA
// =======================================================================
class _FigmaCatalogCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String countText;
  final Color indicatorColor;
  final bool isCarrera;
  final VoidCallback? onTapGeneral;

  const _FigmaCatalogCard({
    required this.title,
    required this.subtitle,
    required this.countText,
    required this.indicatorColor,
    required this.isCarrera,
    this.onTapGeneral,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16, left: 20, right: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTapGeneral,
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(width: 6, decoration: BoxDecoration(color: indicatorColor, borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)))),
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
                                Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.2))),
                                const SizedBox(width: 8),
                                Text(countText, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF00338D))),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.grey)),
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
                                  builder: (context) {
                                    if (isCarrera) {
                                      final parts = title.split(' · Plan ');
                                      return CarreraFormModal(
                                        isEditing: true,
                                        nombre: subtitle,
                                        abreviatura: parts.isNotEmpty ? parts[0] : '',
                                        plan: parts.length > 1 ? parts[1] : '',
                                      );
                                    } else {
                                      final numEdificio = title.replaceAll(RegExp(r'[^0-9]'), '');
                                      return SalonFormModal(
                                        isEditing: true,
                                        edificioFijo: numEdificio,
                                        etiqueta: subtitle,
                                      );
                                    }
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
                                  builder: (context) => DeleteCatalogModal(title: title, subtitle: subtitle),
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
        ),
      ),
    );
  }
}