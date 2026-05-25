import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../shared/theme/app_theme.dart';
import '../data/patient_models.dart';
import '../presentation/patient_providers.dart';

class PatientVitalsScreen extends ConsumerStatefulWidget {
  const PatientVitalsScreen({super.key});

  @override
  ConsumerState<PatientVitalsScreen> createState() => _PatientVitalsScreenState();
}

class _PatientVitalsScreenState extends ConsumerState<PatientVitalsScreen> {
  String _selectedType = 'HeartRate';
  final _valueController = TextEditingController();
  final _diastolicController = TextEditingController();
  bool _isLoading = false;

  final List<Map<String, dynamic>> _readingTypes = [
    {'type': 'HeartRate', 'label': 'نبض القلب', 'unit': 'نبضة/دقيقة', 'min': 30, 'max': 250},
    {'type': 'SystolicBP', 'label': 'الضغط الانقباضي', 'unit': 'mmHg', 'min': 50, 'max': 250},
    {'type': 'DiastolicBP', 'label': 'الضغط الانبساطي', 'unit': 'mmHg', 'min': 30, 'max': 150},
    {'type': 'Temperature', 'label': 'درجة الحرارة', 'unit': 'درجة مئوية', 'min': 34, 'max': 42},
    {'type': 'Glucose', 'label': 'معدل السكر', 'unit': 'mg/dL', 'min': 20, 'max': 600},
  ];

  @override
  void dispose() {
    _valueController.dispose();
    _diastolicController.dispose();
    super.dispose();
  }

  Future<void> _recordVital() async {
    final value = double.tryParse(_valueController.text);
    if (value == null) {
      _showError('الرجاء إدخال قيمة صحيحة');
      return;
    }

    final config = _readingTypes.firstWhere((r) => r['type'] == _selectedType);
    if (value < config['min'] || value > config['max']) {
      _showError('القيمة خارج النطاق المسموح');
      return;
    }

    setState(() => _isLoading = true);

    try {
      Position? position;
      try {
        final permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          await Geolocator.requestPermission();
        }
        position = await Geolocator.getCurrentPosition();
      } catch (_) {}

      final notifier = ref.read(vitalsNotifierProvider.notifier);

      await notifier.recordVital(RecordVitalCommand(
        readingType: _selectedType,
        value: value,
        unit: config['unit'] as String,
        latitude: position?.latitude,
        longitude: position?.longitude,
      ));

      // If systolic BP was recorded, also record diastolic as separate reading
      if (_selectedType == 'SystolicBP') {
        final diastolic = double.tryParse(_diastolicController.text);
        if (diastolic != null) {
          await notifier.recordVital(RecordVitalCommand(
            readingType: 'DiastolicBP',
            value: diastolic,
            unit: 'mmHg',
            latitude: position?.latitude,
            longitude: position?.longitude,
          ));
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ القياس بنجاح'),
            backgroundColor: AppTheme.secondaryColor,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.errorColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة قياس')),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'اختر نوع القياس',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _readingTypes.map((type) {
                  final isSelected = _selectedType == type['type'];
                  return ChoiceChip(
                    label: Text(type['label'] as String),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedType = type['type'] as String);
                    },
                    selectedColor: AppTheme.primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textPrimary,
                      fontFamily: 'Cairo',
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              Text(
                'أدخل القيمة',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _valueController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 32, fontFamily: 'Cairo'),
                decoration: InputDecoration(
                  hintText: _readingTypes.firstWhere((r) => r['type'] == _selectedType)['unit'] as String,
                ),
              ),
              if (_selectedType == 'SystolicBP') ...[
                const SizedBox(height: 16),
                const Text(
                  'الضغط الانبساطي (اختياري)',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _diastolicController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 32, fontFamily: 'Cairo'),
                  decoration: const InputDecoration(
                    hintText: 'الضغط الانبساطي',
                  ),
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _recordVital,
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('حفظ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}