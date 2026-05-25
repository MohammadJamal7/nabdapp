import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme/app_theme.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../auth/data/models/auth_models.dart';
import 'caregiver_create_patient_screen.dart';
import 'caregiver_patient_detail_screen.dart';

class CaregiverHomeScreen extends ConsumerWidget {
  const CaregiverHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientsAsync = ref.watch(patientsListProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('نبض'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'logout':
                    ref.read(authStateProvider.notifier).logout();
                    break;
                }
              },
              offset: const Offset(-8, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: Colors.white,
              elevation: 8,
              surfaceTintColor: Colors.white,
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(children: [
                    Icon(Icons.logout_rounded, size: 20, color: AppTheme.textSecondary),
                    SizedBox(width: 12),
                    Text('تسجيل الخروج', style: TextStyle(fontSize: 15, color: AppTheme.textPrimary)),
                  ]),
                ),
              ],
              child: const GradientAvatar(initials: 'م', size: 40),
            ),
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(patientsListProvider),
          child: patientsAsync.when(
            data: (patients) => patients.isEmpty
                ? _EmptyState()
                : _PatientList(patients: patients),
            loading: () => const _LoadingSkeleton(),
            error: (e, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text('حدث خطأ: $e', style: const TextStyle(color: AppTheme.textSecondary)),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: GradientFab(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreatePatientScreen())),
        icon: Icons.person_add_rounded,
        label: 'إضافة مريض',
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}';
    return name.isNotEmpty ? name[0] : 'م';
  }
}

// ─── Empty State ─────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: AppTheme.elevatedShadow,
              ),
              child: const Icon(Icons.favorite_rounded, size: 56, color: Colors.white),
            ),
            const SizedBox(height: 32),
            const Text('مرحباً بك في نبض', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            const SizedBox(height: 12),
            const Text(
              'أضف مريضاً لبدء متابعة حالته الصحية\nوتلقي التنبيهات والتقارير',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: AppTheme.textSecondary, height: 1.6),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: 220,
              child: GradientButton(
                icon: Icons.person_add_rounded,
                label: 'إضافة مريض',
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreatePatientScreen())),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Loading Skeleton ─────────────────────────────────────
class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 100, 20, 100),
      itemCount: 3,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: ShimmerCard(),
      ),
    );
  }
}

class ShimmerCard extends StatefulWidget {
  @override
  State<ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<ShimmerCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final dx = 1.0 - (_controller.value * 2 - 1).abs();
        return Container(
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: CircleAvatar(radius: 30, backgroundColor: Colors.grey.withAlpha(30 + (dx * 40).toInt())),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(2, (i) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  width: 120 + dx * 60,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.grey.withAlpha(30 + (dx * 40).toInt()),
                    borderRadius: BorderRadius.circular(7),
                  ),
                )),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Patient List ─────────────────────────────────────────
class _PatientList extends StatelessWidget {
  final List<PatientSummaryDto> patients;
  const _PatientList({required this.patients});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 100, 24, 8),
            child: Row(
              children: [
                const Text('المريض', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('${patients.length} مرضى',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primary)),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _PatientCard(
                patient: patients[index],
                index: index,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CaregiverPatientDetailScreen(patientId: patients[index].id))),
              ),
              childCount: patients.length,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Patient Card (Premium) ───────────────────────────────
class _PatientCard extends StatelessWidget {
  final PatientSummaryDto patient;
  final int index;
  final VoidCallback onTap;

  const _PatientCard({required this.patient, required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isActive = patient.isActivated == true;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppTheme.cardShadow,
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Gradient accent bar
                Container(
                  width: 6,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isActive
                          ? [AppTheme.primary, AppTheme.primaryLight]
                          : [AppTheme.textMuted, AppTheme.border],
                    ),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
                    child: Row(
                      children: [
                        GradientAvatar(
                          initials: _initials(patient.fullName),
                          size: 52,
                          gradientIndex: index,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                patient.fullName,
                                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  StatusDot(isActive: isActive),
                                  const SizedBox(width: 6),
                                  Text(
                                    isActive ? 'نشط' : 'غير مفعل',
                                    style: TextStyle(
                                      fontSize: 13, fontWeight: FontWeight.w500,
                                      color: isActive ? AppTheme.success : AppTheme.textMuted,
                                    ),
                                  ),
                                  if (patient.dateOfBirth != null) ...[
                                    const SizedBox(width: 12),
                                    Text(
                                      patient.dateOfBirth!,
                                      style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.chevron_left_rounded, color: AppTheme.textMuted, size: 20),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}';
    return name.isNotEmpty ? name[0] : 'م';
  }
}

// ─── Reusable Components ──────────────────────────────────

class GradientAvatar extends StatelessWidget {
  final String initials;
  final double size;
  final int gradientIndex;

  const GradientAvatar({
    super.key,
    required this.initials,
    this.size = 52,
    this.gradientIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.avatarGradient(gradientIndex);
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: colors[0].withAlpha(60), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(fontSize: size * 0.38, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}

class StatusDot extends StatelessWidget {
  final bool isActive;
  const StatusDot({super.key, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8, height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppTheme.success : AppTheme.textMuted,
        shape: BoxShape.circle,
        boxShadow: isActive
            ? [BoxShadow(color: AppTheme.success.withAlpha(100), blurRadius: 6, spreadRadius: 1)]
            : null,
      ),
    );
  }
}

class GradientButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const GradientButton({super.key, required this.label, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: AppTheme.primary.withAlpha(80), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        ),
      ),
    );
  }
}

class GradientFab extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  const GradientFab({super.key, required this.onPressed, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: AppTheme.primaryGradient,
        boxShadow: [
          BoxShadow(color: AppTheme.primary.withAlpha(100), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(label),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
    );
  }
}
