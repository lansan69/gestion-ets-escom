import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_ets_escom/core/providers/core_providers.dart';
import 'package:gestion_ets_escom/core/services/notification_service.dart';
import 'package:gestion_ets_escom/core/utils/snackbar_helper.dart';
import 'package:gestion_ets_escom/features/shared/domain/entities/calendario_examen.dart';
import 'package:gestion_ets_escom/features/shared/presentation/pages/welcome_page.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/app_colors.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/background_pattern_painter.dart';
import 'package:gestion_ets_escom/features/user/presentation/providers/carrera_providers.dart';
import 'package:gestion_ets_escom/features/user/presentation/providers/notification_prefs_provider.dart';
import 'package:gestion_ets_escom/features/user/presentation/providers/preferencias_provider.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topOffset = MediaQuery.of(context).padding.top + 10;
    final preferenciaAsync = ref.watch(preferenciasPageProvider);
    final carrerasAsync = ref.watch(carrerasProvider);
    final preferencia = preferenciaAsync.value;
    final carreras = carrerasAsync.value ?? [];

    final carrera = carreras
        .where((c) => c.id == preferencia?.carreraId)
        .firstOrNull;

    final carreraLabel = carrera != null ? carrera.abreviatura : '-';

    final sems = preferencia?.semestres ?? [];
    final semestresLabel = sems.isNotEmpty
        ? sems.map((s) => 'Sem. $s').join(' · ')
        : '—';

    return Container(
      height: double.infinity,
      width: double.infinity,
      color: AppColors.primaryDarkBlue,
      child: Stack(
        children: [
          CustomPaint(size: Size.infinite, painter: BackgroundPatternPainter()),
          Positioned(
            top: topOffset,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.backgroundWhite,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Chips fijos ──────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'Tus preferencias activas',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _ActiveChip(
                          label: carreraLabel,
                          color: AppColors.primaryDarkBlue,
                          textColor: Colors.white,
                        ),
                        for (final e in sems) ...[
                          const SizedBox(width: 8),
                          _ActiveChip(
                            label: 'Sem. $e',
                            color: const Color(0xFFE3EAFD),
                            textColor: const Color(0xFF0D47A1),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // ─── Secciones scrolleables ───────────────────
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.only(bottom: 32),
                      children: [
                        const SizedBox(height: 8),
                        _SettingsSection(
                          title: 'MIS PREFERENCIAS',
                          children: [
                            _SettingsTile(
                              icon: Icons.school,
                              iconColor: const Color(0xFF2B3A4A),
                              iconBgColor: const Color(0xFFE8EEF4),
                              title: 'Carrera y Plan',
                              subtitle: carreraLabel,
                              onTap: () => context.push(
                                '/settings/preferencias/carrera',
                              ),
                            ),
                            _Divider(),
                            _SettingsTile(
                              icon: Icons.menu_book,
                              iconColor: const Color(0xFF3C8041),
                              iconBgColor: const Color(0xFFEBF3EB),
                              title: 'Semestres activos',
                              subtitle: semestresLabel,
                              onTap: () => context.push(
                                '/settings/preferencias/semestre',
                                extra: {
                                  'carreraId': preferencia?.carreraId,
                                  'isEditing': true,
                                },
                              ),
                            ),
                          ],
                        ),
                        _SettingsSection(
                          title: 'NOTIFICACIONES',
                          children: [
                            _NotificacionesTile(
                              onTap: () => _showNotificacionesSheet(context, ref),
                            ),
                          ],
                        ),
                        _SettingsSection(
                          title: 'DATOS',
                          children: [
                            _SettingsTile(
                              icon: Icons.delete_outline,
                              iconColor: const Color(0xFFD32F2F),
                              iconBgColor: const Color(0xFFFFEBEE),
                              title: 'Limpiar caché',
                              titleColor: const Color(0xFFD32F2F),
                              subtitle: 'Elimina ETS guardados y preferencias',
                              subtitleColor: const Color(0xFFD32F2F),
                              trailingIconColor: const Color(0xFFD32F2F),
                              onTap: () => _confirmClearCache(context, ref),
                            ),
                            _Divider(),
                          ],
                        ),
                        _SettingsSection(
                          title: 'CONTROLES',
                          children: [
                            _SettingsTile(
                              icon: Icons.logout_rounded,
                              iconColor: const Color(0xFFD32F2F),
                              iconBgColor: const Color(0xFFFFEBEE),
                              title: 'Salir de la app',
                              subtitle: 'Cierra la aplicación por completo',
                              showTrailingIcon: false,
                              onTap: () => _confirmExit(context),
                            ),
                            _Divider(),
                            _SettingsTile(
                              icon: Icons.arrow_back,
                              iconColor: const Color(0xFF0D47A1),
                              iconBgColor: const Color(0xFFE3EAFD),
                              title: 'Regresar al inicio',
                              subtitle: 'Volver a la pantalla de inicio',
                              showTrailingIcon: false,
                              onTap: () => context.go('/bienvenida'),
                            ),
                          ],
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
    );
  }
}

Future<void> _confirmClearCache(BuildContext context, WidgetRef ref) async {
  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Icon(Icons.delete_outline, color: Color(0xFFD32F2F), size: 36),
          const SizedBox(height: 12),
          const Text(
            '¿Limpiar caché?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            'Se eliminarán tus preferencias y exámenes guardados. '
            'Deberás configurar la app de nuevo.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFD32F2F)),
                    foregroundColor: const Color(0xFFD32F2F),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFD32F2F),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Limpiar'),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  if (confirmed != true || !context.mounted) return;

  final result = await ref.read(clearCacheProvider).call();
  if (!context.mounted) return;

  result.fold(
    (_) => SnackbarHelper.showError(context, 'No se pudo limpiar el caché'),
    (_) async {
      if (context.mounted) {
        SnackbarHelper.showSuccess(context, 'Caché eliminado correctamente');
        context.go('/splash');
      }
    },
  );
}

Future<void> _confirmExit(BuildContext context) async {
  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Icon(Icons.logout_rounded, color: Color(0xFF0D47A1), size: 36),
          const SizedBox(height: 12),
          const Text(
            '¿Salir de la aplicación?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            'Podrás volver a abrirla cuando lo necesites.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF0D47A1)),
                    foregroundColor: const Color(0xFF0D47A1),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0D47A1),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Salir'),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  if (confirmed == true) SystemNavigator.pop();
}

// --- WIDGETS AUXILIARES ---

class _ActiveChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;

  const _ActiveChip({
    required this.label,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final Color? titleColor;
  final Color? subtitleColor;
  final Widget? trailing;
  final bool showTrailingIcon;
  final Color? trailingIconColor;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    this.titleColor,
    this.subtitleColor,
    this.trailing,
    this.showTrailingIcon = true,
    this.trailingIconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: titleColor ?? Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: subtitleColor ?? Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else if (showTrailingIcon)
              Icon(
                Icons.chevron_right,
                color: trailingIconColor ?? Colors.grey.shade400,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 60, right: 16),
      child: Divider(height: 1, color: Colors.grey.shade200),
    );
  }
}

// ─── Notificaciones ────────────────────────────────────────────────────────────

Future<void> _showNotificacionesSheet(
    BuildContext context, WidgetRef ref) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const _NotificacionesSheet(),
  );
}

