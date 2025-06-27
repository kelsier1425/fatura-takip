import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../config/supabase/supabase_config.dart';
import '../../domain/entities/user_entity.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthState {
  final AuthStatus status;
  final UserEntity? user;
  final String? errorMessage;
  final bool isGuest;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.isGuest = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    String? errorMessage,
    bool? isGuest,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      isGuest: isGuest ?? this.isGuest,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final SupabaseClient _supabase = SupabaseConfig.client;
  
  AuthNotifier() : super(const AuthState(status: AuthStatus.unauthenticated)) {
    _initializeAuth();
  }
  
  void _initializeAuth() {
    // Start with unauthenticated state
    state = const AuthState(status: AuthStatus.unauthenticated);
    
    // Check current session
    final session = _supabase.auth.currentSession;
    if (session != null) {
      _handleAuthStateChange(session);
    }
    
    // Listen to auth state changes
    _supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        _handleAuthStateChange(session);
      } else {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    });
  }
  
  void _handleAuthStateChange(Session session) async {
    final userMetadata = session.user.userMetadata;
    
    // First set basic auth state
    final basicUser = UserEntity(
      id: session.user.id,
      email: session.user.email ?? '',
      name: userMetadata?['name'] ?? 'User',
      isPremium: false,
      subscriptionType: null,
      subscriptionEndDate: null,
      photoUrl: userMetadata?['avatar_url'],
      createdAt: DateTime.parse(session.user.createdAt),
      lastLoginAt: DateTime.now(),
    );
    
    state = AuthState(
      status: AuthStatus.authenticated,
      user: basicUser,
      isGuest: false,
    );
    
    // Then fetch user profile from database
    try {
      final profileResponse = await _supabase
          .from('profiles')
          .select()
          .eq('id', session.user.id)
          .single();
          
      if (profileResponse != null) {
        final updatedUser = UserEntity(
          id: session.user.id,
          email: session.user.email ?? '',
          name: profileResponse['name'] ?? userMetadata?['name'] ?? session.user.email?.split('@').first ?? 'User',
          isPremium: profileResponse['is_premium'] ?? false,
          subscriptionType: profileResponse['subscription_type'],
          subscriptionEndDate: profileResponse['subscription_end_date'] != null 
              ? DateTime.parse(profileResponse['subscription_end_date']) 
              : null,
          photoUrl: profileResponse['photo_url'] ?? userMetadata?['avatar_url'],
          createdAt: DateTime.parse(session.user.createdAt),
          lastLoginAt: DateTime.now(),
        );
        
        state = AuthState(
          status: AuthStatus.authenticated,
          user: updatedUser,
          isGuest: false,
        );
      }
    } catch (e) {
      print('🔥 Error fetching user profile: $e');
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.session == null) {
        throw Exception('Giriş başarısız');
      }
      
      // Auth state change listener will handle the state update
    } on AuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _getAuthErrorMessage(e),
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Giriş yapılırken bir hata oluştu: ${e.toString()}',
      );
    }
  }

  Future<void> register(String email, String password, String name) async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      print('🔥 Starting registration for: $email');
      
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
        },
      );
      
      print('🔥 SignUp response: ${response.user?.id}');
      print('🔥 Session: ${response.session?.accessToken != null}');
      
      if (response.user == null) {
        throw Exception('Kayıt başarısız - User null');
      }
      
      // Don't create profile here - let trigger handle it
      // Profile will be created automatically by trigger
      
      // Registration successful, set as authenticated if session exists
      if (response.session != null) {
        // Auto-logged in, set as authenticated
        state = state.copyWith(
          status: AuthStatus.authenticated,
          errorMessage: null,
        );
      } else {
        // Email verification required
        state = state.copyWith(
          status: AuthStatus.authenticated, // Changed to authenticated to show success dialog
          errorMessage: null,
        );
      }
      
      print('🔥 Registration completed successfully');
      
    } on AuthException catch (e) {
      print('🔥 Auth Exception: ${e.message}');
      print('🔥 Auth Exception Details: ${e.toString()}');
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _getAuthErrorMessage(e),
      );
    } catch (e) {
      print('🔥 General Exception: ${e.toString()}');
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Kayıt olurken bir hata oluştu: ${e.toString()}',
      );
    }
  }

  Future<void> loginWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      // TODO: Implement Google Sign In with Supabase
      // For now, we'll show a message
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Google ile giriş yakında eklenecek',
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Google ile giriş yapılırken bir hata oluştu: ${e.toString()}',
      );
    }
  }

  Future<void> loginAsGuest() async {
    // Guest login is not supported with Supabase
    // Show a message to encourage user registration
    state = state.copyWith(
      status: AuthStatus.error,
      errorMessage: 'Ücretsiz hesap oluşturarak tüm özellikleri kullanabilirsiniz',
    );
  }

  Future<void> forgotPassword(String email) async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      await _supabase.auth.resetPasswordForEmail(email);
      
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: 'Şifre sıfırlama e-postası gönderildi. Lütfen e-postanızı kontrol edin.',
      );
    } on AuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _getAuthErrorMessage(e),
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Şifre sıfırlama e-postası gönderilirken bir hata oluştu',
      );
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      await _supabase.auth.signOut();
      state = const AuthState(status: AuthStatus.unauthenticated);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Çıkış yapılırken bir hata oluştu',
      );
    }
  }

  Future<void> logout() async {
    await signOut();
  }

  Future<void> verifyEmail(String token) async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final response = await _supabase.auth.verifyOTP(
        token: token,
        type: OtpType.signup,
      );
      
      if (response.session != null) {
        // Email verification successful, user is now authenticated
        // The auth state change listener will handle the state update
        state = state.copyWith(
          status: AuthStatus.authenticated,
          errorMessage: 'Email başarıyla doğrulandı!',
        );
      } else {
        throw Exception('Email doğrulama başarısız');
      }
    } on AuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _getAuthErrorMessage(e),
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Email doğrulama sırasında bir hata oluştu: ${e.toString()}',
      );
    }
  }

  Future<void> handleEmailVerificationFromUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      final token = uri.queryParameters['token'];
      
      if (token != null) {
        await verifyEmail(token);
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Geçersiz doğrulama linki',
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Email doğrulama linkini işlerken bir hata oluştu',
      );
    }
  }

  void clearError() {
    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      errorMessage: null,
    );
  }

  void checkAuthStatus() {
    _initializeAuth();
  }

  Future<void> clearSession() async {
    try {
      await _supabase.auth.signOut();
      state = const AuthState(status: AuthStatus.unauthenticated);
    } catch (e) {
      // Ignore errors and force unauthenticated state
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }
  
  String _getAuthErrorMessage(AuthException e) {
    switch (e.message) {
      case 'Invalid login credentials':
        return 'Geçersiz e-posta veya şifre';
      case 'Email not confirmed':
        return 'E-posta adresinizi doğrulamanız gerekiyor';
      case 'User already registered':
        return 'Bu e-posta adresi zaten kayıtlı';
      default:
        return e.message ?? 'Bir hata oluştu';
    }
  }
}

// Provider instances
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

// Computed providers
final currentUserProvider = Provider<UserEntity?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.status == AuthStatus.authenticated;
});

final isGuestProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.isGuest;
});

final isPremiumProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.isPremium ?? false;
});