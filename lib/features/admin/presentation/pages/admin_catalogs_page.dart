import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_ets_escom/core/providers/core_providers.dart';
import 'package:gestion_ets_escom/features/admin/presentation/providers/admin_salon_providers.dart';
import 'package:gestion_ets_escom/features/admin/presentation/widgets/catalog_modals.dart';
import 'package:gestion_ets_escom/features/admin/presentation/pages/admin_materias_page.dart';
import 'package:gestion_ets_escom/features/admin/presentation/pages/admin_salones_page.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/carrera.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/app_colors.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/background_pattern_painter.dart';
import 'package:gestion_ets_escom/features/user/presentation/providers/carrera_providers.dart';
import 'package:gestion_ets_escom/features/user/presentation/providers/edificios_provider.dart';

class AdminCatalogsPage extends StatelessWidget {
  const AdminCatalogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: AppColors.primaryDarkBlue,
            floatingActionButton: FloatingActionButton(
              backgroundColor: AppColors.primaryDarkBlue,
              shape: const CircleBorder(),
              elevation: 4,
              onPressed: () {
                final tabIndex = DefaultTabController.of(context).index;
                showDialog(
                  context: context,
                  builder: (_) => tabIndex == 0
                      ? const CarreraFormModal()
                      : const EdificioFormModal(),
                );
              },
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            ),
            body: Stack(children: [
              CustomPaint(size: Size.infinite, painter: BackgroundPatternPainter()),
              SafeArea(
                bottom: false,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 12, 8, 20),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Catálogos', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
                      SizedBox(height: 2),
                      Text('Consulta y edita los registros', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    ]),
                  ),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppColors.backgroundWhite,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      child: const Column(children: [
                        TabBar(
                          labelColor: AppColors.primaryDarkBlue,
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: AppColors.primaryDarkBlue,
                          indicatorWeight: 3,
                          labelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                          tabs: [Tab(text: 'Carreras'), Tab(text: 'Edificios')],
                        ),
                        Expanded(child: TabBarView(children: [_CarrerasTab(), _EdificiosTab()])),
                      ]),
                    ),
                  ),
                ]),
              ),
            ]),
          );
        },
      ),
    );
  }
}

// =======================================================================
// PESTAÑA CARRERAS — activas (carrerasProvider) e inactivas (adminCarrerasInactivasProvider)
// =======================================================================
class _CarrerasTab extends ConsumerStatefulWidget {
  const _CarrerasTab();

  @override
  ConsumerState<_CarrerasTab> createState() => _CarrerasTabState();
}

class _CarrerasTabState extends ConsumerState<_CarrerasTab> {
  bool _showInactivas = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              _CarreraToggleChip(
                label: 'Activas',
                selected: !_showInactivas,
                onTap: () => setState(() => _showInactivas = false),
              ),
              const SizedBox(width: 8),
              _CarreraToggleChip(
                label: 'Inactivas',
                selected: _showInactivas,
                onTap: () => setState(() => _showInactivas = true),
              ),
            ],
          ),
        ),
        Expanded(
          child: _showInactivas ? _buildInactivas() : _buildActivas(),
        ),
      ],
    );
  }

  Widget _buildActivas() {
    final async = ref.watch(carrerasProvider);
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
      data: (carreras) {
        if (carreras.isEmpty) {
          return const Center(child: Text('No hay carreras registradas.', style: TextStyle(color: Colors.grey)));
        }
        return ListView.builder(
          padding: const EdgeInsets.only(top: 16, bottom: 80),
          itemCount: carreras.length,
          itemBuilder: (_, i) {
            final c = carreras[i];
            return _CatalogCard(
              title: '${c.abreviatura} · Plan ${c.plan}',
              subtitle: c.nombre,
              countText: 'Activa',
              indicatorColor: const Color(0xFF388E3C),
              onTapGeneral: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => AdminMateriasPage(carrera: c),
              )),
              onEdit: () => showDialog(context: context,
                builder: (_) => CarreraFormModal(isEditing: true, carrera: c)),
              onDelete: () => showDialog(context: context,
                builder: (_) => DeleteCatalogModal(
                  title: '${c.abreviatura} · Plan ${c.plan}',
                  subtitle: c.nombre,
                  entityId: c.id,
                  isCarrera: true,
                )),
            );
          },
        );
      },
    );
  }

  Widget _buildInactivas() {
    final async = ref.watch(adminCarrerasInactivasProvider);
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
      data: (carreras) {
        if (carreras.isEmpty) {
          return const Center(child: Text('No hay carreras inactivas.', style: TextStyle(color: Colors.grey)));
        }
        return ListView.builder(
          padding: const EdgeInsets.only(top: 16, bottom: 80),
          itemCount: carreras.length,
          itemBuilder: (_, i) {
            final c = carreras[i];
            return _InactivaCarreraCard(carrera: c);
          },
        );
      },
    );
  }
}

