import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/validators/app_validators.dart';
import '../presentation/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    
    final phone = _phoneController.text.trim();
    await ref.read(authStateProvider.notifier).login(phone);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: AppTheme.errorColor),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  Image.asset(
                    'assets/icon/logo.png',
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'رعايتكم في أيدي أمينة',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 60),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, fontFamily: 'Cairo'),
                    decoration: const InputDecoration(
                      hintText: 'رقم الهاتف',
                      prefixIcon: Icon(Icons.phone),
                    ),
                    validator: AppValidators.phone,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: authState.isLoading ? null : _login,
                    child: authState.isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('تسجيل الدخول'),
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterCaregiverScreen(),
                        ),
                      );
                    },
                    child: const Text('تسجيل كمقدم رعاية'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ActivatePatientScreen(),
                        ),
                      );
                    },
                    child: const Text('تفعيل حساب مريض'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterCaregiverScreen extends ConsumerStatefulWidget {
  const RegisterCaregiverScreen({super.key});

  @override
  ConsumerState<RegisterCaregiverScreen> createState() => _RegisterCaregiverScreenState();
}

class _RegisterCaregiverScreenState extends ConsumerState<RegisterCaregiverScreen> {
  final _phoneController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    
    await ref.read(authStateProvider.notifier).registerCaregiver(
      _phoneController.text.trim(),
      _firstNameController.text.trim(),
      _lastNameController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: AppTheme.errorColor),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل مقدم رعاية')),
      body: SafeArea(
        child: Directionality(
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
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: authState.isLoading ? null : _register,
                    child: authState.isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('تسجيل'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ActivatePatientScreen extends ConsumerStatefulWidget {
  const ActivatePatientScreen({super.key});

  @override
  ConsumerState<ActivatePatientScreen> createState() => _ActivatePatientScreenState();
}

class _ActivatePatientScreenState extends ConsumerState<ActivatePatientScreen> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _activate() async {
    if (!_formKey.currentState!.validate()) return;
    
    await ref.read(authStateProvider.notifier).activatePatient(
      _codeController.text.trim(),
      _phoneController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: AppTheme.errorColor),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('تفعيل حساب المريض')),
      body: SafeArea(
        child: Directionality(
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
                      labelText: 'رقم هاتف المريض',
                      prefixIcon: Icon(Icons.phone),
                    ),
                    validator: AppValidators.phone,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _codeController,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, fontFamily: 'Cairo', letterSpacing: 8),
                    decoration: const InputDecoration(
                      labelText: 'رمز التفعيل',
                      hintText: 'XXXXXXXX',
                    ),
                    validator: AppValidators.activationCode,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: authState.isLoading ? null : _activate,
                    child: authState.isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('تفعيل'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}