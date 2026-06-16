import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_ets_escom/core/providers/core_providers.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/app_colors.dart';
import 'package:gestion_ets_escom/features/shared/presentation/theme/elements/background_pattern_painter.dart';
import 'package:go_router/go_router.dart';

class AdminLoginPage extends ConsumerStatefulWidget {
  const AdminLoginPage({super.key});

  @override
  ConsumerState<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends ConsumerState<AdminLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usuarioController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usuarioController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    debugPrint("Iniciando sesión");
    debugPrint(_usuarioController.text.trim());
    debugPrint(_passwordController.text);
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    final result = await ref
        .read(loginUseCaseProvider)
        .call(
          correo: _usuarioController.text.trim(),
          contrasena: _passwordController.text,
        );
    debugPrint('result: ${result}');
    if (!mounted) return;

    result.fold(
      (failure) => setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = _friendlyError(failure.message);
      }),
      (admin) {
        ref.read(currentAdminProvider.notifier).set(admin);
        context.go('/admin/dashboard');
      },
    );
  }

  String _friendlyError(String raw) {
    if (raw.contains('Invalid login credentials') ||
        raw.contains('invalid_credentials')) {
      return 'Usuario o contraseña incorrectos';
    }
    if (raw.contains('network') || raw.contains('SocketException')) {
      return 'Sin conexión. Verifica tu red e intenta de nuevo';
    }
    return 'Ocurrió un error. Intenta de nuevo';
  }

  @override
  Widget build(BuildContext context) {
    const double avatarRadius = 40;

    return Scaffold(
      backgroundColor: AppColors.primaryDarkBlue,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                // ─── Header con patrón de fondo ──────────────────────────────────────────
                Container(
                  height: MediaQuery.of(context).size.height * 0.25,
                  color: AppColors.primaryDarkBlue,
                  child: Stack(
                    children: [
                      CustomPaint(
                        size: Size.infinite,
                        painter: BackgroundPatternPainter(),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'ESCOM',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Sistema de Gestión ETS',
                              style: TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Text(
                                'Administrativo',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ─── Panel blanco con formulario ─────────────────────────────────────────
                Expanded(
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.topCenter,
                    children: [
                      Positioned.fill(
                        child: Container(
                          decoration: const BoxDecoration(
                            color: AppColors.backgroundWhite,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: avatarRadius + 16,
                            left: 24,
                            right: 24,
                            bottom: MediaQuery.of(context).padding.bottom + 16,
                          ),
                          child: SingleChildScrollView(
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Bienvenido',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Inicia sesión para gestionar los ETS',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 32),

                                  const Text(
                                    'Correo electrónico',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _usuarioController,
                                    keyboardType: TextInputType.emailAddress,
                                    enabled: !_isLoading,
                                    decoration: InputDecoration(
                                      hintText: 'correo@escom.ipn.mx',
                                      prefixIcon: const Icon(
                                        Icons.person_outline,
                                      ),
                                      filled: true,
                                      fillColor: AppColors.backgroundLight,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    validator: (value) =>
                                        value!.isEmpty ? 'Requerido' : null,
                                  ),
                                  const SizedBox(height: 24),

                                  const Text(
                                    'Contraseña',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    enabled: !_isLoading,
                                    decoration: InputDecoration(
                                      hintText: 'Contraseña',
                                      prefixIcon: const Icon(
                                        Icons.lock_outline,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                        ),
                                        onPressed: () => setState(
                                          () => _obscurePassword =
                                              !_obscurePassword,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: AppColors.backgroundLight,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: _hasError
                                            ? const BorderSide(
                                                color: Colors.red,
                                                width: 2,
                                              )
                                            : BorderSide.none,
                                      ),
                                    ),
                                    validator: (value) =>
                                        value!.isEmpty ? 'Requerido' : null,
                                  ),

                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: _isLoading ? null : () {},
                                      child: const Text(
                                        '¿Olvidaste tu contraseña?',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: FilledButton(
                                      style: FilledButton.styleFrom(
                                        backgroundColor:
                                            AppColors.primaryDarkBlue,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            25,
                                          ),
                                        ),
                                      ),
                                      onPressed: _isLoading
                                          ? null
                                          : _iniciarSesion,
                                      child: _isLoading
                                          ? const SizedBox(
                                              width: 22,
                                              height: 22,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Text(
                                              'Iniciar Sesión',
                                              style: TextStyle(fontSize: 16),
                                            ),
                                    ),
                                  ),

                                  if (_hasError) ...[
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.red[50],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.red[200]!,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.warning_amber_rounded,
                                            color: Colors.red[700],
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              _errorMessage ??
                                                  'Usuario o contraseña incorrectos',
                                              style: TextStyle(
                                                color: Colors.red[700],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // ─── Avatar flotante del IPN ──────────────────────────────────────────
                      Positioned(
                        top: -avatarRadius,
                        child: CircleAvatar(
                          radius: avatarRadius,
                          backgroundColor: AppColors.primaryLightCherry,
                          child: const Text(
                            'IPN',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryCherry,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // ─── Botón de regresar flotante ───────────────────────────────────────────
            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                onPressed: _isLoading ? null : () => context.pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
