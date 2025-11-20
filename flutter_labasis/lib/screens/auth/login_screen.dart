// lib/screens/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../home/home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoggingIn = false;

  @override
  void initState() {
    super.initState();
    // Pre-llenar con datos de prueba (puedes quitar esto después)
    _emailController.text = 'auxiliar@labasis.com';
    _passwordController.text = 'auxiliar123';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // Evitar múltiples clicks
    if (_isLoggingIn) {
      print('⚠️ Login ya en proceso, ignorando click adicional');
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoggingIn = true;
      });

      print('');
      print('═══════════════════════════════════════');
      print('🔐 INICIANDO PROCESO DE LOGIN');
      print('═══════════════════════════════════════');
      print('📧 Email: ${_emailController.text.trim()}');
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      try {
        final success = await authProvider.login(
          _emailController.text.trim(),
          _passwordController.text,
        );

        if (!mounted) {
          print('⚠️ Widget desmontado, cancelando navegación');
          return;
        }

        print('');
        print('─────────────────────────────────────');
        print('📊 RESULTADO DEL LOGIN:');
        print('─────────────────────────────────────');
        print('✓ Success: $success');
        print('✓ Usuario: ${authProvider.user?.nombre ?? "null"}');
        print('✓ Email: ${authProvider.user?.email ?? "null"}');
        print('✓ Rol: ${authProvider.user?.rol ?? "null"}');
        print('✓ Token presente: ${authProvider.token != null ? "SÍ" : "NO"}');
        print('✓ isAuthenticated: ${authProvider.isAuthenticated}');
        print('─────────────────────────────────────');

        if (success && authProvider.isAuthenticated) {
          print('');
          print('✅ LOGIN EXITOSO - Navegando al HomeScreen...');
          
          // Esperar un frame para asegurar que el estado se actualizó
          await Future.delayed(const Duration(milliseconds: 100));
          
          if (!mounted) {
            print('⚠️ Widget desmontado durante delay, cancelando navegación');
            return;
          }
          
          // Usar pushAndRemoveUntil para limpiar la pila de navegación
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
          );
          
          print('✅ NAVEGACIÓN COMPLETADA');
          print('═══════════════════════════════════════');
          print('');
        } else {
          print('');
          print('❌ LOGIN FALLIDO');
          print('❌ Error: ${authProvider.error ?? "Error desconocido"}');
          print('═══════════════════════════════════════');
          print('');
          
          _showErrorSnackBar(authProvider.error ?? 'Error en el login');
        }
      } catch (e) {
        print('');
        print('❌ EXCEPCIÓN EN LOGIN: $e');
        print('═══════════════════════════════════════');
        print('');
        
        if (mounted) {
          _showErrorSnackBar('Error inesperado: ${e.toString()}');
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoggingIn = false;
          });
        }
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red[700],
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        action: SnackBarAction(
          label: 'CERRAR',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo/Icono
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.blue[700],
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.science,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Título
                  const Text(
                    'LABASIS',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2196F3),
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sistema de Gestión de Laboratorios',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  // Form
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Email
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          enabled: !_isLoggingIn,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            hintText: 'correo@ejemplo.com',
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa tu email';
                            }
                            if (!value.contains('@')) {
                              return 'Por favor ingresa un email válido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Password
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          enabled: !_isLoggingIn,
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            hintText: '••••••••',
                            prefixIcon: const Icon(Icons.lock_outlined),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa tu contraseña';
                            }
                            if (value.length < 6) {
                              return 'La contraseña debe tener al menos 6 caracteres';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        
                        // Botón de login
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, _) {
                            final isButtonLoading = _isLoggingIn || authProvider.isLoading;
                            
                            return SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: isButtonLoading ? null : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2196F3),
                                  disabledBackgroundColor: Colors.grey[300],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: isButtonLoading ? 0 : 2,
                                ),
                                child: isButtonLoading
                                    ? Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.white),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            'Iniciando sesión...',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      )
                                    : const Text(
                                        'INICIAR SESIÓN',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Link a registro
                  TextButton(
                    onPressed: _isLoggingIn
                        ? null
                        : () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const RegisterScreen(),
                              ),
                            );
                          },
                    child: const Text(
                      '¿No tienes cuenta? Regístrate aquí',
                      style: TextStyle(
                        color: Color(0xFF2196F3),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  
                  // Info de prueba
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.blue[100]!,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 18,
                              color: Colors.blue[700],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Usuarios de prueba',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Colors.blue[900],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildCredentialRow(
                          icon: Icons.admin_panel_settings,
                          label: 'Admin',
                          email: 'admin@labasis.com',
                          password: 'admin123',
                        ),
                        const SizedBox(height: 8),
                        _buildCredentialRow(
                          icon: Icons.person,
                          label: 'Auxiliar',
                          email: 'auxiliar@labasis.com',
                          password: 'auxiliar123',
                        ),
                      ],
                    ),
                  ),
                  
                  // Versión (opcional)
                  const SizedBox(height: 24),
                  Text(
                    'v1.0.0',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCredentialRow({
    required IconData icon,
    required String label,
    required String email,
    required String password,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.blue[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$email / $password',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 16),
            onPressed: () {
              // Aquí podrías implementar copiar al portapapeles
              _emailController.text = email;
              _passwordController.text = password;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Credenciales de $label cargadas'),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            tooltip: 'Usar estas credenciales',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}