import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme.dart';
import '../services/firebase_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure  = true;
  bool _loading  = false;

  Future<void> _login() async {
    if (_emailCtrl.text.isEmpty || _passwordCtrl.text.isEmpty) return;

    setState(() => _loading = true);
    try {
      await FirebaseService.signIn(
        _emailCtrl.text.trim(),
        _passwordCtrl.text.trim(),
      );
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppTheme.severityCritical,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 2),

              // Logo + título
              Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppTheme.accent.withOpacity(0.4)),
                    ),
                    child: const Icon(Icons.shield_outlined,
                        color: AppTheme.accent, size: 24),
                  ),
                  const SizedBox(width: 12),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                      ),
                      children: [
                        TextSpan(
                            text: 'Safe',
                            style:
                                TextStyle(color: AppTheme.textPrimary)),
                        TextSpan(
                            text: 'City',
                            style: TextStyle(color: AppTheme.accent)),
                      ],
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2),

              const SizedBox(height: 12),
              Text(
                'Monitorea la ciudad.\nMantente seguro.',
                style: TextStyle(
                  fontSize: 15,
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
              ).animate().fadeIn(delay: 200.ms),

              const Spacer(),

              // Email
              const Text('CORREO ELECTRÓNICO', style: _labelStyle),
              const SizedBox(height: 8),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'usuario@correo.com',
                  prefixIcon: Icon(Icons.email_outlined,
                      color: AppTheme.textMuted, size: 20),
                ),
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: 20),

              // Contraseña
              const Text('CONTRASEÑA', style: _labelStyle),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordCtrl,
                obscureText: _obscure,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: '••••••••',
                  prefixIcon: const Icon(Icons.lock_outline,
                      color: AppTheme.textMuted, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: AppTheme.textMuted,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscure = !_obscure),
                  ),
                ),
              ).animate().fadeIn(delay: 400.ms),

              const SizedBox(height: 32),

              // Botón iniciar sesión
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _login,
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.bgPrimary,
                          ),
                        )
                      : const Text('Iniciar Sesión'),
                ),
              ).animate().fadeIn(delay: 500.ms),

              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    '¿Olvidaste tu contraseña?',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}

const _labelStyle = TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.w600,
  color: AppTheme.textMuted,
  letterSpacing: 1.2,
);
