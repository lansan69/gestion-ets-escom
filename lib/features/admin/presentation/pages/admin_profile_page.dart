import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/app_colors.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/background_pattern_painter.dart';

class AdminProfilePage extends StatelessWidget {
  const AdminProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDarkBlue,
      body: Stack(
        children: [
          CustomPaint(size: Size.infinite, painter: BackgroundPatternPainter()),
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Header ──────────────────────────────────────────────────
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mi Cuenta',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Administra tu acceso y preferencias',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                // ─── Panel blanco ─────────────────────────────────────────────
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.backgroundWhite,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 24),
                      children: [
                        // 1. TARJETA DE IDENTIDAD (Perfil)
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey[200]!),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4))
                            ],
                          ),
                          child: Column(
                            children: [
                              const CircleAvatar(
                                radius: 40,
                                backgroundColor: Color(0xFFE3EAFC),
                                child: Text(
                                  'RH',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryDarkBlue,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Rebeca Hernández',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A1A1A)),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Administrador del Sistema',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue[700]),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'admin@escom.ipn.mx',
                                style:
                                    TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),
                        const Text(
                          'SEGURIDAD Y ACCESO',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Colors.grey,
                              letterSpacing: 1.2),
                        ),
                        const SizedBox(height: 12),

                        // 2. OPCIONES DE SEGURIDAD
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(10)),
                              child: const Icon(Icons.lock_outline_rounded,
                                  color: AppColors.primaryDarkBlue),
                            ),
                            title: const Text('Cambiar Contraseña',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600)),
                            trailing: const Icon(Icons.arrow_forward_ios_rounded,
                                size: 16, color: Colors.grey),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) =>
                                    const _ChangePasswordModal(),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 32),
                        const Text(
                          'SISTEMA',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Colors.grey,
                              letterSpacing: 1.2),
                        ),
                        const SizedBox(height: 12),

                        // 3. OPCIONES DE SISTEMA
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Column(
                            children: [
                              const ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 4),
                                leading: Icon(Icons.info_outline_rounded,
                                    color: Colors.grey),
                                title: Text('Versión de la App',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500)),
                                trailing: Text('v1.0.0',
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold)),
                              ),
                              Divider(height: 1, color: Colors.grey[200]),
                              ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 4),
                                leading: const Icon(Icons.description_outlined,
                                    color: Colors.grey),
                                title: const Text('Términos y Privacidad',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500)),
                                trailing: const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 16,
                                    color: Colors.grey),
                                onTap: () {
                                  // TODO: Abrir url de términos
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),

                        // 4. BOTÓN CERRAR SESIÓN
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side:
                                BorderSide(color: Colors.red[300]!, width: 1.5),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            foregroundColor: Colors.red[600],
                          ),
                          icon: const Icon(Icons.logout_rounded),
                          label: const Text('Cerrar Sesión',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => const _LogoutModal(),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
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

// =======================================================================
// MODAL: CAMBIAR CONTRASEÑA
// =======================================================================
class _ChangePasswordModal extends StatefulWidget {
  const _ChangePasswordModal();

  @override
  State<_ChangePasswordModal> createState() => _ChangePasswordModalState();
}

class _ChangePasswordModalState extends State<_ChangePasswordModal> {
  bool _obscureCurrent = true;
  bool _obscureNew = true;

  @override
  Widget build(BuildContext context) {
    const colorPrimario = Color(0xFF00338D);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(28)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(24, 24, 16, 24),
                decoration: BoxDecoration(
                  color: Colors.blue[50]?.withOpacity(0.4),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(28)),
                  border: Border(bottom: BorderSide(color: Colors.blue[100]!)),
                ),
                child: Row(
                  children: [
                    Container(
                        width: 6,
                        height: 44,
                        decoration: BoxDecoration(
                            color: colorPrimario,
                            borderRadius: BorderRadius.circular(4))),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Actualizar Contraseña',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w800)),
                          Text('Crea una contraseña segura',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: colorPrimario,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context)),
                  ],
                ),
              ),
              // Formulario
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Contraseña Actual',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF444444))),
                      const SizedBox(height: 8),
                      TextField(
                        obscureText: _obscureCurrent,
                        decoration: _inputDecoration(
                          hint: '••••••••',
                          icon: Icons.lock_outline,
                          suffixIcon: IconButton(
                            icon: Icon(
                                _obscureCurrent
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey),
                            onPressed: () => setState(
                                () => _obscureCurrent = !_obscureCurrent),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('Nueva Contraseña',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF444444))),
                      const SizedBox(height: 8),
                      TextField(
                        obscureText: _obscureNew,
                        decoration: _inputDecoration(
                          hint: '••••••••',
                          icon: Icons.lock_reset_rounded,
                          suffixIcon: IconButton(
                            icon: Icon(
                                _obscureNew
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey),
                            onPressed: () =>
                                setState(() => _obscureNew = !_obscureNew),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Footer
              Container(
                padding: const EdgeInsets.all(24),
                child: FilledButton(
                  style: FilledButton.styleFrom(
                      backgroundColor: colorPrimario,
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16))),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Guardar Contraseña',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
      {required String hint, required IconData icon, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF8F9FA),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none),
      prefixIcon: Icon(icon,
          size: 20,
          color: const Color(0xFF00338D).withOpacity(0.6)),
      suffixIcon: suffixIcon,
    );
  }
}

// =======================================================================
// MODAL: CONFIRMAR CERRAR SESIÓN
// =======================================================================
class _LogoutModal extends StatelessWidget {
  const _LogoutModal();

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(32)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.red[50], shape: BoxShape.circle),
                child:
                    Icon(Icons.logout_rounded, size: 36, color: Colors.red[600]),
              ),
              const SizedBox(height: 20),
              const Text('¿Cerrar Sesión?',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1A1A1A)),
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                  'Tendrás que volver a ingresar tus credenciales para administrar el sistema.',
                  style: TextStyle(
                      fontSize: 14, color: Colors.grey[600], height: 1.4),
                  textAlign: TextAlign.center),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(
                              color: Colors.grey[300]!, width: 1.5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16))),
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancelar',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700])),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                          backgroundColor: Colors.red[600],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 0),
                      onPressed: () {
                        // TODO: Lógica de limpieza de token y ruteo al Login
                        Navigator.pop(context);
                      },
                      child: const Text('Salir',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
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
