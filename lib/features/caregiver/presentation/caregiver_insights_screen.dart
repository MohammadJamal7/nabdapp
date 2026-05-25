import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme/app_theme.dart';
import '../../patient/presentation/patient_providers.dart';

class CaregiverInsightsScreen extends ConsumerWidget {
  final String patientId;

  const CaregiverInsightsScreen({super.key, required this.patientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insightsAsync = ref.watch(insightsProvider(patientId));

    return Scaffold(
      appBar: AppBar(title: const Text('الرؤى الذكية')),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(insightsProvider(patientId));
          },
          child: insightsAsync.when(
            data: (insights) {
              if (insights.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.insights, size: 80, color: AppTheme.textSecondary),
                        SizedBox(height: 16),
                        Text(
                          'ستظهر الرؤى الذكية بعد بضعة أيام من النشاط',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: insights.length,
                itemBuilder: (context, index) {
                  final insight = insights[index];
                  return _InsightCard(insight: insight);
                },
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

class _InsightCard extends StatelessWidget {
  final dynamic insight;

  const _InsightCard({required this.insight});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  insight.urgencyFlag ? Icons.warning : Icons.insights,
                  color: insight.urgencyFlag ? AppTheme.warningColor : AppTheme.primaryColor,
                ),
                const SizedBox(width: 8),
                if (insight.urgencyFlag)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.warningColor.withAlpha(26),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'يحتاج اهتمام',
                      style: TextStyle(
                        color: AppTheme.warningColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              insight.summary,
              style: const TextStyle(fontSize: 16, height: 1.6),
            ),
            if (insight.recommendations.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'التوصيات:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...insight.recommendations.map<Widget>((rec) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(child: Text(rec)),
                  ],
                ),
              )),
            ],
            const SizedBox(height: 12),
            Text(
              'تاريخ التوليد: ${insight.generatedAt}',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}