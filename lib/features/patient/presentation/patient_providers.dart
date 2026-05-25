import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/patient_models.dart';
import '../data/patient_api_service.dart';

final patientApiServiceProvider = Provider((ref) => PatientApiService());

final medicationsProvider = FutureProvider.family<List<MedicationDto>, String>((ref, patientId) async {
  final apiService = ref.watch(patientApiServiceProvider);
  return await apiService.getMedications(patientId);
});

final medicationLogsProvider = FutureProvider.family<List<MedicationLogDto>, ({String patientId, String? medicationId, String? date})>((ref, params) async {
  final apiService = ref.watch(patientApiServiceProvider);
  return await apiService.getMedicationLogs(
    patientId: params.patientId,
    medicationId: params.medicationId,
    date: params.date,
  );
});

final vitalsProvider = FutureProvider.family<List<VitalSignReadingDto>, ({String patientId, String? type})>((ref, params) async {
  final apiService = ref.watch(patientApiServiceProvider);
  return await apiService.getVitals(params.patientId, readingType: params.type);
});

final vitalSummaryProvider = FutureProvider.family<List<VitalSignSummaryDto>, String>((ref, patientId) async {
  final apiService = ref.watch(patientApiServiceProvider);
  return await apiService.getVitalSummary(patientId);
});

final thresholdsProvider = FutureProvider.family<List<VitalSignThresholdDto>, String>((ref, patientId) async {
  final apiService = ref.watch(patientApiServiceProvider);
  return await apiService.getThresholds(patientId);
});

final alertsProvider = FutureProvider.family<List<EmergencyAlertDto>, ({String patientId, String? status})>((ref, params) async {
  final apiService = ref.watch(patientApiServiceProvider);
  return await apiService.getAlerts(params.patientId, status: params.status);
});

final alertDetailProvider = FutureProvider.family<AlertDetailDto, ({String patientId, String alertId})>((ref, params) async {
  final apiService = ref.watch(patientApiServiceProvider);
  return await apiService.getAlertDetail(params.patientId, params.alertId);
});

final insightsProvider = FutureProvider.family<List<InsightDto>, String>((ref, patientId) async {
  final apiService = ref.watch(patientApiServiceProvider);
  return await apiService.getInsights(patientId);
});

final articlesProvider = FutureProvider.family<List<ArticleDto>, String?>((ref, conditionTag) async {
  final apiService = ref.watch(patientApiServiceProvider);
  return await apiService.getArticles(conditionTag: conditionTag);
});

class MedicationNotifier extends StateNotifier<AsyncValue<void>> {
  final PatientApiService _apiService;
  final String patientId;

  MedicationNotifier(this._apiService, this.patientId) : super(const AsyncValue.data(null));

  Future<void> createMedication(CreateMedicationCommand command) async {
    state = const AsyncValue.loading();
    try {
      await _apiService.createMedication(patientId, command);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateMedication(String medicationId, CreateMedicationCommand command) async {
    state = const AsyncValue.loading();
    try {
      await _apiService.updateMedication(patientId, medicationId, command);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteMedication(String medicationId) async {
    state = const AsyncValue.loading();
    try {
      await _apiService.deleteMedication(patientId, medicationId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markTaken(String logId) async {
    state = const AsyncValue.loading();
    try {
      await _apiService.markMedicationTaken(logId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> snooze(String logId) async {
    state = const AsyncValue.loading();
    try {
      await _apiService.snoozeMedication(logId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final medicationNotifierProvider = StateNotifierProvider.family<MedicationNotifier, AsyncValue<void>, String>((ref, patientId) {
  final apiService = ref.watch(patientApiServiceProvider);
  return MedicationNotifier(apiService, patientId);
});

class VitalsNotifier extends StateNotifier<AsyncValue<void>> {
  final PatientApiService _apiService;

  VitalsNotifier(this._apiService) : super(const AsyncValue.data(null));

  Future<VitalSignReadingDto> recordVital(RecordVitalCommand command) async {
    state = const AsyncValue.loading();
    try {
      final result = await _apiService.recordVital(command);
      state = const AsyncValue.data(null);
      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final vitalsNotifierProvider = StateNotifierProvider<VitalsNotifier, AsyncValue<void>>((ref) {
  final apiService = ref.watch(patientApiServiceProvider);
  return VitalsNotifier(apiService);
});

class AlertsNotifier extends StateNotifier<AsyncValue<void>> {
  final PatientApiService _apiService;

  AlertsNotifier(this._apiService) : super(const AsyncValue.data(null));

  Future<EmergencyAlertDto> createSos({double? latitude, double? longitude}) async {
    state = const AsyncValue.loading();
    try {
      final result = await _apiService.createSosAlert(latitude: latitude, longitude: longitude);
      state = const AsyncValue.data(null);
      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> acknowledge(String patientId, String alertId) async {
    state = const AsyncValue.loading();
    try {
      await _apiService.acknowledgeAlert(patientId, alertId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> cancel(String patientId, String alertId) async {
    state = const AsyncValue.loading();
    try {
      await _apiService.cancelAlert(patientId, alertId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final alertsNotifierProvider = StateNotifierProvider<AlertsNotifier, AsyncValue<void>>((ref) {
  final apiService = ref.watch(patientApiServiceProvider);
  return AlertsNotifier(apiService);
});