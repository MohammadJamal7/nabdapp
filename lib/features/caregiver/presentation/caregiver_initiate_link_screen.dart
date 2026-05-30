import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/validators/app_validators.dart';

class CaregiverInitiateLinkScreen extends ConsumerStatefulWidget {
  const CaregiverInitiateLinkScreen({super.key});

  @override
  ConsumerState<CaregiverInitiateLinkScreen> createState() => _CaregiverInitiateLinkScreenState();
}

class _CaregiverInitiateLinkScreenState extends ConsumerState<CaregiverInitiateLinkScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _inviteCode;
  bool _isLoading = false;

  Future<void> _initiateLink() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final response = await ApiClient.post(
        ApiConstants.caregiversLinkInitiate,
        data: {
          'patientPhoneNumber': _phoneController.text.trim(),
          'escalationPriority': 1,
        },
      );
      setState(() => _inviteCode = response.data['code'] as String);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e'), backgroundColor: AppTheme.errorColor),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ربط مقدم رعاية')),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.link, size: 80, color: AppTheme.primaryColor),
                const SizedBox(height: 24),
                const Text(
                  'إنشاء رمز دعوة',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'أدخل رقم هاتف المريض لإنشاء رمز الدعوة',
                  style: TextStyle(color: AppTheme.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                if (_inviteCode != null) ...[
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withAlpha(26),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.primaryColor),
                    ),
                    child: Column(
                      children: [
                        const Text('رمز الدعوة:', style: TextStyle(color: AppTheme.textSecondary)),
                        const SizedBox(height: 12),
                        Text(
                          _inviteCode!,
                          style: const TextStyle(fontSize: 32, fontFamily: 'Cairo', letterSpacing: 8, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('شارك هذا الرمز مع المريض', textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('تم'),
                  ),
                ] else ...[
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      labelText: 'رقم هاتف المريض',
                      prefixIcon: Icon(Icons.phone),
                    ),
                    validator: AppValidators.phone,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _initiateLink,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('إنشاء رمز دعوة'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
