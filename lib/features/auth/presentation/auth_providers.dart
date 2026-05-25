import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/storage_service.dart';
import '../../../core/signalr/signalr_service.dart';
import '../data/auth_api_service.dart';
import '../data/models/auth_models.dart';

enum UserRole { caregiver, patient }

final authApiServiceProvider = Provider((ref) => AuthApiService());

final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  return AuthStateNotifier(ref.watch(authApiServiceProvider));
});

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final UserRole? role;
  final String? userId;
  final String? patientId;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.role,
    this.userId,
    this.patientId,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    UserRole? role,
    String? userId,
    String? patientId,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      role: role ?? this.role,
      userId: userId ?? this.userId,
      patientId: patientId ?? this.patientId,
      error: error,
    );
  }
}

class AuthStateNotifier extends StateNotifier<AuthState> {
  final AuthApiService _apiService;

  AuthStateNotifier(this._apiService) : super(const AuthState()) {
    _checkAuthStatus();
  }

  Map<String, dynamic> _decodeJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return {};
      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      return json.decode(payload) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  void _checkAuthStatus() {
    if (StorageService.isAuthenticated) {
      final roleStr = StorageService.userRole;
      final role = roleStr == 'Caregiver' ? UserRole.caregiver : UserRole.patient;
      state = AuthState(
        isAuthenticated: true,
        role: role,
        userId: StorageService.userId,
        patientId: StorageService.patientId,
      );
    }
  }

  Future<void> _handleTokenSuccess(AuthTokens tokens) async {
    await StorageService.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
      expiresAt: tokens.expiresAt,
    );
    final role = tokens.role == 'Caregiver' ? UserRole.caregiver : UserRole.patient;

    // Decode JWT to extract userId/patientId
    final claims = _decodeJwt(tokens.accessToken);
    final userId = claims['sub'] as String? ?? '';
    final patientId = claims['patientId'] as String?;

    await StorageService.saveUserSession(
      userId: userId,
      role: tokens.role,
      patientId: patientId,
    );

    state = state.copyWith(
      isLoading: false,
      isAuthenticated: true,
      role: role,
      userId: userId,
      patientId: patientId,
    );
  }

  Future<void> login(String phoneNumber) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final tokens = await _apiService.login(LoginRequest(phoneNumber: phoneNumber));
      await _handleTokenSuccess(tokens);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> registerCaregiver(String phoneNumber, String firstName, String lastName) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final tokens = await _apiService.registerCaregiver(
        CaregiverRegisterRequest(
          phoneNumber: phoneNumber,
          firstName: firstName,
          lastName: lastName,
        ),
      );
      await _handleTokenSuccess(tokens);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<CreatePatientResponse> createPatient(CreatePatientRequest request) async {
    return await _apiService.createPatient(request);
  }

  Future<void> activatePatient(String activationCode, String phoneNumber) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final tokens = await _apiService.activatePatient(
        ActivatePatientRequest(
          activationCode: activationCode,
          phoneNumber: phoneNumber,
        ),
      );
      await _handleTokenSuccess(tokens);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> logout() async {
    await SignalRService.disconnect();
    try {
      final refreshToken = StorageService.refreshToken;
      if (refreshToken != null) {
        await _apiService.revokeToken(RevokeTokenRequest(token: refreshToken));
      }
    } catch (_) {}
    await StorageService.clearAll();
    state = const AuthState();
  }
}

final currentUserProvider = FutureProvider<UserDto>((ref) async {
  final authState = ref.watch(authStateProvider);
  if (!authState.isAuthenticated || authState.role != UserRole.patient) {
    throw Exception('Not authorized');
  }
  final apiService = ref.watch(authApiServiceProvider);
  return await apiService.getCurrentPatient();
});

final patientsListProvider = FutureProvider<List<PatientSummaryDto>>((ref) async {
  final authState = ref.watch(authStateProvider);
  if (!authState.isAuthenticated || authState.role != UserRole.caregiver) {
    throw Exception('Not authorized');
  }
  final apiService = ref.watch(authApiServiceProvider);
  return await apiService.getPatients();
});