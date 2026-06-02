class AuthTokens {
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;
  final String role;

  AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.role,
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) => AuthTokens(
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String,
        expiresAt: DateTime.parse(json['expiresAt'] as String),
        role: json['role'] as String? ?? 'Patient',
      );

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'expiresAt': expiresAt.toIso8601String(),
        'role': role,
      };
}

class CaregiverRegisterRequest {
  final String phoneNumber;
  final String firstName;
  final String lastName;

  CaregiverRegisterRequest({
    required this.phoneNumber,
    required this.firstName,
    required this.lastName,
  });

  Map<String, dynamic> toJson() => {
        'phoneNumber': phoneNumber,
        'firstName': firstName,
        'lastName': lastName,
      };
}

class LoginRequest {
  final String phoneNumber;

  LoginRequest({required this.phoneNumber});

  Map<String, dynamic> toJson() => {'phoneNumber': phoneNumber};
}

class RefreshTokenRequest {
  final String token;

  RefreshTokenRequest({required this.token});

  Map<String, dynamic> toJson() => {'token': token};
}

class RevokeTokenRequest {
  final String token;

  RevokeTokenRequest({required this.token});

  Map<String, dynamic> toJson() => {'token': token};
}

class CreatePatientRequest {
  final String phoneNumber;
  final String firstName;
  final String lastName;
  final String dateOfBirth;
  final String gender;
  final String? bloodType;
  final List<String>? conditions;

  CreatePatientRequest({
    required this.phoneNumber,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.gender,
    this.bloodType,
    this.conditions,
  });

  Map<String, dynamic> toJson() => {
        'phoneNumber': phoneNumber,
        'firstName': firstName,
        'lastName': lastName,
        'dateOfBirth': dateOfBirth,
        'gender': gender,
        if (bloodType != null) 'bloodType': bloodType,
        if (conditions != null) 'conditions': conditions,
      };
}

class CreatePatientResponse {
  final String activationCode;
  final String patientId;

  CreatePatientResponse({
    required this.activationCode,
    required this.patientId,
  });

  factory CreatePatientResponse.fromJson(Map<String, dynamic> json) =>
      CreatePatientResponse(
        activationCode: json['activationCode'] as String,
        patientId: json['patientId'] as String,
      );
}

class ActivatePatientRequest {
  final String activationCode;
  final String phoneNumber;

  ActivatePatientRequest({
    required this.activationCode,
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() => {
        'activationCode': activationCode,
        'phoneNumber': phoneNumber,
      };
}

class UserDto {
  final String id;
  final String? firstNameAr;
  final String? lastNameAr;
  final String? dateOfBirth;
  final String? gender;
  final bool? isActivated;
  final String? bloodType;
  final List<String>? conditions;
  final int? linkedCaregiverCount;

  UserDto({
    required this.id,
    this.firstNameAr,
    this.lastNameAr,
    this.dateOfBirth,
    this.gender,
    this.isActivated,
    this.bloodType,
    this.conditions,
    this.linkedCaregiverCount,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) => UserDto(
        id: json['id'] as String,
        firstNameAr: json['firstNameAr'] as String?,
        lastNameAr: json['lastNameAr'] as String?,
        dateOfBirth: json['dateOfBirth'] as String?,
        gender: json['gender'] as String?,
        isActivated: json['isActivated'] as bool?,
        bloodType: json['bloodType'] as String?,
        conditions: (json['conditions'] as List<dynamic>?)?.cast<String>(),
        linkedCaregiverCount: json['linkedCaregiverCount'] as int?,
      );

  String get fullName => '${firstNameAr ?? ''} ${lastNameAr ?? ''}'.trim();
}

class PatientSummaryDto {
  final String id;
  final String? firstNameAr;
  final String? lastNameAr;
  final String? dateOfBirth;
  final String? gender;
  final bool? isActivated;
  PatientSummaryDto({
    required this.id,
    this.firstNameAr,
    this.lastNameAr,
    this.dateOfBirth,
    this.gender,
    this.isActivated,
  });

  factory PatientSummaryDto.fromJson(Map<String, dynamic> json) =>
      PatientSummaryDto(
        id: json['id'] as String,
        firstNameAr: json['firstNameAr'] as String?,
        lastNameAr: json['lastNameAr'] as String?,
        dateOfBirth: json['dateOfBirth'] as String?,
        gender: json['gender'] as String?,
        isActivated: json['isActivated'] as bool?,
      );

  String get fullName => '${firstNameAr ?? ''} ${lastNameAr ?? ''}'.trim();
}