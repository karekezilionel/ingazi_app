import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  bool get isAuthenticated => user != null;
  bool get isStudent => user?.isStudent ?? false;
  bool get isStartup => user?.isStartup ?? false;
  bool get isAdmin => user?.isAdmin ?? false;

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(AuthState()) {
    _repository.authStateChanges.listen((firebaseUser) async {
      print('🔍 Auth state changed. Firebase user: ${firebaseUser?.email}');
      if (firebaseUser == null) {
        print('👤 User signed out');
        state = AuthState();
      } else {
        print('👤 User signed in: ${firebaseUser.uid}');
        state = state.copyWith(isLoading: true);
        try {
          final userData = await _repository.getUserData(firebaseUser.uid);
          if (userData != null) {
            print('✅ User data loaded: ${userData.email}, Role: ${userData.role}');
            state = AuthState(user: userData);
          } else {
            print('❌ User data not found in Firestore');
            state = AuthState(error: 'User data not found');
          }
        } catch (e) {
          print('❌ Error loading user data: $e');
          state = AuthState(error: e.toString());
        }
      }
    });
  }

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = await _repository.signUpWithEmail(
        email: email,
        password: password,
        name: name,
        role: role,
      );
      state = AuthState(user: user);
      return user;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = await _repository.signInWithEmail(
        email: email,
        password: password,
      );
      print('✅ Sign in successful: ${user.email}, Role: ${user.role}');
      state = AuthState(user: user);
      return user;
    } catch (e) {
      print('❌ Sign in error: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.signOut();
      state = AuthState();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}