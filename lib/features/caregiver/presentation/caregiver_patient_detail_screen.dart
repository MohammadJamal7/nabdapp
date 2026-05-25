import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme/app_theme.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../auth/data/models/auth_models.dart';
import '../../patient/data/patient_models.dart';
import '../../patient/presentation/patient_providers.dart';
import 'caregiver_medications_screen.dart';
import 'caregiver_thresholds_screen.dart';
import 'caregiver_alerts_screen.dart';
import 'caregiver_insights_screen.dart';
import '../../patient/presentation/patient_profile_screen.dart';

class CaregiverPatientDetailScreen extends ConsumerWidget {
  final String patientId;

  const CaregiverPatientDetailScreen({super.key, required this.patientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientAsync = ref.watch(patientsListProvider);
    final summaryAsync = ref.watch(vitalSummaryProvider(patientId));
    final alertsAsync = ref.watch(alertsProvider((patientId: patientId, status: 'Active')));

    return Scaffold(
      appBar: AppBar(
        title: patientAsync.when(
          data: (patients) {
            final patient = patients.firstWhere((p) => p.id == patientId, orElse: () => PatientSummaryDto(id: '', firstNameAr: 'مريض', lastNameAr: ''));
            return Text(patient.fullName);
          },
          loading: () => const Text('...'),
          error: (_, __) => const Text('مريض'),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(vitalSummaryProvider(patientId));
            ref.invalidate(alertsProvider((patientId: patientId, status: 'Active')));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildActiveAlerts(context, ref, alertsAsync),
                const SizedBox(height: 16),
                _buildVitalsSummary(context, ref, summaryAsync),
                const SizedBox(height: 16),
                _buildQuickActions(context),
                const SizedBox(height: 16),
                _buildInsightsCard(context, ref),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveAlerts(BuildContext context, WidgetRef ref, AsyncValue<List<EmergencyAlertDto>> alertsAsync) {
    return alertsAsync.when(
      data: (alerts) {
        if (alerts.isEmpty) return const SizedBox.shrink();
        return Card(
          color: AppTheme.errorColor.withAlpha(26),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.warning, color: AppTheme.errorColor),
                    const SizedBox(width: 8),
                    Text(
                      '${alerts.length} تنبيه نشط',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.errorColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...alerts.take(2).map((alert) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '${alert.triggerType} - ${alert.createdAt}',
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                )),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CaregiverAlertsScreen(patientId: patientId)),
                    );
                  },
                  child: const Text('عرض التنبيهات'),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildVitalsSummary(BuildContext context, WidgetRef ref, AsyncValue<List<VitalSignSummaryDto>> summaryAsync) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'القياسات الأخيرة',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            summaryAsync.when(
              data: (summary) {
                if (summary.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('لا توجد قياسات', style: TextStyle(color: AppTheme.textSecondary)),
                    ),
                  );
                }
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: summary.map((s) {
                    return Container(
                      width: 100,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withAlpha(26),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _getReadingTypeLabel(s.readingType),
                            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                          ),
                          Text(
                            s.average?.toStringAsFixed(0) ?? '-',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${s.sampleCount} قياس',
                            style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الإجراءات السريعة',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.medication,
                    label: 'الأدوية',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CaregiverMedicationsScreen(patientId: patientId)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.tune,
                    title: 'الحدود',
                    label: 'الحدود',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CaregiverThresholdsScreen(patientId: patientId)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.notifications_active,
                    label: 'التنبيهات',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CaregiverAlertsScreen(patientId: patientId)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.edit_note,
                    label: 'تعديل الملف',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => PatientProfileScreen(patientId: patientId)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.insights,
                    label: 'الرؤى',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CaregiverInsightsScreen(patientId: patientId)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsCard(BuildContext context, WidgetRef ref) {
    final insightsAsync = ref.watch(insightsProvider(patientId));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الرؤى الذكية',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CaregiverInsightsScreen(patientId: patientId)),
                    );
                  },
                  child: const Text('عرض الكل'),
                ),
              ],
            ),
            insightsAsync.when(
              data: (insights) {
                if (insights.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('لا توجد رؤى بعد', style: TextStyle(color: AppTheme.textSecondary)),
                  );
                }
                final latest = insights.first;
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: latest.urgencyFlag
                        ? AppTheme.warningColor.withAlpha(26)
                        : AppTheme.primaryColor.withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (latest.urgencyFlag)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Icon(Icons.warning, color: AppTheme.warningColor, size: 20),
                              SizedBox(width: 4),
                              Text('يحتاج اهتمام', style: TextStyle(color: AppTheme.warningColor)),
                            ],
                          ),
                        ),
                      Text(
                        latest.summary,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
            ),
          ],
        ),
      ),
    );
  }

  String _getReadingTypeLabel(String type) {
    switch (type) {
      case 'HeartRate':
        return 'نبض';
      case 'SystolicBP':
        return 'ضغط';
      case 'DiastolicBP':
        return 'ضغط انبساطي';
      case 'Temperature':
        return 'حرارة';
      case 'Glucose':
        return 'سكر';
      default:
        return type;
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    this.title = '',
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withAlpha(26),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 32),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}