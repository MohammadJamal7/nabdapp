import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../shared/theme/app_theme.dart';

class PatientApproveLinkScreen extends ConsumerStatefulWidget {
  const PatientApproveLinkScreen({super.key});

  @override
  ConsumerState<PatientApproveLinkScreen> createState() => _PatientApproveLinkScreenState();
}

class _PatientApproveLinkScreenState extends ConsumerState<PatientApproveLinkScreen> {
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _approveLink() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await ApiClient.post(
        ApiConstants.caregiversLinkApprove,
        data: {'code': _codeController.text.trim()},
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم ربط مقدم الرعاية بنجاح'), backgroundColor: AppTheme.secondaryColor),
        );
        Navigator.pop(context);
      }
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
    _codeController.dispose();
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
                const Icon(Icons.person_add, size: 80, color: AppTheme.primaryColor),
                const SizedBox(height: 24),
                const Text(
                  'أدخل رمز الدعوة',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'أدخل رمز الدعوة الذي حصلت عليه من مقدم الرعاية',
                  style: TextStyle(color: AppTheme.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _codeController,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, fontFamily: 'Cairo', letterSpacing: 8),
                  decoration: const InputDecoration(labelText: 'رمز الدعوة', hintText: 'XXXXXX'),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'الرجاء إدخال رمز الدعوة';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _approveLink,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('تأكيد'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
