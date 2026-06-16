// ============================================================
// NOMBRE: individual_materia_view.dart
// USO: Vista de detalle de un examen ETS. Compartida entre usuario
//      y administrador. El parámetro bottomBar permite sustituir
//      la barra de acciones predeterminada (calendario) por otra.
//      Ruta usuario: /materia (via GoRouter).
//      Ruta admin: Navigator.push desde _ExamListCardAdmin.
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_ets_escom/core/providers/core_providers.dart';
import 'package:gestion_ets_escom/core/services/launcher_service.dart';
import 'package:gestion_ets_escom/features/shared/presentation/elements/color_picker_dialog.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/app_colors.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/background_pattern_painter.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/card_materia_expanded.dart';

class MateriaData {
  final String id;
  final String nombre;
  final String profesor;
  final String? emailProfesor;
  final int semestre;
  final String salon;
  final String fecha;
  final DateTime rawFecha;
  final String hora;
  final String turno;
  final EtsStatus status;
  final Color barColor;
  // Hex color del área de formación (#RRGGBB). Se usa como selección por
  // defecto en el color picker del calendario.
  final String? areaFormacionColor;
  final String? guia;
  final String? proyecto;
  final String? notas;

  const MateriaData({
    required this.id,
    required this.nombre,
    required this.profesor,
    this.emailProfesor,
    required this.semestre,
    required this.salon,
    required this.fecha,
    required this.rawFecha,
    required this.hora,
    required this.turno,
    required this.status,
    required this.barColor,
    this.areaFormacionColor,
    this.guia,
    this.proyecto,
    this.notas,
  });

  /// Días que faltan para el examen (negativo = ya pasó).
  int get diasRestantes {
    final examDay = DateTime(rawFecha.year, rawFecha.month, rawFecha.day);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return examDay.difference(today).inDays;
  }

  bool get tieneMaterial => guia != null || proyecto != null || notas != null;
}

// ---------------------------------------------------------------------------
// Vista principal
// ---------------------------------------------------------------------------
class IndividualMateriaView extends ConsumerWidget {
  const IndividualMateriaView({
    super.key,
    required this.data,
    this.bottomBar,
  });

  final MateriaData data;