class _CarreraToggleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CarreraToggleChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryDarkBlue : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.primaryDarkBlue : Colors.grey[300]!),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
    );
  }
}

class _InactivaCarreraCard extends ConsumerWidget {
  final Carrera carrera;
  const _InactivaCarreraCard({required this.carrera});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12, left: 20, right: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 6,
              decoration: BoxDecoration(
                color: Colors.orange[300],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.orange[50],
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text('Inactiva', style: TextStyle(fontSize: 11, color: Colors.orange[700], fontWeight: FontWeight.w600)),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${carrera.abreviatura} · Plan ${carrera.plan}',
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(carrera.nombre, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        try {
                          await ref.read(adminRemoteDatasourceProvider).reactivarCarrera(carrera.id);
                          if (!context.mounted) return;
                          ref.invalidate(adminCarrerasInactivasProvider);
                          ref.invalidate(carrerasProvider);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Carrera reactivada'), backgroundColor: Colors.green),
                          );
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                          );
                        }
                      },
                      child: const Text('Reactivar'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =======================================================================
// PESTAÑA EDIFICIOS — datos reales desde edificiosProvider
// =======================================================================
class _EdificiosTab extends ConsumerWidget {
  const _EdificiosTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(edificiosProvider);
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
      data: (edificios) {
        if (edificios.isEmpty) {
          return const Center(child: Text('No hay edificios registrados.', style: TextStyle(color: Colors.grey)));
        }
        return ListView.builder(
          padding: const EdgeInsets.only(top: 16, bottom: 80),
          itemCount: edificios.length,
          itemBuilder: (_, i) {
            final e = edificios[i];
            return _CatalogCard(
              title: e.nombre,
              subtitle: 'Edificio número ${e.numero}',
              countText: 'Edificio ${e.numero}',
              indicatorColor: Colors.blueGrey,
              onTapGeneral: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => AdminSalonesPage(edificio: e.nombre),
              )),
              onEdit: () => showDialog(context: context,
                builder: (_) => EdificioFormModal(isEditing: true, edificio: e)),
              onDelete: () => showDialog(context: context,
                builder: (_) => DeleteEdificioModal(edificio: e)),
            );
          },
        );
      },
    );
  }
}

// =======================================================================
// TARJETA GENÉRICA
// =======================================================================
class _CatalogCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String countText;
  final Color indicatorColor;
  final VoidCallback? onTapGeneral;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _CatalogCard({
    required this.title,
    required this.subtitle,
    required this.countText,
    required this.indicatorColor,
    this.onTapGeneral,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16, left: 20, right: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTapGeneral,
          child: IntrinsicHeight(
            child: Row(children: [
              Container(
                width: 6,
                decoration: BoxDecoration(
                  color: indicatorColor,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
                ),
              ),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.2))),
                      const SizedBox(width: 8),
                      Text(countText, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryDarkBlue)),
                    ]),
                    const SizedBox(height: 8),
                    Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  ]),
                ),
                Divider(height: 1, color: Colors.grey[200]),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    if (onEdit != null)
                      TextButton.icon(
                        onPressed: onEdit,
                        icon: Icon(Icons.edit_outlined, size: 18, color: Colors.blue[700]),
                        label: Text('Editar', style: TextStyle(color: Colors.blue[700])),
                      ),
                    if (onDelete != null) ...[
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: onDelete,
                        icon: Icon(Icons.delete_outline, size: 18, color: Colors.red[600]),
                        label: Text('Eliminar', style: TextStyle(color: Colors.red[600])),
                      ),
                    ],
                  ]),
                ),
              ])),
            ]),
          ),
        ),
      ),
    );
  }
}