class _NotificacionesTile extends ConsumerWidget {
  final VoidCallback onTap;
  const _NotificacionesTile({required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(notificationPrefsProvider);
    final enabled = prefsAsync.asData?.value.enabled ?? true;
    final subtitle = enabled ? 'Activadas' : 'Desactivadas';

    return _SettingsTile(
      icon: Icons.notifications_outlined,
      iconColor: const Color(0xFF6B3FA0),
      iconBgColor: const Color(0xFFF3EDFB),
      title: 'Notificaciones',
      subtitle: subtitle,
      onTap: onTap,
    );
  }
}

class _NotificacionesSheet extends ConsumerStatefulWidget {
  const _NotificacionesSheet();

  @override
  ConsumerState<_NotificacionesSheet> createState() =>
      _NotificacionesSheetState();
}

class _NotificacionesSheetState extends ConsumerState<_NotificacionesSheet> {
  late bool _enabled;
  late int _daysBefore;
  late TimeOfDay _time;
  bool _saving = false;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prefs =
          ref.read(notificationPrefsProvider).asData?.value ??
          const NotificationPrefs();
      setState(() {
        _enabled = prefs.enabled;
        _daysBefore = prefs.daysBefore;
        _time = TimeOfDay(hour: prefs.hour, minute: prefs.minute);
        _ready = true;
      });
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);

    if (_enabled) {
      await NotificationService.instance.requestPermission();
    }

    final prefs = NotificationPrefs(
      enabled: _enabled,
      daysBefore: _daysBefore,
      hour: _time.hour,
      minute: _time.minute,
    );

    await ref.read(notificationPrefsProvider.notifier).save(prefs);

    if (_enabled) {
      final result = await ref.read(getCalendarioExamenesProvider).call();
      final examenes = result.fold(
        (_) => <CalendarioExamen>[],
        (list) => list,
      );
      await NotificationService.instance.scheduleAll(examenes, prefs);
    } else {
      await NotificationService.instance.cancelAll();
    }

    if (mounted) {
      Navigator.pop(context);
      SnackbarHelper.showSuccess(context, 'Preferencias de notificación guardadas');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final bottomPadding = MediaQuery.of(context).viewInsets.bottom + 32;
    final daysOptions = [
      (label: 'Mismo día', value: 0),
      (label: '1 día antes', value: 1),
      (label: '2 días antes', value: 2),
      (label: '1 semana', value: 7),
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 20, 24, bottomPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Center(
            child: Icon(Icons.notifications_outlined,
                size: 36, color: Color(0xFF6B3FA0)),
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              'Notificaciones de ETS',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Activar recordatorios',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              Switch(
                value: _enabled,
                activeThumbColor: const Color(0xFF6B3FA0),
                activeTrackColor: const Color(0xFFD4BFEE),
                onChanged: (v) => setState(() => _enabled = v),
              ),
            ],
          ),
          if (_enabled) ...[
            const SizedBox(height: 20),
            Text(
              'ANTICIPACIÓN',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade400),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final opt in daysOptions)
                  ChoiceChip(
                    label: Text(opt.label),
                    selected: _daysBefore == opt.value,
                    selectedColor: const Color(0xFFF3EDFB),
                    onSelected: (_) =>
                        setState(() => _daysBefore = opt.value),
                    side: BorderSide(
                      color: _daysBefore == opt.value
                          ? const Color(0xFF6B3FA0)
                          : Colors.grey.shade300,
                    ),
                    labelStyle: TextStyle(
                      color: _daysBefore == opt.value
                          ? const Color(0xFF6B3FA0)
                          : Colors.black87,
                      fontWeight: _daysBefore == opt.value
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'HORA DEL AVISO',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade400),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: _time,
                );
                if (picked != null) setState(() => _time = picked);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time,
                        color: Color(0xFF6B3FA0), size: 20),
                    const SizedBox(width: 12),
                    Text(
                      _time.format(context),
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                    const Spacer(),
                    Icon(Icons.chevron_right, color: Colors.grey.shade400),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF6B3FA0),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Guardar'),
            ),
          ),
        ],
      ),
    );
  }
}
