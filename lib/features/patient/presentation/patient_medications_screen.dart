import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme/app_theme.dart';
import '../../auth/presentation/auth_providers.dart';
import '../data/patient_models.dart';
import '../presentation/patient_providers.dart';

class PatientMedicationsScreen extends ConsumerWidget {
  const PatientMedicationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final patientId = authState.patientId ?? '';
    final today = DateTime.now().toIso8601String().split('T')[0];

    final logsAsync = ref.watch(medicationLogsProvider((patientId: patientId, medicationId: null, date: today)));
    final medsAsync = ref.watch(medicationsProvider(patientId));

    return Scaffold(
      appBar: AppBar(title: const Text('الأدوية')),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(medicationsProvider(patientId));
            ref.invalidate(medicationLogsProvider((patientId: patientId, medicationId: null, date: today)));
          },
          child: medsAsync.when(
            data: (meds) {
              if (meds.isEmpty) {
                return const Center(
                  child: Text('لا توجد أدوية مسجلة', style: TextStyle(color: AppTheme.textSecondary)),
                );
              }
              return logsAsync.when(
                data: (logs) => ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    final log = logs[index];
                    final med = meds.firstWhere(
                      (m) => m.id == log.medicationId,
                      orElse: () => MedicationDto(
                        id: '',
                        name: 'غير معروف',
                        dosageAmount: '',
                        dosageUnit: '',
                        frequencyType: '',
                        scheduledTimes: [],
                      ),
                    );
                    return _MedicationLogCard(
                      log: log,
                      medication: med,
                      onTaken: () async {
                        await ref.read(medicationNotifierProvider(patientId).notifier).markTaken(log.id);
                        ref.invalidate(medicationLogsProvider((patientId: patientId, medicationId: null, date: today)));
                      },
                      onSnooze: () async {
                        await ref.read(medicationNotifierProvider(patientId).notifier).snooze(log.id);
                        ref.invalidate(medicationLogsProvider((patientId: patientId, medicationId: null, date: today)));
                      },
                    );
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
        ),
      ),
    );
  }
}

class _MedicationLogCard extends StatelessWidget {
  final MedicationLogDto log;
  final MedicationDto medication;
  final VoidCallback onTaken;
  final VoidCallback onSnooze;

  const _MedicationLogCard({
    required this.log,
    required this.medication,
    required this.onTaken,
    required this.onSnooze,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = log.isPending;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    medication.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(log.status).withAlpha(26),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusText(log.status),
                    style: TextStyle(
                      color: _getStatusColor(log.status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              medication.dosage,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 4),
            Text(
              'الموعد: ${log.scheduledAt.hour}:${log.scheduledAt.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
            if (log.snoozeCount > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'تم التأجيل ${log.snoozeCount} مرة',
                  style: const TextStyle(color: AppTheme.warningColor),
                ),
              ),
            if (isPending) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onTaken,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.secondaryColor,
                      ),
                      child: const Text('تم أخذها'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onSnooze,
                      child: const Text('تأجيل 15 دقيقة'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Taken':
        return AppTheme.secondaryColor;
      case 'Snoozed':
        return AppTheme.warningColor;
      case 'Missed':
        return AppTheme.errorColor;
      default:
        return AppTheme.primaryColor;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'Taken':
        return 'تم';
      case 'Snoozed':
        return 'مؤجل';
      case 'Missed':
        return 'فائت';
      default:
        return 'معلق';
    }
  }
}