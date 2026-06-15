import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: Colors.white, // Fondo principal
      child: Column(
        children: [
          // --- HEADER AZUL ---
          Container(
            width: double.infinity,
            color: const Color(0xFF0D47A1), // Azul ESCOM
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: const Text(
                  'Configuración',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),

          // --- CONTENIDO SCROLLEABLE ---
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Chips de Preferencias Activas
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text('Tus preferencias activas', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _ActiveChip(label: 'ISC 2020', color: const Color(0xFF3C8041), textColor: Colors.white),
                      const SizedBox(width: 8),
                      _ActiveChip(label: 'Sem. 4', color: const Color(0xFFE3EAFD), textColor: const Color(0xFF0D47A1)),
                      const SizedBox(width: 8),
                      _ActiveChip(label: 'Sem. 5', color: const Color(0xFFE3EAFD), textColor: const Color(0xFF0D47A1)),
                      const SizedBox(width: 8),
                      _ActiveChip(label: 'Sem. 7', color: const Color(0xFFE3EAFD), textColor: const Color(0xFF0D47A1)),
                      const SizedBox(width: 8),
                      _ActiveChip(label: 'Matutino', color: const Color(0xFFE3EAFD), textColor: const Color(0xFF0D47A1)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // SECCIÓN: MIS PREFERENCIAS
                _SettingsSection(
                  title: 'MIS PREFERENCIAS',
                  children: [
                    _SettingsTile(
                      icon: Icons.school,
                      iconColor: const Color(0xFF2B3A4A),
                      iconBgColor: const Color(0xFFE8EEF4),
                      title: 'Carrera y Plan',
                      subtitle: 'ISC · Plan 2020',
                      onTap: () => context.go('/onboarding/carrera'),
                    ),
                    _Divider(),
                    _SettingsTile(
                      icon: Icons.menu_book,
                      iconColor: const Color(0xFF3C8041),
                      iconBgColor: const Color(0xFFEBF3EB),
                      title: 'Semestres activos',
                      subtitle: 'Sem. 4 · Sem. 5 · Sem. 7',
                      onTap: () => context.go('/onboarding/semestre'),
                    ),
                    _Divider(),
                    _SettingsTile(
                      icon: Icons.wb_sunny,
                      iconColor: const Color(0xFFE18301),
                      iconBgColor: const Color(0xFFFDF3E6),
                      title: 'Turno preferido',
                      subtitle: 'Matutino',
                    ),
                  ],
                ),

                // SECCIÓN: NOTIFICACIONES
                _SettingsSection(
                  title: 'NOTIFICACIONES',
                  children: [
                    _SettingsTile(
                      icon: Icons.notifications,
                      iconColor: const Color(0xFFE18301),
                      iconBgColor: const Color(0xFFFDF3E6),
                      title: 'Activar notificaciones',
                      subtitle: 'Recibe recordatorios de tus ETS',
                      trailing: Switch(
                        value: true,
                        onChanged: (val) {},
                        activeColor: const Color(0xFF0D47A1),
                      ),
                    ),
                    _Divider(),
                    _SettingsTile(
                      icon: Icons.access_alarm,
                      iconColor: const Color(0xFF6B7280),
                      iconBgColor: const Color(0xFFF3F4F6),
                      title: 'Recordatorio por defecto',
                      subtitle: '1 día antes',
                    ),
                  ],
                ),

                // SECCIÓN: APARIENCIA
                _SettingsSection(
                  title: 'APARIENCIA',
                  children: [
                    _SettingsTile(
                      icon: Icons.nightlight_round,
                      iconColor: const Color(0xFFFFC107),
                      iconBgColor: const Color(0xFFFFF8E1),
                      title: 'Modo oscuro',
                      subtitle: 'Cambia el tema de la app',
                      trailing: Switch(
                        value: false,
                        onChanged: (val) {},
                      ),
                    ),
                  ],
                ),

                // SECCIÓN: DATOS
                _SettingsSection(
                  title: 'DATOS',
                  children: [
                    _SettingsTile(
                      icon: Icons.delete_outline,
                      iconColor: const Color(0xFFD32F2F), // Rojo
                      iconBgColor: const Color(0xFFFFEBEE),
                      title: 'Limpiar caché',
                      titleColor: const Color(0xFFD32F2F),
                      subtitle: 'Elimina ETS guardados y preferencias',
                      subtitleColor: const Color(0xFFD32F2F),
                      trailingIconColor: const Color(0xFFD32F2F),
                      onTap: () {
                        // Lógica para limpiar SQLite/SharedPreferences
                      },
                    ),
                    _Divider(),
                    _SettingsTile(
                      icon: Icons.info_outline,
                      iconColor: const Color(0xFF0D47A1),
                      iconBgColor: const Color(0xFFE3EAFD),
                      title: 'Versión de la app',
                      subtitle: 'ETS ESCOM v1.0.0',
                      showTrailingIcon: false,
                    ),
                  ],
                ),
                
                const SizedBox(height: 32), // Espacio final
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- WIDGETS AUXILIARES ---

class _ActiveChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;

  const _ActiveChip({required this.label, required this.color, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold)),
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
            child: Text(title, style: TextStyle(color: Colors.grey.shade400, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200), // Borde ligero del diseño
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
      borderRadius: BorderRadius.circular(16), // Respeta la curva al hacer clic
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: titleColor ?? Colors.black87)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: subtitleColor ?? Colors.grey.shade500)),
                ],
              ),
            ),
            if (trailing != null) trailing!
            else if (showTrailingIcon) Icon(Icons.chevron_right, color: trailingIconColor ?? Colors.grey.shade400, size: 20),
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
      padding: const EdgeInsets.only(left: 60, right: 16), // Alineado con el texto
      child: Divider(height: 1, color: Colors.grey.shade200),
    );
  }
}