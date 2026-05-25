import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme/app_theme.dart';
import '../../patient/data/patient_models.dart';
import '../../patient/presentation/patient_providers.dart';

class CaregiverAlertsScreen extends ConsumerWidget {
  final String patientId;

  const CaregiverAlertsScreen({super.key, required this.patientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeAlertsAsync = ref.watch(alertsProvider((patientId: patientId, status: 'Active')));
    final allAlertsAsync = ref.watch(alertsProvider((patientId: patientId, status: null)));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('التنبيهات'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'النشطة'),
              Tab(text: 'السابقة'),
            ],
          ),
        ),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: TabBarView(
            children: [
              _buildAlertsList(activeAlertsAsync, ref, isActive: true),
              _buildAlertsList(allAlertsAsync, ref, isActive: false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlertsList(AsyncValue<List<EmergencyAlertDto>> alertsAsync, WidgetRef ref, {required bool isActive}) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(alertsProvider((patientId: patientId, status: isActive ? 'Active' : null)));
      },
      child: alertsAsync.when(
        data: (alerts) {
          if (alerts.isEmpty) {
            return Center(
              child: Text(
                isActive ? 'لا توجد تنبيهات نشطة' : 'لا توجد تنبيهات سابقة',
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final alert = alerts[index];
              return _AlertCard(
                alert: alert,
                onAcknowledge: isActive
                    ? () async {
                        await ref.read(alertsNotifierProvider.notifier).acknowledge(patientId, alert.id);
                        ref.invalidate(alertsProvider((patientId: patientId, status: 'Active')));
                        ref.invalidate(alertsProvider((patientId: patientId, status: null)));
                      }
                    : null,
                onCancel: isActive
                    ? () async {
                        await ref.read(alertsNotifierProvider.notifier).cancel(patientId, alert.id);
                        ref.invalidate(alertsProvider((patientId: patientId, status: 'Active')));
                        ref.invalidate(alertsProvider((patientId: patientId, status: null)));
                      }
                    : null,
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final EmergencyAlertDto alert;
  final VoidCallback? onAcknowledge;
  final VoidCallback? onCancel;

  const _AlertCard({
    required this.alert,
    this.onAcknowledge,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = alert.isActive;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isActive ? AppTheme.errorColor.withAlpha(13) : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _getIcon(),
                      color: isActive ? AppTheme.errorColor : AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getTypeLabel(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withAlpha(26),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusLabel(),
                    style: TextStyle(
                      color: _getStatusColor(),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'التاريخ: ${alert.createdAt.toString().substring(0, 16)}',
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
            if (alert.latitude != null && alert.longitude != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'الموقع: ${alert.latitude}, ${alert.longitude}',
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
              ),
            if (isActive) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onAcknowledge,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.secondaryColor,
                      ),
                      child: const Text('تأكيد'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onCancel,
                      child: const Text('إلغاء'),
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

  IconData _getIcon() {
    switch (alert.triggerType) {
      case 'ManualSos':
        return Icons.emergency;
      case 'VitalBreach':
        return Icons.warning;
      default:
        return Icons.notifications;
    }
  }

  String _getTypeLabel() {
    switch (alert.triggerType) {
      case 'ManualSos':
        return 'نداء طوارئ';
      case 'VitalBreach':
        return 'تجاوز القياس';
      default:
        return 'تنبيه';
    }
  }

  Color _getStatusColor() {
    switch (alert.status) {
      case 'Active':
        return AppTheme.errorColor;
      case 'Acknowledged':
        return AppTheme.secondaryColor;
      case 'Cancelled':
        return AppTheme.textSecondary;
      default:
        return AppTheme.primaryColor;
    }
  }

  String _getStatusLabel() {
    switch (alert.status) {
      case 'Active':
        return 'نشط';
      case 'Acknowledged':
        return 'تم التأكيد';
      case 'Cancelled':
        return 'ملغي';
      default:
        return alert.status;
    }
  }
}