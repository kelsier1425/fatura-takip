import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/animated_button.dart';
import '../../../../core/widgets/animated_text_field.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../widgets/auth_header.dart';
import '../providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    print('🔥 Login attempt for: ${_emailController.text}');
    
    final authNotifier = ref.read(authProvider.notifier);
    
    try {
      await authNotifier.login(_emailController.text, _passwordController.text);
      
      final authState = ref.read(authProvider);
      if (authState.status == AuthStatus.authenticated) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Giriş başarılı!'),
              backgroundColor: Colors.green,
            ),
          );
          context.go('/home');
        }
      } else if (authState.status == AuthStatus.error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(authState.errorMessage ?? 'Giriş başarısız')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Giriş başarısız: $e')),
        );
      }
    }
  }

  Future<void> _handleGuestLogin() async {
    final authNotifier = ref.read(authProvider.notifier);
    
    try {
      await authNotifier.loginAsGuest();
      
      final authState = ref.read(authProvider);
      if (authState.status == AuthStatus.authenticated) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Misafir olarak giriş yapıldı'),
              backgroundColor: Colors.green,
            ),
          );
          context.go('/home');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  Future<void> _handleGoogleLogin() async {
    final authNotifier = ref.read(authProvider.notifier);
    
    try {
      await authNotifier.loginWithGoogle();
      
      final authState = ref.read(authProvider);
      if (authState.status == AuthStatus.authenticated) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Google ile giriş başarılı!'),
              backgroundColor: Colors.green,
            ),
          );
          context.go('/home');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google girişi başarısız: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final isLoading = authState.status == AuthStatus.loading;
    
    // Listen for auth state changes
    ref.listen<AuthState>(authProvider, (previous, next) {
      print('🔥 Auth state changed: ${previous?.status} -> ${next.status}');
      if (next.status == AuthStatus.authenticated && mounted) {
        context.go('/home');
      }
    });
    
    return LoadingOverlay(
      isLoading: isLoading,
      loadingText: 'Giriş yapılıyor...',
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    const AuthHeader(
                      title: 'Hoş Geldiniz',
                      subtitle: 'Hesabınıza giriş yapın',
                    ),
                    const SizedBox(height: 48),
                    AnimatedTextField(
                      controller: _emailController,
                      labelText: 'E-posta',
                      hintText: 'ornek@email.com',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email_outlined),
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 16),
                    AnimatedTextField(
                      controller: _passwordController,
                      labelText: 'Şifre',
                      hintText: '••••••••',
                      obscureText: !_isPasswordVisible,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: _togglePasswordVisibility,
                      ),
                      validator: Validators.password,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context.push('/forgot-password'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                        ),
                        child: const Text('Şifremi Unuttum'),
                      ),
                    ),
                    const SizedBox(height: 24),
                    AnimatedButton(
                      onPressed: _handleLogin,
                      child: const Text('Giriş Yap'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 1,
                            color: theme.dividerColor,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'veya',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: theme.dividerColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AnimatedButton(
                      onPressed: _handleGoogleLogin,
                      backgroundColor: theme.colorScheme.surface,
                      foregroundColor: theme.colorScheme.onSurface,
                      elevation: 1,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.account_circle_outlined, size: 20),
                          SizedBox(width: 12),
                          Text('Google ile Giriş Yap'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    AnimatedButton(
                      onPressed: _handleGuestLogin,
                      backgroundColor: theme.colorScheme.secondary,
                      foregroundColor: Colors.white,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_outline, size: 20),
                          SizedBox(width: 12),
                          Text('Misafir Olarak Devam Et'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Hesabınız yok mu?',
                          style: theme.textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: () => context.push('/register'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                          ),
                          child: const Text('Kayıt Ol'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}