import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum UserRole { petani, konsumen, admin }

class AppUser {
  final String name;
  final String identifier; // no HP / email
  final UserRole role;

  const AppUser({
    required this.name,
    required this.identifier,
    required this.role,
  });

  String get roleLabel => switch (role) {
    UserRole.petani => 'Petani',
    UserRole.konsumen => 'Konsumen',
    UserRole.admin => 'Admin',
  };
}

class AuthState {
  final AppUser? user;
  final bool isLoading;
  final String? error;

  const AuthState({this.user, this.isLoading = false, this.error});

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    AppUser? user,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState(isLoading: true)) {
    _restore();
  }

  static const _kSession = 'pangan_session_v1';

  // Akun demo lokal (mock, siap diganti API).
  static final Map<String, _Account> _accounts = {
    '08123456789': _Account(
      name: 'Bapak Sugianto',
      identifier: '08123456789',
      password: 'petani123',
      role: UserRole.petani,
    ),
  };

  Future<void> _restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kSession);
      if (raw != null) {
        final m = jsonDecode(raw) as Map<String, dynamic>;
        final roleName = m['role'] as String?;
        final role = UserRole.values.firstWhere(
          (r) => r.name == roleName,
          orElse: () => UserRole.petani,
        );
        state = AuthState(
          user: AppUser(
            name: (m['name'] as String?) ?? '',
            identifier: (m['identifier'] as String?) ?? '',
            role: role,
          ),
        );
        return;
      }
    } catch (_) {}
    state = const AuthState();
  }

  Future<void> _persist(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kSession,
      jsonEncode({
        'name': user.name,
        'identifier': user.identifier,
        'role': user.role.name,
      }),
    );
  }

  Future<String?> login({
    required String identifier,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    final key = identifier.trim();
    final acc = _accounts[key];
    if (acc == null || acc.password != password) {
      state = state.copyWith(
        isLoading: false,
        error: 'Nomor HP/email atau kata sandi salah.',
      );
      return state.error;
    }
    final user = AppUser(
        name: acc.name, identifier: acc.identifier, role: acc.role);
    await _persist(user);
    state = AuthState(user: user);
    return null;
  }

  Future<String?> register({
    required String name,
    required String identifier,
    required String password,
    required UserRole role,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    await Future<void>.delayed(const Duration(milliseconds: 800));
    final key = identifier.trim();
    if (_accounts.containsKey(key)) {
      state = state.copyWith(
        isLoading: false,
        error: 'Akun dengan nomor HP/email ini sudah terdaftar.',
      );
      return state.error;
    }
    _accounts[key] = _Account(
      name: name.trim(),
      identifier: key,
      password: password,
      role: role,
    );
    final user = AppUser(name: name.trim(), identifier: key, role: role);
    await _persist(user);
    state = AuthState(user: user);
    return null;
  }

  Future<void> updateProfile({String? name, String? identifier, UserRole? role}) async {
    final u = state.user;
    if (u == null) return;
    final next = AppUser(
      name: (name != null && name.trim().isNotEmpty) ? name.trim() : u.name,
      identifier: (identifier != null && identifier.trim().isNotEmpty) ? identifier.trim() : u.identifier,
      role: role ?? u.role,
    );
    // sinkronkan ke akun demo lokal bila ada
    final acc = _accounts[u.identifier];
    if (acc != null) {
      _accounts[u.identifier] = _Account(
        name: next.name,
        identifier: next.identifier,
        password: acc.password,
        role: next.role,
      );
    }
    state = state.copyWith(user: next, clearError: true);
    await _persist(next);
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kSession);
    } catch (_) {}
    state = const AuthState();
  }
}

class _Account {
  final String name;
  final String identifier;
  final String password;
  final UserRole role;
  const _Account({
    required this.name,
    required this.identifier,
    required this.password,
    required this.role,
  });
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);
