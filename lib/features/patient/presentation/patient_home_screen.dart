import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/premium_sos_button.dart';
import '../../../shared/widgets/vitals_premium_card.dart';
import '../../auth/presentation/auth_providers.dart';
import '../data/patient_models.dart';
import '../presentation/patient_providers.dart';
import '../../auth/presentation/auth_providers.dart' show UserRole;
import 'patient_medications_screen.dart';
import 'patient_vitals_screen.dart';
import 'patient_articles_screen.dart';
import 'patient_profile_view_screen.dart';
import 'sos_screen.dart';

class PatientHomeScreen extends ConsumerWidget {
  const PatientHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    
    // Guard: If caregiver, show error/redirect
    if (authState.role == UserRole.caregiver) {
      return Scaffold(
        appBar: AppBar(title: const Text('خطأ')),
        body: const Center(
          child: Text(
            'يجب تسجيل الخروج وإعادة تسجيل الدخول\n(تحديث التطبيق مطلوب)',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }
    
    final patientId = authState.patientId ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('نبض'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PatientProfileViewScreen()));
                  break;
                case 'logout':
                  ref.read(authStateProvider.notifier).logout();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'profile', child: Row(children: [Icon(Icons.person), SizedBox(width: 8), Text('الملف الشخصي')])),
              const PopupMenuItem(value: 'logout', child: Row(children: [Icon(Icons.logout), SizedBox(width: 8), Text('تسجيل الخروج')])),
            ],
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(medicationsProvider(patientId));
            ref.invalidate(medicationLogsProvider((patientId: patientId, medicationId: null, date: null)));
            ref.invalidate(vitalSummaryProvider(patientId));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildPremiumSosButton(context),
                const SizedBox(height: 28),
                _buildTodayMedications(context, ref, patientId),
                const SizedBox(height: 20),
                _buildLatestVitals(context, ref, patientId),
                const SizedBox(height: 20),
                _buildArticlesCard(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumSosButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Center(
            child: PremiumSosButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SosScreen())),
              size: 110,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'اضغط في حالات الطوارئ',
            style: TextStyle(fontSize: 14, color: AppTheme.textMuted, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayMedications(BuildContext context, WidgetRef ref, String patientId) {
    final logsAsync = ref.watch(medicationLogsProvider((patientId: patientId, medicationId: null, date: DateTime.now().toIso8601String().split('T')[0])));
    final medsAsync = ref.watch(medicationsProvider(patientId));

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
                  'أدوية اليوم',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PatientMedicationsScreen()),
                    );
                  },
                  child: const Text('عرض الكل'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            medsAsync.when(
              data: (meds) {
                if (meds.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('لا توجد أدوية', style: TextStyle(color: AppTheme.textSecondary)),
                    ),
                  );
                }
                return logsAsync.when(
                  data: (logs) {
                    final pendingLogs = logs.where((l) => l.isPending).toList();
                    if (pendingLogs.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('تم أخذ所有的药', style: TextStyle(color: AppTheme.secondaryColor, fontWeight: FontWeight.bold)),
                        ),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: pendingLogs.length > 3 ? 3 : pendingLogs.length,
                      itemBuilder: (context, index) {
                        final log = pendingLogs[index];
                        final med = meds.firstWhere((m) => m.id == log.medicationId, orElse: () => MedicationDto(id: '', name: 'غير معروف', dosageAmount: '', dosageUnit: '', frequencyType: '', scheduledTimes: []));
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            log.isPending ? Icons.access_time : (log.isTaken ? Icons.check_circle : Icons.remove_circle),
                            color: log.isPending ? AppTheme.warningColor : (log.isTaken ? AppTheme.secondaryColor : AppTheme.errorColor),
                          ),
                          title: Text(med.name),
                          subtitle: Text(med.dosage),
                          trailing: Text(
                            '${log.scheduledAt.hour}:${log.scheduledAt.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(color: AppTheme.textSecondary),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Error: $e'),
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

  Widget _buildLatestVitals(BuildContext context, WidgetRef ref, String patientId) {
    final summaryAsync = ref.watch(vitalSummaryProvider(patientId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('آخر القياسات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PatientVitalsScreen())),
              child: const Text('إضافة'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        summaryAsync.when(
          data: (summary) {
            if (summary.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: const Center(child: Text('لا توجد قياسات', style: TextStyle(color: AppTheme.textSecondary))),
              );
            }
            return GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: summary.take(4).map((s) {
                final config = _vitalConfig(s.readingType);
                return VitalsPremiumCard(
                  label: config.label,
                  value: s.average?.toStringAsFixed(0) ?? '-',
                  unit: config.unit,
                  icon: config.icon,
                  color: config.color,
                  isWarning: s.max != null && s.max! > config.warningThreshold,
                  minSpark: s.min,
                );
              }).toList(),
            );
          },
          loading: () => Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppTheme.cardShadow,
            ),
            child: const Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Text('خطأ: $e', style: const TextStyle(color: AppTheme.textSecondary)),
          ),
        ),
      ],
    );
  }

  _VitalConfig _vitalConfig(String type) {
    switch (type) {
      case 'HeartRate':
        return _VitalConfig('النبض', 'bpm', Icons.favorite_rounded, AppTheme.danger, 100);
      case 'SystolicBP':
        return _VitalConfig('الضغط', 'mmHg', Icons.monitor_heart_rounded, AppTheme.primary, 140);
      case 'DiastolicBP':
        return _VitalConfig('الضغط السفلي', 'mmHg', Icons.monitor_heart_outlined, AppTheme.accent, 90);
      case 'Temperature':
        return _VitalConfig('الحرارة', '°C', Icons.thermostat_rounded, AppTheme.warning, 38);
      case 'Glucose':
        return _VitalConfig('السكر', 'mg/dL', Icons.bloodtype_rounded, AppTheme.success, 180);
      default:
        return _VitalConfig(type, '', Icons.circle, AppTheme.primary, 999);
    }
  }

  Widget _buildArticlesCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'نصائح صحية',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.article, color: AppTheme.primaryColor),
              title: const Text('مقالات صحية'),
              subtitle: const Text('نصائح للعناية بصحتك'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PatientArticlesScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

}

class _VitalConfig {
  final String label;
  final String unit;
  final IconData icon;
  final Color color;
  final double warningThreshold;

  _VitalConfig(this.label, this.unit, this.icon, this.color, this.warningThreshold);
}