import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthState {
  final bool isAuthenticated;
  final String? userId;
  final String? email;
  final String? displayName;

  AuthState({
    this.isAuthenticated = false,
    this.userId,
    this.email,
    this.displayName,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? userId,
    String? email,
    String? displayName,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
    );
  }
}

class AuthService extends StateNotifier<AuthState> {
  AuthService() : super(AuthState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    // Check if user is already logged in
    // This would typically check SharedPreferences or a local database
    await Future.delayed(const Duration(milliseconds: 500));
    // For now, default to unauthenticated
  }

  Future<void> login(String email, String password) async {
    try {
      // Implement your authentication logic here
      // This is a placeholder implementation
      state = AuthState(
        isAuthenticated: true,
        userId: 'user_123',
        email: email,
        displayName: email.split('@').first,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      // Implement your logout logic here
      state = AuthState();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> register(String email, String password) async {
    try {
      // Implement your registration logic here
      state = AuthState(
        isAuthenticated: true,
        userId: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        displayName: email.split('@').first,
      );
    } catch (e) {
      rethrow;
    }
  }
}

final authProvider = StateNotifierProvider<AuthService, AuthState>((ref) {
  return AuthService();
});
