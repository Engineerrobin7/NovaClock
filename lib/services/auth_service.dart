import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// User Model
class User {
  final String id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        name: json['name'],
        email: json['email'],
      );
}

// Auth State
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get isAuthenticated => user != null;
}

// Auth Service
class AuthService extends StateNotifier<AuthState> {
  AuthService() : super(const AuthState()) {
    _loadUser();
  }

  // Load saved user on app start
  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    
    if (userJson != null) {
      final user = User.fromJson(json.decode(userJson));
      state = state.copyWith(user: user);
    }
  }

  // Email validation
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Password validation
  String? validatePassword(String password) {
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  // Sign Up
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    if (name.isEmpty) {
      state = state.copyWith(error: 'Name is required');
      return false;
    }

    if (!_isValidEmail(email)) {
      state = state.copyWith(error: 'Invalid email format');
      return false;
    }

    final passwordError = validatePassword(password);
    if (passwordError != null) {
      state = state.copyWith(error: passwordError);
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Check if user already exists
      final existingEmail = prefs.getString('email');
      if (existingEmail == email) {
        state = state.copyWith(
          isLoading: false,
          error: 'Account already exists with this email',
        );
        return false;
      }

      // Create user
      final userId = DateTime.now().millisecondsSinceEpoch.toString();
      final user = User(id: userId, name: name, email: email);

      // Save credentials
      await prefs.setString('email', email);
      await prefs.setString('password', password);
      await prefs.setString('user', json.encode(user.toJson()));

      state = state.copyWith(user: user, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to create account',
      );
      return false;
    }
  }

  // Login
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    if (!_isValidEmail(email)) {
      state = state.copyWith(error: 'Invalid email format');
      return false;
    }

    if (password.isEmpty) {
      state = state.copyWith(error: 'Password is required');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('email');
      final savedPassword = prefs.getString('password');

      if (savedEmail == email && savedPassword == password) {
        final userJson = prefs.getString('user');
        if (userJson != null) {
          final user = User.fromJson(json.decode(userJson));
          state = state.copyWith(user: user, isLoading: false);
          return true;
        }
      }

      state = state.copyWith(
        isLoading: false,
        error: 'Invalid email or password',
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to login',
      );
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    state = const AuthState();
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider
final authProvider = StateNotifierProvider<AuthService, AuthState>((ref) {
  return AuthService();
});
