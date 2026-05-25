class ApiConstants {
  static const String baseUrl = 'http://192.168.1.122:5000';

  static const String authCaregiverRegister = '/api/auth/caregiver/register';
  static const String authLogin = '/api/auth/login';
  static const String authTokenRefresh = '/api/auth/token/refresh';
  static const String authTokenRevoke = '/api/auth/token/revoke';
  static const String authPatientCreate = '/api/auth/patient/create';
  static const String authPatientActivate = '/api/auth/patient/activate';

  static const String patients = '/api/patients';
  static const String patientsMe = '/api/patients/me';

  static const String caregiversLinkInitiate = '/api/caregivers/link/initiate';
  static const String caregiversLinkApprove = '/api/caregivers/link/approve';

  static const String medications = '/api/patients/{patientId}/medications';
  static const String medicationLogs = '/api/medication-logs';
  static const String medicationLogsTaken = '/api/medication-logs/{logId}/taken';
  static const String medicationLogsSnooze = '/api/medication-logs/{logId}/snooze';

  static const String vitals = '/api/vitals';
  static const String vitalsPatient = '/api/vitals/{patientId}';
  static const String vitalsSummary = '/api/vitals/{patientId}/summary';

  static const String alerts = '/api/alerts';
  static const String alertsSos = '/api/alerts/sos';
  static const String patientAlerts = '/api/patients/{patientId}/alerts';
  static const String patientAlertsDetail = '/api/patients/{patientId}/alerts/{alertId}/detail';
  static const String patientAlertsAcknowledge = '/api/patients/{patientId}/alerts/{alertId}/acknowledge';
  static const String patientAlertsCancel = '/api/patients/{patientId}/alerts/{alertId}/cancel';

  static const String insights = '/api/patients/{patientId}/insights';

  static const String articles = '/api/articles';
  static const String articlesById = '/api/articles/{articleId}';

  static const String deviceTokens = '/api/device-tokens';

  static const String signalRHub = '/hubs/caregiver-dashboard';

  static const int apiTimeoutSeconds = 30;
}

class StorageKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String tokenExpiry = 'token_expiry';
  static const String userRole = 'user_role';
  static const String userId = 'user_id';
  static const String patientId = 'patient_id';
  static const String fcmToken = 'fcm_token';
  static const String onboardingComplete = 'onboarding_complete';
}

class AppConstants {
  static const int accessTokenExpiryMinutes = 15;
  static const int refreshTokenExpiryDays = 7;
  static const int sosCountdownSeconds = 10;
  static const int maxSnoozeCount = 3;
  static const int snoozeDurationMinutes = 15;
}