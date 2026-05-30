import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme/app_theme.dart';
import '../../auth/data/models/auth_models.dart';
import '../../auth/presentation/auth_providers.dart';

class PatientProfileViewScreen extends ConsumerWidget {
  const PatientProfileViewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: profileAsync.when(
          data: (profile) => _ProfileContent(profile: profile),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text('خطأ: $e', style: const TextStyle(color: AppTheme.textSecondary)),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final UserDto profile;
  const _ProfileContent({required this.profile});

  @override
  Widget build(BuildContext context) {
    final initials = profile.fullName.isNotEmpty
        ? profile.fullName.split(' ').map((s) => s[0]).take(2).join()
        : 'م';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: AppTheme.primary.withAlpha(80), blurRadius: 20, offset: const Offset(0, 8))],
            ),
            child: Center(
              child: Text(initials, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 24),
          Text(profile.fullName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          if (profile.isActivated == true)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.success.withAlpha(20),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified, size: 14, color: AppTheme.success),
                  SizedBox(width: 4),
                  Text('حساب نشط', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.success)),
                ],
              ),
            ),
          const SizedBox(height: 32),
          if (profile.linkedCaregiverCount != null)
            _InfoChip(
              icon: Icons.people_rounded,
              label: 'مقدمو الرعاية',
              value: '${profile.linkedCaregiverCount}',
            ),
          const SizedBox(height: 24),
          // Info cards
          _InfoRow(label: 'تاريخ الميلاد', value: profile.dateOfBirth ?? '—'),
          _InfoRow(label: 'الجنس', value: profile.gender == 'Male' ? 'ذكر' : profile.gender == 'Female' ? 'أنثى' : '—'),
          _InfoRow(label: 'فصيلة الدم', value: profile.bloodType ?? '—'),
          if (profile.conditions != null && profile.conditions!.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text('الأمراض المزمنة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: profile.conditions!.map((c) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withAlpha(15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.primary.withAlpha(40)),
                ),
                child: Text(c, style: const TextStyle(fontSize: 14, color: AppTheme.primary, fontWeight: FontWeight.w500)),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 15, color: AppTheme.textSecondary)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoChip({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.accent.withAlpha(15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accent.withAlpha(40)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppTheme.accent),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
          const SizedBox(width: 8),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.accent)),
        ],
      ),
    );
  }
}
