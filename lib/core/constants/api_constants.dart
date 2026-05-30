class ApiConstants {
 // static const String baseUrl = 'http://192.168.1.122:5000';
  static const String baseUrl = 'https://nabd-5ure.onrender.com/api';
  static const String authLogin = '/auth/login';
  static const String authTokenRefresh = '/auth/token/refresh';
  static const String authTokenRevoke = '/auth/token/revoke';
  static const String authPatientCreate = '/auth/patient/create';
  static const String authPatientActivate = '/auth/patient/activate';
  static const String authCaregiverRegister = '/auth/caregiver/register';

  static const String patients = '/patients';
  static const String patientsMe = '/patients/me';

  static const String caregiversLinkInitiate = '/caregivers/link/initiate';
  static const String caregiversLinkApprove = '/caregivers/link/approve';

  static const String medications = '/patients/{patientId}/medications';
  static const String medicationLogs = '/medication-logs';
  static const String medicationLogsTaken = '/medication-logs/{logId}/taken';
  static const String medicationLogsSnooze = '/medication-logs/{logId}/snooze';

  static const String vitals = '/vitals';
  static const String vitalsPatient = '/vitals/{patientId}';
  static const String vitalsSummary = '/vitals/{patientId}/summary';

  static const String alerts = '/alerts';
  static const String alertsSos = '/alerts/sos';
  static const String patientAlerts = '/patients/{patientId}/alerts';
  static const String patientAlertsDetail = '/patients/{patientId}/alerts/{alertId}/detail';
  static const String patientAlertsAcknowledge = '/patients/{patientId}/alerts/{alertId}/acknowledge';
  static const String patientAlertsCancel = '/patients/{patientId}/alerts/{alertId}/cancel';

  static const String insights = '/patients/{patientId}/insights';

  static const String articles = '/articles';
  static const String articlesById = '/articles/{articleId}';

  static const String deviceTokens = '/device-tokens';

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