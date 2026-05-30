import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/validators/app_validators.dart';
import '../../patient/data/patient_models.dart';
import '../../patient/presentation/patient_providers.dart';

class CaregiverThresholdsScreen extends ConsumerStatefulWidget {
  final String patientId;

  const CaregiverThresholdsScreen({super.key, required this.patientId});

  @override
  ConsumerState<CaregiverThresholdsScreen> createState() => _CaregiverThresholdsScreenState();
}

class _CaregiverThresholdsScreenState extends ConsumerState<CaregiverThresholdsScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _minControllers = {};
  final Map<String, TextEditingController> _maxControllers = {};
  bool _isLoading = false;

  final List<Map<String, dynamic>> _defaultThresholds = [
    {'type': 'HeartRate', 'label': 'نبض القلب', 'min': 60.0, 'max': 100.0, 'unit': 'نبضة/دقيقة'},
    {'type': 'SystolicBP', 'label': 'الضغط الانقباضي', 'min': 90.0, 'max': 140.0, 'unit': 'mmHg'},
    {'type': 'DiastolicBP', 'label': 'الضغط الانبساطي', 'min': 60.0, 'max': 90.0, 'unit': 'mmHg'},
    {'type': 'Temperature', 'label': 'درجة الحرارة', 'min': null, 'max': 38.0, 'unit': 'درجة مئوية'},
    {'type': 'Glucose', 'label': 'معدل السكر', 'min': 70.0, 'max': 180.0, 'unit': 'mg/dL'},
  ];

  @override
  void initState() {
    super.initState();
    for (var t in _defaultThresholds) {
      _minControllers[t['type'] as String] = TextEditingController();
      _maxControllers[t['type'] as String] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (var c in _minControllers.values) c.dispose();
    for (var c in _maxControllers.values) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final thresholdsAsync = ref.watch(thresholdsProvider(widget.patientId));

    return Scaffold(
      appBar: AppBar(title: const Text('حدود القياسات')),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: thresholdsAsync.when(
          data: (thresholds) {
            _initControllers(thresholds);
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'القيم الافتراضية',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'هذه هي القيم الافتراضية للمراقبة. يمكن تخصيصها لكل مريض.',
                              style: TextStyle(color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._defaultThresholds.map((threshold) {
                      final type = threshold['type'] as String;
                      final minVal = _minControllers[type]?.text.isNotEmpty == true
                          ? double.tryParse(_minControllers[type]!.text)
                          : threshold['min'];
                      final maxVal = _maxControllers[type]?.text.isNotEmpty == true
                          ? double.tryParse(_maxControllers[type]!.text)
                          : threshold['max'];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    threshold['label'] as String,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    threshold['unit'] as String,
                                    style: const TextStyle(color: AppTheme.textSecondary),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _minControllers[type],
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: 'الحد الأدنى',
                                        hintText: threshold['min']?.toString() ?? '-',
                                      ),
                                      validator: (v) => AppValidators.thresholdValue(v),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _maxControllers[type],
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: 'الحد الأعلى',
                                        hintText: threshold['max']?.toString() ?? '-',
                                      ),
                                      validator: (v) => AppValidators.thresholdValue(v),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveThresholds,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('حفظ الحدود'),
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }

  void _initControllers(List<VitalSignThresholdDto> thresholds) {
    for (var t in thresholds) {
      if (_minControllers.containsKey(t.readingType)) {
        if (t.minValue != null && _minControllers[t.readingType]?.text.isEmpty == true) {
          _minControllers[t.readingType]?.text = t.minValue.toString();
        }
        if (t.maxValue != null && _maxControllers[t.readingType]?.text.isEmpty == true) {
          _maxControllers[t.readingType]?.text = t.maxValue.toString();
        }
      }
    }
  }

  Future<void> _saveThresholds() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final thresholds = _defaultThresholds.map((t) {
        final type = t['type'] as String;
        final minText = _minControllers[type]?.text.trim();
        final maxText = _maxControllers[type]?.text.trim();

        return SetThresholdItemDto(
          readingType: type,
          minValue: minText?.isNotEmpty == true ? double.tryParse(minText!) : null,
          maxValue: maxText?.isNotEmpty == true ? double.tryParse(maxText!) : null,
        );
      }).toList();

      final apiService = ref.read(patientApiServiceProvider);
      await apiService.setThresholds(widget.patientId, thresholds);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ الحدود بنجاح'),
            backgroundColor: AppTheme.secondaryColor,
          ),
        );
        ref.invalidate(thresholdsProvider(widget.patientId));
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
}