import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/validators/app_validators.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../auth/data/models/auth_models.dart';

class CreatePatientScreen extends ConsumerStatefulWidget {
  const CreatePatientScreen({super.key});

  @override
  ConsumerState<CreatePatientScreen> createState() => _CreatePatientScreenState();
}

class _CreatePatientScreenState extends ConsumerState<CreatePatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  String _gender = 'Male';
  DateTime _dateOfBirth = DateTime(1950);
  String? _bloodType;
  final List<String> _conditions = [];
  bool _isLoading = false;

  final List<String> _bloodTypes = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];
  final List<String> _availableConditions = ['السكري', 'ضغط الدم', 'أمراض القلب', 'الربو', 'التهاب المفاصل'];

  @override
  void dispose() {
    _phoneController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _createPatient() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final request = CreatePatientRequest(
        phoneNumber: _phoneController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        dateOfBirth: _dateOfBirth.toIso8601String().split('T')[0],
        gender: _gender,
        bloodType: _bloodType,
        conditions: _conditions.isNotEmpty ? _conditions : null,
      );

      final response = await ref.read(authStateProvider.notifier).createPatient(request);

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('تم إنشاء المريض'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('رمز التفعيل:'),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    response.activationCode,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 8,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'أعطِ هذا الرمز للمريض لتفعيل حسابه',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ],
            ),
            actions: [
              TextButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: response.activationCode));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم نسخ الرمز'), duration: Duration(seconds: 2)),
                  );
                },
                icon: const Icon(Icons.copy),
                label: const Text('نسخ'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('حسناً'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.errorColor),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة مريض')),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'رقم الهاتف',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  validator: AppValidators.phone,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'الاسم الأول',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: AppValidators.firstName,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'الاسم الأخير',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: AppValidators.lastName,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _gender,
                  decoration: const InputDecoration(
                    labelText: 'الجنس',
                    prefixIcon: Icon(Icons.wc),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Male', child: Text('ذكر')),
                    DropdownMenuItem(value: 'Female', child: Text('أنثى')),
                  ],
                  onChanged: (value) => setState(() => _gender = value!),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _dateOfBirth,
                      firstDate: DateTime(1940),
                      lastDate: DateTime(2010),
                    );
                    if (date != null) setState(() => _dateOfBirth = date);
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'تاريخ الميلاد',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(_dateOfBirth.toIso8601String().split('T')[0]),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String?>(
                  value: _bloodType,
                  decoration: const InputDecoration(
                    labelText: 'فصيلة الدم',
                    prefixIcon: Icon(Icons.bloodtype),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('اختر')),
                    ..._bloodTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))),
                  ],
                  onChanged: (value) => setState(() => _bloodType = value),
                ),
                const SizedBox(height: 24),
                const Text(
                  'الأمراض المزمنة',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableConditions.map((condition) {
                    final isSelected = _conditions.contains(condition);
                    return FilterChip(
                      label: Text(condition),
                      selected: isSelected,
                      selectedColor: AppTheme.primaryColor.withAlpha(51),
                      checkmarkColor: AppTheme.primaryColor,
                      backgroundColor: AppTheme.surface,
                      side: BorderSide(
                        color: isSelected ? AppTheme.primaryColor : AppTheme.border,
                      ),
                      labelStyle: TextStyle(
                        color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _conditions.add(condition);
                          } else {
                            _conditions.remove(condition);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _createPatient,
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('إنشاء'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}