import '../../../core/api/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../data/patient_models.dart';

class PatientApiService {
  Future<List<MedicationDto>> getMedications(String patientId) async {
    final response = await ApiClient.get(
      ApiConstants.medications.replaceAll('{patientId}', patientId),
    );
    return (response.data as List).map((e) => MedicationDto.fromJson(e)).toList();
  }

  Future<MedicationDto> getMedication(String patientId, String medicationId) async {
    final response = await ApiClient.get(
      '${ApiConstants.medications.replaceAll('{patientId}', patientId)}/$medicationId',
    );
    return MedicationDto.fromJson(response.data);
  }

  Future<MedicationDto> createMedication(String patientId, CreateMedicationCommand command) async {
    final response = await ApiClient.post(
      ApiConstants.medications.replaceAll('{patientId}', patientId),
      data: command.toJson(patientId),
    );
    return MedicationDto.fromJson(response.data);
  }

  Future<void> updateMedication(String patientId, String medicationId, CreateMedicationCommand command) async {
    await ApiClient.put(
      '${ApiConstants.medications.replaceAll('{patientId}', patientId)}/$medicationId',
      data: command.toJson(patientId),
    );
  }

  Future<void> deleteMedication(String patientId, String medicationId) async {
    await ApiClient.delete(
      '${ApiConstants.medications.replaceAll('{patientId}', patientId)}/$medicationId',
    );
  }

  Future<List<MedicationLogDto>> getMedicationLogs({
    required String patientId,
    String? medicationId,
    String? date,
    int page = 1,
    int pageSize = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'patientId': patientId,
      'page': page,
      'pageSize': pageSize,
    };
    if (medicationId != null) queryParams['medicationId'] = medicationId;
    if (date != null) queryParams['date'] = date;

    final response = await ApiClient.get(
      ApiConstants.medicationLogs,
      queryParameters: queryParams,
    );
    return (response.data as List).map((e) => MedicationLogDto.fromJson(e)).toList();
  }

  Future<MedicationLogDto> markMedicationTaken(String logId) async {
    final response = await ApiClient.post(
      ApiConstants.medicationLogsTaken.replaceAll('{logId}', logId),
    );
    return MedicationLogDto.fromJson(response.data);
  }

  Future<MedicationLogDto> snoozeMedication(String logId) async {
    final response = await ApiClient.post(
      ApiConstants.medicationLogsSnooze.replaceAll('{logId}', logId),
    );
    return MedicationLogDto.fromJson(response.data);
  }

  Future<VitalSignReadingDto> recordVital(RecordVitalCommand command) async {
    final response = await ApiClient.post(
      ApiConstants.vitals,
      data: command.toJson(),
    );
    return VitalSignReadingDto.fromJson(response.data);
  }

  Future<List<VitalSignReadingDto>> getVitals(String patientId, {String? readingType, int page = 1, int pageSize = 20}) async {
    final response = await ApiClient.get(
      ApiConstants.vitalsPatient.replaceAll('{patientId}', patientId),
      queryParameters: {
        if (readingType != null) 'type': readingType,
        'page': page,
        'pageSize': pageSize,
      },
    );
    return (response.data as List).map((e) => VitalSignReadingDto.fromJson(e)).toList();
  }

  Future<List<VitalSignSummaryDto>> getVitalSummary(String patientId) async {
    final response = await ApiClient.get(
      ApiConstants.vitalsSummary.replaceAll('{patientId}', patientId),
    );
    return (response.data as List).map((e) => VitalSignSummaryDto.fromJson(e)).toList();
  }

  Future<List<VitalSignThresholdDto>> getThresholds(String patientId) async {
    final response = await ApiClient.get(
      '${ApiConstants.patients}/$patientId/thresholds',
    );
    return (response.data as List).map((e) => VitalSignThresholdDto.fromJson(e)).toList();
  }

  Future<void> setThresholds(String patientId, List<SetThresholdItemDto> thresholds) async {
    await ApiClient.put(
      '${ApiConstants.patients}/$patientId/thresholds',
      data: thresholds.map((e) => e.toJson()).toList(),
    );
  }

  Future<EmergencyAlertDto> createSosAlert({double? latitude, double? longitude}) async {
    final response = await ApiClient.post(
      ApiConstants.alertsSos,
      data: {
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      },
    );
    return EmergencyAlertDto.fromJson(response.data);
  }

  Future<List<EmergencyAlertDto>> getAlerts(String patientId, {String? status, int page = 1, int pageSize = 20}) async {
    final response = await ApiClient.get(
      ApiConstants.patientAlerts.replaceAll('{patientId}', patientId),
      queryParameters: {
        if (status != null) 'status': status,
        'page': page,
        'pageSize': pageSize,
      },
    );
    return (response.data as List).map((e) => EmergencyAlertDto.fromJson(e)).toList();
  }

  Future<AlertDetailDto> getAlertDetail(String patientId, String alertId) async {
    final response = await ApiClient.get(
      ApiConstants.patientAlertsDetail
          .replaceAll('{patientId}', patientId)
          .replaceAll('{alertId}', alertId),
    );
    return AlertDetailDto.fromJson(response.data);
  }

  Future<void> acknowledgeAlert(String patientId, String alertId) async {
    await ApiClient.post(
      ApiConstants.patientAlertsAcknowledge
          .replaceAll('{patientId}', patientId)
          .replaceAll('{alertId}', alertId),
    );
  }

  Future<void> cancelAlert(String patientId, String alertId) async {
    await ApiClient.post(
      ApiConstants.patientAlertsCancel
          .replaceAll('{patientId}', patientId)
          .replaceAll('{alertId}', alertId),
    );
  }

  Future<List<InsightDto>> getInsights(String patientId) async {
    final response = await ApiClient.get(
      ApiConstants.insights.replaceAll('{patientId}', patientId),
    );
    return (response.data as List).map((e) => InsightDto.fromJson(e)).toList();
  }

  Future<List<ArticleDto>> getArticles({String? conditionTag}) async {
    final response = await ApiClient.get(
      ApiConstants.articles,
      queryParameters: {
        if (conditionTag != null) 'conditionTag': conditionTag,
      },
    );
    if (response.statusCode == 304 || response.data == null) return [];
    return (response.data as List).map((e) => ArticleDto.fromJson(e)).toList();
  }

  Future<ArticleDto> getArticleById(String articleId) async {
    final response = await ApiClient.get(
      ApiConstants.articlesById.replaceAll('{articleId}', articleId),
    );
    if (response.statusCode == 304 || response.data == null) {
      throw Exception('Article not modified');
    }
    return ArticleDto.fromJson(response.data);
  }

  Future<void> registerDeviceToken(String fcmToken) async {
    await ApiClient.post(
      ApiConstants.deviceTokens,
      data: {'fcmToken': fcmToken},
    );
  }
}