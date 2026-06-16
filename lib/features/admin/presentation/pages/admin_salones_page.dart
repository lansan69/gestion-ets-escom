import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_ets_escom/core/utils/text_utils.dart';
import 'package:gestion_ets_escom/features/admin/presentation/providers/admin_salon_providers.dart';
import 'package:gestion_ets_escom/features/admin/presentation/providers/catalog_provider.dart';
import 'package:gestion_ets_escom/features/admin/presentation/widgets/admin_filter_sheets.dart';
import 'package:gestion_ets_escom/features/admin/presentation/widgets/catalog_modals.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/salon.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/app_colors.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/background_pattern_painter.dart';
import 'package:gestion_ets_escom/features/user/presentation/providers/salones_providers.dart';

class AdminSalonesPage extends ConsumerStatefulWidget {
  final String edificio;

  const AdminSalonesPage({super.key, required this.edificio});

  @override
  ConsumerState<AdminSalonesPage> createState() => _AdminSalonesPageState();
}

class _AdminSalonesPageState extends ConsumerState<AdminSalonesPage> {
  final _searchCtrl = TextEditingController();
  late final int _edificioNum;
  bool _showInactivos = false;

  @override
  void initState() {
    super.initState();
    _edificioNum =
        int.tryParse(widget.edificio.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    // Limpiar búsqueda/filtros después del primer frame para no modificar
    // providers durante el build (restricción de Riverpod).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(adminSalonSearchProvider.notifier).clear();
      ref.read(adminSalonPisoFilterProvider.notifier).clear();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  static String _pisoKeyword(int piso) {
    switch (piso) {
      case 0: return 'planta baja';
      case 1: return 'piso 1';
      case 2: return 'piso 2';
      default: return 'piso $piso';
    }
  }

  List<Salon> _applyFilters(List<Salon> all, String search, Set<int> pisos) {
    var list = all.where((s) => s.edificio == _edificioNum).toList();

    if (search.isNotEmpty) {
      final q = removeDiacritics(search);
      list = list.where((s) {
        // Keyword "salon" muestra todos los salones.
        if ('salon'.contains(q)) return true;
        final nomenclatura = removeDiacritics(
            '${s.edificio}${s.piso}${s.numeroSalon.toString().padLeft(2, '0')}');
        final etiqueta = removeDiacritics(s.etiquetaSalon ?? '');
        final pisoLabel = removeDiacritics(_pisoKeyword(s.piso));
        return nomenclatura.contains(q) || etiqueta.contains(q) || pisoLabel.contains(q);
      }).toList();
    }

    if (pisos.isNotEmpty) {
      list = list.where((s) => pisos.contains(s.piso)).toList();
    }

    list.sort((a, b) {
      final pisoCmp = a.piso.compareTo(b.piso);
      return pisoCmp != 0 ? pisoCmp : a.numeroSalon.compareTo(b.numeroSalon);
    });

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final salonesAsync = ref.watch(salonesProvider);
    final inactivosAsync = ref.watch(adminSalonesInactivosProvider);
    final search = ref.watch(adminSalonSearchProvider);
    final pisos = ref.watch(adminSalonPisoFilterProvider);
    final hasFilters = pisos.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.primaryDarkBlue,
      floatingActionButton: _showInactivos
          ? null
          : FloatingActionButton(
              backgroundColor: AppColors.primaryDarkBlue,
              shape: const CircleBorder(),
              elevation: 4,
              onPressed: () => showDialog(
                context: context,
                builder: (_) => SalonFormModal(edificioFijo: '$_edificioNum'),
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
                // ─── Header ──────────────────────────────────────────────
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
                              widget.edificio,
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
                // ─── Panel blanco ─────────────────────────────────────────
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
                                        .read(adminSalonSearchProvider.notifier)
                                        .set(v),
                                    decoration: const InputDecoration(
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
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: const BoxDecoration(
                                        color: AppColors.primaryDarkBlue,
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

                        // TOGGLE ACTIVOS / INACTIVOS
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                          child: Row(
                            children: [
                              _TabToggle(
                                label: 'Activos',
                                selected: !_showInactivos,
                                onTap: () =>
                                    setState(() => _showInactivos = false),
                              ),
                              const SizedBox(width: 8),
                              _TabToggle(
                                label: 'Inactivos',
                                selected: _showInactivos,
                                onTap: () =>
                                    setState(() => _showInactivos = true),
                              ),
                            ],
                          ),
                        ),

                        // LISTA DE SALONES
                        Expanded(
                          child: _showInactivos
                              ? inactivosAsync.when(
                                  loading: () => const Center(
                                      child: CircularProgressIndicator()),
                                  error: (e, _) => Center(
                                    child: Text('Error: $e',
                                        style: const TextStyle(
                                            color: Colors.red)),
                                  ),
                                  data: (all) {
                                    final salones =
                                        _applyFilters(all, search, pisos);
                                    if (salones.isEmpty) {
                                      return const Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.check_circle_outline,
                                                color: Colors.green, size: 40),
                                            SizedBox(height: 8),
                                            Text('No hay salones inactivos',
                                                style: TextStyle(
                                                    color: Colors.grey)),
                                          ],
                                        ),
                                      );
                                    }
                                    return ListView.builder(
                                      padding: const EdgeInsets.only(
                                          top: 16, bottom: 80),
                                      itemCount: salones.length,
                                      itemBuilder: (_, i) =>
                                          _SalonInactivoCard(
                                        salon: salones[i],
                                        edificioNum: _edificioNum,
                                      ),
                                    );
                                  },
                                )
                              : salonesAsync.when(
                                  loading: () => const Center(
                                      child: CircularProgressIndicator()),
                                  error: (e, _) => Center(
                                    child: Text('Error: $e',
                                        style: const TextStyle(
                                            color: Colors.red)),
                                  ),
                                  data: (all) {
                                    final salones =
                                        _applyFilters(all, search, pisos);
                                    if (salones.isEmpty) {
                                      return const Center(
                                        child: Text(
                                          'No hay salones registrados.',
                                          style:
                                              TextStyle(color: Colors.grey),
                                        ),
                                      );
                                    }
                                    return ListView.builder(
                                      padding: const EdgeInsets.only(
                                          top: 16, bottom: 80),
                                      itemCount: salones.length,
                                      itemBuilder: (_, i) => _SalonCard(
                                        salon: salones[i],
                                        edificioNum: _edificioNum,
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

// ─── Toggle chip Activos / Inactivos ─────────────────────────────────────────
class _TabToggle extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabToggle(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryDarkBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? AppColors.primaryDarkBlue
                : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}

// ─── Tarjeta de salón activo ─────────────────────────────────────────────────
class _SalonCard extends ConsumerWidget {
  final Salon salon;
  final int edificioNum;

  const _SalonCard({required this.salon, required this.edificioNum});

  String get _nomenclatura =>
      '$edificioNum${salon.piso}${salon.numeroSalon.toString().padLeft(2, '0')}';

  String get _pisoLabel {
    switch (salon.piso) {
      case 0:
        return 'Planta Baja';
      case 1:
        return 'Piso 1';
      case 2:
        return 'Piso 2';
      default:
        return 'Piso ${salon.piso}';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Salón $_nomenclatura',
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                height: 1.2),
                          ),
                        ),
                        Text(
                          _pisoLabel,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDarkBlue),
                        ),
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
                            builder: (_) => SalonFormModal(
                              isEditing: true,
                              edificioFijo: '$edificioNum',
                              salon: salon,
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
                            builder: (_) => DeleteCatalogModal(
                              title: 'Salón $_nomenclatura',
                              subtitle: _pisoLabel,
                              entityId: salon.id,
                              isCarrera: false,
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

// ─── Tarjeta de salón inactivo (con botón Reactivar) ─────────────────────────
class _SalonInactivoCard extends ConsumerWidget {
  final Salon salon;
  final int edificioNum;

  const _SalonInactivoCard({required this.salon, required this.edificioNum});

  String get _nomenclatura =>
      '$edificioNum${salon.piso}${salon.numeroSalon.toString().padLeft(2, '0')}';

  String get _pisoLabel {
    switch (salon.piso) {
      case 0:
        return 'Planta Baja';
      case 1:
        return 'Piso 1';
      case 2:
        return 'Piso 2';
      default:
        return 'Piso ${salon.piso}';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(catalogMutationProvider);

    return Container(
      margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange[200]!),
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
                color: Colors.orange[300],
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
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Salón $_nomenclatura',
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    height: 1.2),
                              ),
                              const SizedBox(height: 4),
                              Text(_pisoLabel,
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey[500])),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: Colors.orange[300]!),
                          ),
                          child: Text('Inactivo',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange[800])),
                        ),
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
                          onPressed: estado.isLoading
                              ? null
                              : () async {
                                  await ref
                                      .read(catalogMutationProvider.notifier)
                                      .editSalon(
                                        Salon(
                                          id: salon.id,
                                          edificio: salon.edificio,
                                          piso: salon.piso,
                                          numeroSalon: salon.numeroSalon,
                                          etiquetaSalon: null,
                                          activo: true,
                                        ),
                                      );
                                  final s = ref.read(catalogMutationProvider);
                                  if (!context.mounted) return;
                                  if (s.isSuccess) {
                                    ref.invalidate(salonesProvider);
                                    ref.invalidate(
                                        adminSalonesInactivosProvider);
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text(
                                          'Salón $_nomenclatura reactivado'),
                                      backgroundColor: Colors.green,
                                    ));
                                    ref
                                        .read(catalogMutationProvider.notifier)
                                        .resetState();
                                  } else if (s.errorMessage != null) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text(s.errorMessage!),
                                      backgroundColor: Colors.red,
                                    ));
                                    ref
                                        .read(catalogMutationProvider.notifier)
                                        .resetState();
                                  }
                                },
                          icon: Icon(Icons.restore_rounded,
                              size: 16, color: Colors.green[700]),
                          label: Text('Reactivar',
                              style: TextStyle(
                                  color: Colors.green[700], fontSize: 13)),
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
