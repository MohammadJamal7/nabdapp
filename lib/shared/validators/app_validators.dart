class AppValidators {
  AppValidators._();

  /// Jordanian phone: 0791234567, +962791234567, 00962791234567, 791234567
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'رقم الهاتف مطلوب';
    final cleaned = value.trim().replaceAll(' ', '').replaceAll('-', '');
    final phoneRegex = RegExp(r'^(?:\+962|00962|0)?7[0-9]{8}$');
    if (!phoneRegex.hasMatch(cleaned)) return 'رقم هاتف غير صالح (مثال: 0791234567)';
    return null;
  }

  /// Arabic or English name, 2-100 chars
  static String? name(String? value, String field) {
    if (value == null || value.trim().isEmpty) return '$field مطلوب';
    if (value.trim().length < 2) return '$field يجب أن يكون حرفين على الأقل';
    if (value.trim().length > 100) return '$field طويل جداً';
    return null;
  }

  static String? firstName(String? value) => name(value, 'الاسم الأول');
  static String? lastName(String? value) => name(value, 'الاسم الأخير');

  /// Activation code: 6 alphanumeric chars
  static String? activationCode(String? value) {
    if (value == null || value.trim().isEmpty) return 'رمز التفعيل مطلوب';
    if (value.trim().length != 6) return 'رمز التفعيل يجب أن يكون 6 أحرف';
    return null;
  }

  /// Invite code: 6 alphanumeric chars
  static String? inviteCode(String? value) {
    if (value == null || value.trim().isEmpty) return 'رمز الدعوة مطلوب';
    if (value.trim().length != 6) return 'رمز الدعوة يجب أن يكون 6 أحرف';
    return null;
  }

  /// Date of birth: must be in the past, age between 0-120
  static String? dateOfBirth(String? value) {
    if (value == null || value.trim().isEmpty) return 'تاريخ الميلاد مطلوب';
    try {
      final date = DateTime.parse(value);
      final now = DateTime.now();
      if (date.isAfter(now)) return 'تاريخ الميلاد لا يمكن أن يكون في المستقبل';
      final age = now.year - date.year;
      if (age > 120) return 'الرجاء التحقق من تاريخ الميلاد';
      if (age < 0) return 'تاريخ ميلاد غير صالح';
    } catch (_) {
      return 'صيغة تاريخ غير صالحة (YYYY-MM-DD)';
    }
    return null;
  }

  /// Vital sign value within physiological range
  static String? vitalValue(String? type, double? value) {
    if (value == null) return 'القيمة مطلوبة';

    switch (type) {
      case 'HeartRate':
        if (value < 30 || value > 250) return 'معدل النبض يجب أن يكون بين 30 و 250';
        break;
      case 'SystolicBP':
        if (value < 50 || value > 250) return 'الضغط الانقباضي يجب أن يكون بين 50 و 250';
        break;
      case 'DiastolicBP':
        if (value < 30 || value > 150) return 'الضغط الانبساطي يجب أن يكون بين 30 و 150';
        break;
      case 'Temperature':
        if (value < 34 || value > 42) return 'الحرارة يجب أن تكون بين 34 و 42';
        break;
      case 'Glucose':
        if (value < 20 || value > 600) return 'السكر يجب أن يكون بين 20 و 600';
        break;
      default:
        if (value < 0) return 'القيمة يجب أن تكون موجبة';
    }
    return null;
  }

  /// Medication dosage amount
  static String? dosageAmount(String? value) {
    if (value == null || value.trim().isEmpty) return 'الجرعة مطلوبة';
    if (double.tryParse(value.trim()) == null) return 'الجرعة يجب أن تكون رقماً';
    if (double.parse(value.trim()) <= 0) return 'الجرعة يجب أن تكون أكبر من صفر';
    if (double.parse(value.trim()) > 10000) return 'الجرعة كبيرة جداً';
    return null;
  }

  /// Scheduled times: at least one
  static String? scheduledTimes(List<String>? times) {
    if (times == null || times.isEmpty) return 'الرجاء إضافة وقت واحد على الأقل';
    return null;
  }

  /// Numeric threshold value
  static String? thresholdValue(String? value) {
    if (value == null || value.trim().isEmpty) return null; // nullable field
    final parsed = double.tryParse(value.trim());
    if (parsed == null) return 'الرجاء إدخال رقم صحيح';
    if (parsed < 0) return 'القيمة لا يمكن أن تكون سالبة';
    if (parsed > 500) return 'القيمة كبيرة جداً';
    return null;
  }

  /// Medication name
  static String? medicationName(String? value) {
    if (value == null || value.trim().isEmpty) return 'اسم الدواء مطلوب';
    if (value.trim().length > 200) return 'اسم الدواء طويل جداً';
    return null;
  }

  /// Generic required field
  static String? required(String? value, String field) {
    if (value == null || value.trim().isEmpty) return '$field مطلوب';
    return null;
  }
}