  /// Widget que reemplaza la barra de acciones predeterminada.
  /// Null → muestra _StickyActions (agregar/eliminar del calendario).
  final Widget? bottomBar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: data.barColor,
      // ── Sticky bottom bar con las acciones ──────────────────────────────
      bottomNavigationBar: bottomBar ?? _StickyActions(data: data),
      body: Stack(
        children: [
          // Fondo con patrón
          CustomPaint(size: Size.infinite, painter: BackgroundPatternPainter()),

          CustomScrollView(
            slivers: [
              // ── Header coloreado ─────────────────────────────────────
              SliverToBoxAdapter(
                child: _ColoredHeader(
                  data: data,
                  topPadding: topPadding,
                  onBack: () => Navigator.pop(context),
                ),
              ),

              // ── Cuerpo sobre fondo blanco ────────────────────────────
              SliverFillRemaining(
                hasScrollBody: false,
                child: Container(
                  color: AppColors.backgroundWhite,
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1 · Nombre del profesor
                      _ProfesorNombreCard(data: data),

                      const SizedBox(height: 12),

                      // 2 · Correo del profesor
                      if (data.emailProfesor != null)
                        _ProfesorCorreoCard(data: data),

                      if (data.emailProfesor != null)
                        const SizedBox(height: 12),

                      // 3 · Archivos (guía + proyecto)
                      if (data.guia != null || data.proyecto != null)
                        _ArchivosCard(data: data),

                      if (data.guia != null || data.proyecto != null)
                        const SizedBox(height: 12),

                      // 4 · Notas
                      if (data.notas != null) _NotasCard(data: data),

                      if (!data.tieneMaterial) const _EmptyMaterialNote(),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Botón de regreso flotando sobre el header
          Positioned(
            top: topPadding + 4,
            left: 4,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header coloreado: banner de status + nombre + fecha/hora/salón
// ---------------------------------------------------------------------------
class _ColoredHeader extends StatelessWidget {
  const _ColoredHeader({
    required this.data,
    required this.topPadding,
    required this.onBack,
  });

  final MateriaData data;
  final double topPadding;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final dias = data.diasRestantes;
    final (bannerText, bannerDays) = _statusText(data.status, dias);

    return Padding(
      padding: EdgeInsets.only(
        top: topPadding + 48, // espacio para el back button
        left: 16,
        right: 16,
        bottom: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Banner de status ─────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Text(
                  bannerText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Text(
                  bannerDays,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Nombre de la materia ─────────────────────────────────────
          Text(
            data.nombre,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 10),

          // ── Pills: fecha · hora · salón ──────────────────────────────
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              _HeaderPill(icon: Icons.calendar_today, label: data.fecha),
              _HeaderPill(icon: Icons.access_time, label: data.hora),
              _HeaderPill(icon: Icons.meeting_room, label: data.salon),
            ],
          ),
        ],
      ),
    );
  }

  (String, String) _statusText(EtsStatus status, int dias) {
    return switch (status) {
      EtsStatus.today => ('🔴  HOY', 'El examen es hoy'),
      EtsStatus.tomorrow => ('🟡  MAÑANA', 'El examen es mañana'),
      EtsStatus.soon => ('🟠  PRÓXIMO', 'En $dias días'),
      EtsStatus.far => ('📅  LEJANO', 'En $dias días'),
    };
  }
}

class _HeaderPill extends StatelessWidget {
  const _HeaderPill({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Colors.white70),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Card de nombre del profesor
// ---------------------------------------------------------------------------
class _ProfesorNombreCard extends StatelessWidget {
  const _ProfesorNombreCard({required this.data});
  final MateriaData data;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Profesor',
      icon: Icons.person_outline,
      children: [_InfoRow(icon: Icons.person_outline, label: data.profesor)],
    );
  }
}

// ---------------------------------------------------------------------------
// Card de correo del profesor
// ---------------------------------------------------------------------------
class _ProfesorCorreoCard extends StatelessWidget {
  const _ProfesorCorreoCard({required this.data});
  final MateriaData data;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Correo',
      icon: Icons.email_outlined,
      children: [
        _InfoRow(
          icon: Icons.email_outlined,
          label: data.emailProfesor!,
          trailingWidget: TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: data.emailProfesor!));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Correo copiado'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: Text(
              'Copiar',
              style: TextStyle(
                color: data.barColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Card · Archivos (guía + proyecto)
// ---------------------------------------------------------------------------
class _ArchivosCard extends StatelessWidget {
  const _ArchivosCard({required this.data});
  final MateriaData data;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      icon: Icons.folder_outlined,
      title: 'Archivos',
      children: [
        if (data.guia != null)
          _InfoRow(
            icon: Icons.description_outlined,
            label: data.guia!,
            sublabel: 'Guía de estudio',
            trailingWidget: _DownloadChip(
              color: data.barColor,
              onTap: () => LauncherService().openPdf(data.guia!),
            ),
          ),
        if (data.proyecto != null)
          _InfoRow(
            icon: Icons.insert_drive_file_outlined,
            label: data.proyecto!,
            sublabel: 'Proyecto',
            trailingWidget: _DownloadChip(
              color: data.barColor,
              onTap: () => LauncherService().openPdf(data.proyecto!),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Card · Notas
// ---------------------------------------------------------------------------
class _NotasCard extends StatelessWidget {
  const _NotasCard({required this.data});
  final MateriaData data;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      icon: Icons.sticky_note_2_outlined,
      title: 'Notas',
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
          child: Text(
            data.notas!,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF475569),
              height: 1.55,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Nota discreta cuando no hay material de ningún tipo
// ---------------------------------------------------------------------------
class _EmptyMaterialNote extends StatelessWidget {
  const _EmptyMaterialNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.folder_open_outlined,
            color: Colors.grey.shade400,
            size: 18,
          ),
          const SizedBox(width: 10),
          Text(
            'Sin material de apoyo registrado',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

/// Chip pequeño de acción para archivos descargables.
class _DownloadChip extends StatelessWidget {
  const _DownloadChip({required this.color, this.onTap});
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.download_outlined, size: 12, color: color),
            const SizedBox(width: 4),
            Text(
              'Ver',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sticky bottom bar predeterminada — acciones de calendario (modo usuario)
// ---------------------------------------------------------------------------
class _StickyActions extends ConsumerStatefulWidget {
  const _StickyActions({required this.data});
  final MateriaData data;

  @override
  ConsumerState<_StickyActions> createState() => _StickyActionsState();
}

class _StickyActionsState extends ConsumerState<_StickyActions> {
  bool _loading = false;

  Future<void> _handleCalendario() async {
    if (_loading) return;

    final selectedColor = await showColorPickerDialog(
      context,
      defaultColor: widget.data.areaFormacionColor,
    );
    if (!mounted || selectedColor == null) return;

    setState(() => _loading = true);

    final result = await ref
        .read(addToCalendarioProvider)
        .call(widget.data.id, selectedColor);

    if (!mounted) return;
    setState(() => _loading = false);

    result.fold(
      (_) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo guardar. Intenta de nuevo')),
      ),
      (_) {
        ref.invalidate(isInCalendarioProvider(widget.data.id));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Examen agregado al calendario')),
        );
      },
    );
  }

  Future<void> _handleRemoveCalendario() async {
    if (_loading) return;
    setState(() => _loading = true);

    final result = await ref
        .read(removeFromCalendarioProvider)
        .call(widget.data.id);

    if (!mounted) return;
    setState(() => _loading = false);

    result.fold(
      (_) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo eliminar. Intenta de nuevo')),
      ),
      (_) {
        ref.invalidate(isInCalendarioProvider(widget.data.id));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Examen eliminado del calendario')),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final saved = ref.watch(isInCalendarioProvider(widget.data.id));
    final isSaved = saved.asData?.value ?? false;
    final barColor = widget.data.barColor;

    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: isSaved
                ? OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFC62828),
                      side: const BorderSide(color: Color(0xFFC62828)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _loading ? null : _handleRemoveCalendario,
                    icon: _loading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFFC62828),
                            ),
                          )
                        : const Icon(Icons.calendar_month, size: 18),
                    label: const Text(
                      'Eliminar del calendario',
                      style: TextStyle(fontSize: 13),
                    ),
                  )
                : FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: barColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _loading ? null : _handleCalendario,
                    icon: _loading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.calendar_month, size: 18),
                    label: const Text(
                      'Calendario',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers de UI reutilizables
// ---------------------------------------------------------------------------

/// Tarjeta con título de sección, icono opcional y filas de info.
class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children, this.icon});
  final String title;
  final IconData? icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 13, color: Colors.grey.shade400),
                  const SizedBox(width: 6),
                ],
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

/// Fila de información con icono, texto, sublabel opcional y widget a la derecha.
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    this.sublabel,
    this.trailingWidget,
  });

  final IconData icon;
  final String label;
  final String? sublabel;
  final Widget? trailingWidget;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade400),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (sublabel != null)
                  Text(
                    sublabel!,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF334155),
                  ),
                ),
              ],
            ),
          ),
          if (trailingWidget != null) ...[
            const SizedBox(width: 8),
            trailingWidget!,
          ],
        ],
      ),
    );
  }
}
