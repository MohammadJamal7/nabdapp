import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/validators/app_validators.dart';
import '../../patient/data/patient_models.dart';
import '../../patient/presentation/patient_providers.dart';

class CaregiverMedicationsScreen extends ConsumerWidget {
  final String patientId;

  const CaregiverMedicationsScreen({super.key, required this.patientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medsAsync = ref.watch(medicationsProvider(patientId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('الأدوية'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddMedicationDialog(context, ref),
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(medicationsProvider(patientId));
          },
          child: medsAsync.when(
            data: (meds) {
              if (meds.isEmpty) {
                return const Center(
                  child: Text('لا توجد أدوية', style: TextStyle(color: AppTheme.textSecondary)),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: meds.length,
                itemBuilder: (context, index) {
                  final med = meds[index];
                  return _MedicationCard(
                    medication: med,
                    onEdit: () => _showEditMedicationDialog(context, ref, med),
                    onDelete: () => _confirmDelete(context, ref, med),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMedicationDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddMedicationDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _MedicationFormSheet(
        patientId: patientId,
        onSave: () {
          Navigator.pop(context);
          ref.invalidate(medicationsProvider(patientId));
        },
      ),
    );
  }

  void _showEditMedicationDialog(BuildContext context, WidgetRef ref, MedicationDto med) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _MedicationFormSheet(
        patientId: patientId,
        medication: med,
        onSave: () {
          Navigator.pop(context);
          ref.invalidate(medicationsProvider(patientId));
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, MedicationDto med) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف药业'),
        content: Text('هل أنت متأكد من حذف ${med.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(medicationNotifierProvider(patientId).notifier).deleteMedication(med.id);
              ref.invalidate(medicationsProvider(patientId));
            },
            child: const Text('حذف', style: TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );
  }
}

class _MedicationCard extends StatelessWidget {
  final MedicationDto medication;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MedicationCard({
    required this.medication,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
                Expanded(
                  child: Text(
                    medication.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('تعديل')),
                    const PopupMenuItem(value: 'delete', child: Text('حذف')),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') onEdit();
                    if (value == 'delete') onDelete();
                  },
                ),
              ],
            ),
            Text(medication.dosage, style: const TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 8),
            Text(
              'التكرار: ${_getFrequencyLabel(medication.frequencyType)}',
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 4),
            Text(
              'الأوقات: ${medication.scheduledTimes.join(', ')}',
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
            if (medication.instructions != null) ...[
              const SizedBox(height: 8),
              Text(
                'التعليمات: ${medication.instructions}',
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getFrequencyLabel(String type) {
    switch (type) {
      case 'Daily':
        return 'يومي';
      case 'TwiceDaily':
        return 'مرتين يومياً';
      case 'ThreeTimesDaily':
        return 'ثلاث مرات يومياً';
      case 'Weekly':
        return 'أسبوعياً';
      case 'AsNeeded':
        return 'عند الحاجة';
      default:
        return type;
    }
  }
}

class _MedicationFormSheet extends ConsumerStatefulWidget {
  final String patientId;
  final MedicationDto? medication;
  final VoidCallback onSave;

  const _MedicationFormSheet({
    required this.patientId,
    this.medication,
    required this.onSave,
  });

  @override
  ConsumerState<_MedicationFormSheet> createState() => _MedicationFormSheetState();
}

class _MedicationFormSheetState extends ConsumerState<_MedicationFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _dosageAmountController;
  late TextEditingController _dosageUnitController;
  late TextEditingController _instructionsController;
  String _frequencyType = 'Daily';
  List<String> _scheduledTimes = ['08:00:00'];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final med = widget.medication;
    _nameController = TextEditingController(text: med?.name ?? '');
    _dosageAmountController = TextEditingController(text: med?.dosageAmount ?? '');
    _dosageUnitController = TextEditingController(text: med?.dosageUnit ?? 'mg');
    _instructionsController = TextEditingController(text: med?.instructions ?? '');
    _frequencyType = med?.frequencyType ?? 'Daily';
    _scheduledTimes = med?.scheduledTimes ?? ['08:00:00'];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageAmountController.dispose();
    _dosageUnitController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.medication == null ? 'إضافة دواء' : 'تعديل دواء',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'اسم الدواء'),
                  validator: AppValidators.medicationName,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _dosageAmountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'الجرعة'),
                        validator: AppValidators.dosageAmount,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _dosageUnitController,
                        decoration: const InputDecoration(labelText: 'الوحدة'),
                        validator: (v) => v?.trim().isEmpty == true ? 'الوحدة مطلوبة' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _frequencyType,
                  decoration: const InputDecoration(labelText: 'التكرار'),
                  items: const [
                    DropdownMenuItem(value: 'Daily', child: Text('يومي')),
                    DropdownMenuItem(value: 'TwiceDaily', child: Text('مرتين يومياً')),
                    DropdownMenuItem(value: 'ThreeTimesDaily', child: Text('ثلاث مرات يومياً')),
                    DropdownMenuItem(value: 'Weekly', child: Text('أسبوعياً')),
                    DropdownMenuItem(value: 'AsNeeded', child: Text('عند الحاجة')),
                  ],
                  onChanged: (v) {
                    setState(() {
                      _frequencyType = v!;
                      _syncTimesWithFrequency();
                    });
                  },
                ),
                if (_frequencyType != 'AsNeeded') ...[
                  const SizedBox(height: 16),
                  const Text('أوقات تناول الدواء', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ..._scheduledTimes.asMap().entries.map((entry) {
                    final i = entry.key;
                    final time = entry.value;
                    final timeDisplay = time.length >= 8 ? '${time.substring(0, 2)}:${time.substring(3, 5)}' : time;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () => _pickTime(i),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'الوقت ${i + 1}',
                            prefixIcon: const Icon(Icons.access_time),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: _scheduledTimes.length > 1 ? () => _removeTime(i) : null,
                            ),
                          ),
                          child: Text(timeDisplay, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontFamily: 'Cairo')),
                        ),
                      ),
                    );
                  }),
                  if (_scheduledTimes.length < _maxTimes) ...[
                    const SizedBox(height: 4),
                    TextButton.icon(
                      onPressed: _addTime,
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text('إضافة وقت'),
                    ),
                  ],
                ],
                const SizedBox(height: 16),
                TextFormField(
                  controller: _instructionsController,
                  decoration: const InputDecoration(labelText: 'التعليمات (اختياري)'),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('حفظ'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int get _maxTimes {
    switch (_frequencyType) {
      case 'TwiceDaily': return 2;
      case 'ThreeTimesDaily': return 3;
      default: return 1;
    }
  }

  void _syncTimesWithFrequency() {
    final max = _maxTimes;
    while (_scheduledTimes.length > max) _scheduledTimes.removeLast();
    while (_scheduledTimes.length < max) _scheduledTimes.add('08:00:00');
  }

  Future<void> _pickTime(int index) async {
    final parts = _scheduledTimes[index].split(':');
    final initial = TimeOfDay(hour: int.tryParse(parts[0]) ?? 8, minute: int.tryParse(parts[1]) ?? 0);
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      setState(() {
        _scheduledTimes[index] = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}:00';
      });
    }
  }

  void _addTime() {
    if (_scheduledTimes.length < _maxTimes) {
      setState(() => _scheduledTimes.add('08:00:00'));
    }
  }

  void _removeTime(int index) {
    if (_scheduledTimes.length > 1) {
      setState(() => _scheduledTimes.removeAt(index));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final command = CreateMedicationCommand(
        name: _nameController.text.trim(),
        dosageAmount: _dosageAmountController.text.trim(),
        dosageUnit: _dosageUnitController.text.trim(),
        frequencyType: _frequencyType,
        scheduledTimes: _scheduledTimes,
        startDate: DateTime.now().toIso8601String().split('T')[0],
        instructions: _instructionsController.text.trim().isNotEmpty
            ? _instructionsController.text.trim()
            : null,
      );

      if (widget.medication == null) {
        await ref.read(medicationNotifierProvider(widget.patientId).notifier).createMedication(command);
      } else {
        await ref.read(medicationNotifierProvider(widget.patientId).notifier).updateMedication(
          widget.medication!.id,
          command,
        );
      }

      widget.onSave();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.errorColor),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}