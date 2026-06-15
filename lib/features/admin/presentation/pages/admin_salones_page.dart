import 'package:flutter/material.dart';
import 'package:gestion_ets_escom/features/admin/presentation/widgets/catalog_modals.dart';
import 'package:gestion_ets_escom/features/admin/presentation/widgets/admin_filter_sheets.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/app_colors.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/background_pattern_painter.dart';

class AdminSalonesPage extends StatelessWidget {
  final String edificio;

  const AdminSalonesPage({super.key, required this.edificio});

  @override
  Widget build(BuildContext context) {
    final numEdificio = edificio.replaceAll(RegExp(r'[^0-9]'), '');

    return Scaffold(
      backgroundColor: AppColors.primaryDarkBlue,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryDarkBlue,
        shape: const CircleBorder(),
        elevation: 4,
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => SalonFormModal(edificioFijo: numEdificio),
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
                            Text(
                              edificio,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Salones y laboratorios disponibles',
                              style: TextStyle(
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
                                      hintText: 'Buscar salón...',
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
                                    SalonesFilterSheet.show(context),
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
                        // LISTA DE SALONES
                        Expanded(
                          child: ListView(
                            padding:
                                const EdgeInsets.only(top: 16, bottom: 80),
                            children: [
                              _SalonCard(
                                  edificio: numEdificio,
                                  piso: '1',
                                  numero: '04',
                                  etiqueta: 'Aula General'),
                              _SalonCard(
                                  edificio: numEdificio,
                                  piso: '0',
                                  numero: '01',
                                  etiqueta: 'Laboratorio Pesado 1'),
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

class _SalonCard extends StatelessWidget {
  final String edificio;
  final String piso;
  final String numero;
  final String etiqueta;

  const _SalonCard({
    required this.edificio,
    required this.piso,
    required this.numero,
    required this.etiqueta,
  });

  @override
  Widget build(BuildContext context) {
    final nomenclatura = '$edificio$piso$numero';
    final pisoTexto = piso == '0' ? 'Planta Baja' : 'Piso $piso';

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
              decoration: const BoxDecoration(
                color: Colors.blueGrey,
                borderRadius: BorderRadius.only(
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
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Salón $nomenclatura',
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    height: 1.2),
                              ),
                            ),
                            Text(
                              pisoTexto,
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryDarkBlue),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(etiqueta,
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
                              builder: (context) => SalonFormModal(
                                isEditing: true,
                                edificioFijo: edificio,
                                piso: piso,
                                numero: numero,
                                etiqueta: etiqueta,
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
                                  title: 'Salón $nomenclatura',
                                  subtitle: 'Edificio $edificio'),
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
