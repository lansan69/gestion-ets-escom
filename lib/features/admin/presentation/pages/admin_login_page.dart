import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Nota: Más adelante aquí importaremos tu auth_repository o login_usecase mediante Riverpod.

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
  bool _hasError = false; // Controla la alerta roja inferior de la pantalla A01

  @override
  void dispose() {
    _usuarioController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _iniciarSesion() {
    if (_formKey.currentState!.validate()) {
      // TODO: Reemplazar con la llamada real a Riverpod/Supabase
      // Simulación rápida para que puedas navegar a la siguiente pantalla
      if (_usuarioController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
        setState(() => _hasError = false);
        // Navegamos al dashboard usando GoRouter
        context.go('/admin/dashboard');
      } else {
        setState(() => _hasError = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Colores basados en tu diseño (A01)
    const colorPrimario = Color(0xFF00338D); // Azul IPN/ESCOM aprox
    const colorFondoBlanco = Colors.white;

    return Scaffold(
      backgroundColor: colorPrimario,
      body: SafeArea(
        bottom: false,
        child: Stack( // <-- Agregamos un Stack aquí
          children: [
            // 1. TU CONTENIDO ORIGINAL (La columna con el logo y el formulario)
            Column(
              children: [
                // --- HEADER (Logo y Título) ---
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white24,
                          // backgroundImage: AssetImage('assets/images/logo_escom.png'),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'ESCOM',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          'Sistema de Gestión ETS',
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            'Administrativo',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // --- FORMULARIO BLANCO ---
                Expanded(
                  flex: 4,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24.0),
                    decoration: const BoxDecoration(
                      color: colorFondoBlanco,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
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
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Inicia sesión para gestionar los ETS',
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 32),

                            // Campo Usuario
                            const Text('Usuario', style: TextStyle(fontWeight: FontWeight.w500)),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _usuarioController,
                              decoration: InputDecoration(
                                hintText: 'Número de empleado',
                                prefixIcon: const Icon(Icons.person_outline),
                                filled: true,
                                fillColor: Colors.grey[100],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              validator: (value) => value!.isEmpty ? 'Requerido' : null,
                            ),
                            const SizedBox(height: 24),

                            // Campo Contraseña
                            const Text('Contraseña', style: TextStyle(fontWeight: FontWeight.w500)),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: _hasError 
                                    ? const BorderSide(color: Colors.red, width: 2) 
                                    : BorderSide.none,
                                ),
                              ),
                              validator: (value) => value!.isEmpty ? 'Requerido' : null,
                            ),
                            
                            // Enlace de recuperar contraseña
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {},
                                child: const Text('¿Olvidaste tu contraseña?'),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Botón Iniciar Sesión
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: colorPrimario,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                onPressed: _iniciarSesion,
                                child: const Text('Iniciar Sesión', style: TextStyle(fontSize: 16)),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Alerta de Error (Condicional)
                            if (_hasError)
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.red[200]!),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.warning_amber_rounded, color: Colors.red[700]),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Usuario o contraseña incorrectos',
                                      style: TextStyle(color: Colors.red[700]),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // 2. EL BOTÓN DE REGRESAR FLOTANTE
            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                // Usamos este ícono porque se ve más limpio y moderno (sin relleno)
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                onPressed: () {
                  // Destruye esta pantalla y regresa a la anterior en el historial
                  context.pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}