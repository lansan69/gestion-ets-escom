import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_ets_escom/features/admin/presentation/providers/admin_materia_providers.dart';
import 'package:gestion_ets_escom/features/admin/presentation/widgets/admin_filter_sheets.dart';
import 'package:gestion_ets_escom/features/admin/presentation/widgets/catalog_modals.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/carrera.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/materia.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/app_colors.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/background_pattern_painter.dart';

class AdminMateriasPage extends ConsumerStatefulWidget {
  final Carrera carrera;
  const AdminMateriasPage({super.key, required this.carrera});

  @override
  ConsumerState<AdminMateriasPage> createState() => _AdminMateriasPageState();
}

class _AdminMateriasPageState extends ConsumerState<AdminMateriasPage> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredAsync =
        ref.watch(adminMateriasFilteredProvider(widget.carrera.id));
    final semestres = ref.watch(adminMateriaSemestresProvider);
    final areaId = ref.watch(adminMateriaAreaProvider);
    final hasFilters = semestres.isNotEmpty || areaId != null;

    return Scaffold(
      backgroundColor: AppColors.primaryDarkBlue,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryDarkBlue,
        shape: const CircleBorder(),
        elevation: 4,
        onPressed: () => showDialog(
          context: context,
          builder: (_) => MateriaFormModal(carrera: widget.carrera),
        ),
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
                // ─── Header ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 4, 16, 20),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Materias',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text(
                              '${widget.carrera.abreviatura} · Plan ${widget.carrera.plan}',
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // ─── Panel blanco ─────────────────────────────────────
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
                                  child: TextField(
                                    controller: _searchCtrl,
                                    onChanged: (v) => ref
                                        .read(adminMateriaSearchProvider
                                            .notifier)
                                        .set(v),
                                    decoration: const InputDecoration(
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
                                onTap: () => MateriasFilterSheet.show(context),
                                customBorder: const CircleBorder(),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: hasFilters
                                            ? AppColors.primaryDarkBlue
                                                .withValues(alpha: 0.85)
                                            : AppColors.primaryDarkBlue,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.tune_rounded,
                                          color: Colors.white, size: 22),
                                    ),
                                    if (hasFilters)
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: Container(
                                          width: 10,
                                          height: 10,
                                          decoration: const BoxDecoration(
                                            color: Colors.orange,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // LISTA DE MATERIAS
                        Expanded(
                          child: filteredAsync.when(
                            loading: () => const Center(
                                child: CircularProgressIndicator()),
                            error: (e, _) => Center(
                              child: Text('Error: $e',
                                  style: const TextStyle(color: Colors.red)),
                            ),
                            data: (materias) {
                              if (materias.isEmpty) {
                                return const Center(
                                  child: Text('No hay materias registradas.',
                                      style: TextStyle(color: Colors.grey)),
                                );
                              }
                              return ListView.builder(
                                padding: const EdgeInsets.only(
                                    top: 16, bottom: 80),
                                itemCount: materias.length,
                                itemBuilder: (_, i) => _MateriaCard(
                                  materia: materias[i],
                                  carrera: widget.carrera,
                                ),
                              );
                            },
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

// ─── Tarjeta de materia ────────────────────────────────────────────────────
class _MateriaCard extends ConsumerWidget {
  final Materia materia;
  final Carrera carrera;

  const _MateriaCard({required this.materia, required this.carrera});

  Color _areaColor() {
    final hex = materia.areaFormacion?.color;
    if (hex == null || hex.isEmpty) return Colors.blueGrey;
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final areaColor = _areaColor();
    final subtitulo =
        'Semestre ${materia.semestre}${materia.areaFormacion != null ? ' · ${materia.areaFormacion!.nombre}' : ''}';

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
                color: areaColor,
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
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(materia.nombre,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF222222))),
                        const SizedBox(height: 6),
                        Text(subtitulo,
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
                          onPressed: () => showDialog(
                            context: context,
                            builder: (_) => MateriaFormModal(
                              carrera: carrera,
                              materia: materia,
                            ),
                          ),
                          icon: const Icon(Icons.edit_outlined,
                              size: 16, color: AppColors.primaryDarkBlue),
                          label: const Text('Editar',
                              style: TextStyle(
                                  color: AppColors.primaryDarkBlue,
                                  fontSize: 13)),
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: () => showDialog(
                            context: context,
                            builder: (_) => _DeleteMateriaDialog(
                              materia: materia,
                              carreraId: carrera.id,
                            ),
                          ),
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

// ─── Diálogo de confirmación de eliminación ────────────────────────────────
class _DeleteMateriaDialog extends ConsumerWidget {
  final Materia materia;
  final String carreraId;

  const _DeleteMateriaDialog(
      {required this.materia, required this.carreraId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(adminMateriaMutationProvider);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.delete_sweep_rounded,
                  size: 48, color: Colors.red[600]),
              const SizedBox(height: 16),
              const Text('¿Eliminar materia?',
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Esta acción no se puede deshacer.',
                  style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: Colors.red),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${materia.nombre}\nSemestre ${materia.semestre}',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                          backgroundColor: Colors.red[600]),
                      onPressed: estado.isLoading
                          ? null
                          : () async {
                              await ref
                                  .read(adminMateriaMutationProvider.notifier)
                                  .removeMateria(materia.id);
                              final s =
                                  ref.read(adminMateriaMutationProvider);
                              if (!context.mounted) return;
                              if (s.isSuccess) {
                                ref.invalidate(adminMateriasRawProvider(
                                    carreraId));
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Materia eliminada'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                ref
                                    .read(
                                        adminMateriaMutationProvider.notifier)
                                    .resetState();
                              } else if (s.errorMessage != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(s.errorMessage!),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                ref
                                    .read(
                                        adminMateriaMutationProvider.notifier)
                                    .resetState();
                              }
                            },
                      child: estado.isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Text('Eliminar'),
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
