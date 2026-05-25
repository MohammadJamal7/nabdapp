import '../../../core/api/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../data/models/auth_models.dart';

class AuthApiService {
  Future<AuthTokens> registerCaregiver(CaregiverRegisterRequest request) async {
    final response = await ApiClient.post(
      ApiConstants.authCaregiverRegister,
      data: request.toJson(),
    );
    return AuthTokens.fromJson(response.data);
  }

  Future<AuthTokens> login(LoginRequest request) async {
    final response = await ApiClient.post(
      ApiConstants.authLogin,
      data: request.toJson(),
    );
    return AuthTokens.fromJson(response.data);
  }

  Future<AuthTokens> refreshToken(RefreshTokenRequest request) async {
    final response = await ApiClient.post(
      ApiConstants.authTokenRefresh,
      data: request.toJson(),
    );
    return AuthTokens.fromJson(response.data);
  }

  Future<void> revokeToken(RevokeTokenRequest request) async {
    await ApiClient.post(
      ApiConstants.authTokenRevoke,
      data: request.toJson(),
    );
  }

  Future<CreatePatientResponse> createPatient(CreatePatientRequest request) async {
    final response = await ApiClient.post(
      ApiConstants.authPatientCreate,
      data: request.toJson(),
    );
    return CreatePatientResponse.fromJson(response.data);
  }

  Future<AuthTokens> activatePatient(ActivatePatientRequest request) async {
    final response = await ApiClient.post(
      ApiConstants.authPatientActivate,
      data: request.toJson(),
    );
    return AuthTokens.fromJson(response.data);
  }

  Future<UserDto> getCurrentPatient() async {
    final response = await ApiClient.get(ApiConstants.patientsMe);
    return UserDto.fromJson(response.data);
  }

  Future<List<PatientSummaryDto>> getPatients() async {
    final response = await ApiClient.get(ApiConstants.patients);
    return (response.data as List)
        .map((e) => PatientSummaryDto.fromJson(e))
        .toList();
  }

  Future<UserDto> getPatientDetail(String patientId) async {
    final response = await ApiClient.get('${ApiConstants.patients}/$patientId');
    return UserDto.fromJson(response.data);
  }
}