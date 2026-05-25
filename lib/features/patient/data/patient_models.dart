class MedicationDto {
  final String id;
  final String name;
  final String dosageAmount;
  final String dosageUnit;
  final String frequencyType;
  final List<String> scheduledTimes;
  final String? startDate;
  final String? endDate;
  final String? instructions;
  final bool isDeleted;

  MedicationDto({
    required this.id,
    required this.name,
    required this.dosageAmount,
    required this.dosageUnit,
    required this.frequencyType,
    required this.scheduledTimes,
    this.startDate,
    this.endDate,
    this.instructions,
    this.isDeleted = false,
  });

  factory MedicationDto.fromJson(Map<String, dynamic> json) => MedicationDto(
        id: json['id'] as String,
        name: json['name'] as String,
        dosageAmount: json['dosageAmount'] as String,
        dosageUnit: json['dosageUnit'] as String,
        frequencyType: json['frequencyType'] as String,
        scheduledTimes: (json['scheduledTimes'] as List).cast<String>(),
        startDate: json['startDate'] as String?,
        endDate: json['endDate'] as String?,
        instructions: json['instructions'] as String?,
        isDeleted: json['isDeleted'] as bool? ?? false,
      );

  String get dosage => '$dosageAmount $dosageUnit';
}

class MedicationLogDto {
  final String id;
  final String medicationId;
  final String? clientUUID;
  final DateTime scheduledAt;
  final DateTime? actualAt;
  final String status;
  final int snoozeCount;

  MedicationLogDto({
    required this.id,
    required this.medicationId,
    this.clientUUID,
    required this.scheduledAt,
    this.actualAt,
    required this.status,
    this.snoozeCount = 0,
  });

  factory MedicationLogDto.fromJson(Map<String, dynamic> json) => MedicationLogDto(
        id: json['id'] as String,
        medicationId: json['medicationId'] as String,
        clientUUID: json['clientUUID'] as String?,
        scheduledAt: DateTime.parse(json['scheduledAt'] as String),
        actualAt: json['actualAt'] != null ? DateTime.parse(json['actualAt'] as String) : null,
        status: json['status'] as String,
        snoozeCount: json['snoozeCount'] as int? ?? 0,
      );

  bool get isPending => status == 'Pending';
  bool get isTaken => status == 'Taken';
  bool get isSnoozed => status == 'Snoozed';
  bool get isMissed => status == 'Missed';
}

class VitalSignReadingDto {
  final String id;
  final String readingType;
  final double value;
  final String unit;
  final DateTime recordedAt;
  final double? latitude;
  final double? longitude;

  VitalSignReadingDto({
    required this.id,
    required this.readingType,
    required this.value,
    required this.unit,
    required this.recordedAt,
    this.latitude,
    this.longitude,
  });

  factory VitalSignReadingDto.fromJson(Map<String, dynamic> json) => VitalSignReadingDto(
        id: json['id'] as String,
        readingType: json['readingType'] as String,
        value: (json['value'] as num).toDouble(),
        unit: json['unit'] as String,
        recordedAt: DateTime.parse(json['recordedAt'] as String),
        latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
        longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      );

  String get displayValue => '${value.toInt()} $unit';
}

class VitalSignThresholdDto {
  final String readingType;
  final double? minValue;
  final double? maxValue;
  final bool isDefault;

  VitalSignThresholdDto({
    required this.readingType,
    this.minValue,
    this.maxValue,
    this.isDefault = false,
  });

  factory VitalSignThresholdDto.fromJson(Map<String, dynamic> json) => VitalSignThresholdDto(
        readingType: json['readingType'] as String,
        minValue: json['minValue'] != null ? (json['minValue'] as num).toDouble() : null,
        maxValue: json['maxValue'] != null ? (json['maxValue'] as num).toDouble() : null,
        isDefault: json['isDefault'] as bool? ?? false,
      );
}

class VitalSignSummaryDto {
  final String readingType;
  final double? min;
  final double? max;
  final double? average;
  final int sampleCount;

  VitalSignSummaryDto({
    required this.readingType,
    this.min,
    this.max,
    this.average,
    this.sampleCount = 0,
  });

  factory VitalSignSummaryDto.fromJson(Map<String, dynamic> json) => VitalSignSummaryDto(
        readingType: json['readingType'] as String,
        min: json['min'] != null ? (json['min'] as num).toDouble() : null,
        max: json['max'] != null ? (json['max'] as num).toDouble() : null,
        average: json['average'] != null ? (json['average'] as num).toDouble() : null,
        sampleCount: json['sampleCount'] as int? ?? 0,
      );
}

class EmergencyAlertDto {
  final String id;
  final String patientId;
  final String triggerType;
  final String status;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  EmergencyAlertDto({
    required this.id,
    required this.patientId,
    required this.triggerType,
    required this.status,
    this.latitude,
    this.longitude,
    required this.createdAt,
    this.resolvedAt,
  });

  factory EmergencyAlertDto.fromJson(Map<String, dynamic> json) => EmergencyAlertDto(
        id: json['id'] as String,
        patientId: json['patientId'] as String,
        triggerType: json['triggerType'] as String,
        status: json['status'] as String,
        latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
        longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
        createdAt: DateTime.parse(json['createdAt'] as String),
        resolvedAt: json['resolvedAt'] != null ? DateTime.parse(json['resolvedAt'] as String) : null,
      );

  bool get isActive => status == 'Active';
  bool get isAcknowledged => status == 'Acknowledged';
  bool get isCancelled => status == 'Cancelled';
}

class AlertDetailDto extends EmergencyAlertDto {
  final List<AlertEscalationLogDto> escalationLogs;

  AlertDetailDto({
    required super.id,
    required super.patientId,
    required super.triggerType,
    required super.status,
    super.latitude,
    super.longitude,
    required super.createdAt,
    super.resolvedAt,
    required this.escalationLogs,
  });

  factory AlertDetailDto.fromJson(Map<String, dynamic> json) => AlertDetailDto(
        id: json['id'] as String,
        patientId: json['patientId'] as String,
        triggerType: json['triggerType'] as String,
        status: json['status'] as String,
        latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
        longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
        createdAt: DateTime.parse(json['createdAt'] as String),
        resolvedAt: json['resolvedAt'] != null ? DateTime.parse(json['resolvedAt'] as String) : null,
        escalationLogs: (json['escalationLogs'] as List?)
                ?.map((e) => AlertEscalationLogDto.fromJson(e))
                .toList() ??
            [],
      );
}

class AlertEscalationLogDto {
  final String id;
  final String alertId;
  final String caregiverId;
  final int escalationIndex;
  final DateTime notifiedAt;
  final String channel;
  final String outcome;

  AlertEscalationLogDto({
    required this.id,
    required this.alertId,
    required this.caregiverId,
    required this.escalationIndex,
    required this.notifiedAt,
    required this.channel,
    required this.outcome,
  });

  factory AlertEscalationLogDto.fromJson(Map<String, dynamic> json) => AlertEscalationLogDto(
        id: json['id'] as String,
        alertId: json['alertId'] as String,
        caregiverId: json['caregiverId'] as String,
        escalationIndex: json['escalationIndex'] as int,
        notifiedAt: DateTime.parse(json['notifiedAt'] as String),
        channel: json['channel'] as String,
        outcome: json['outcome'] as String,
      );
}

class InsightDto {
  final String id;
  final String summary;
  final List<String> recommendations;
  final bool urgencyFlag;
  final DateTime generatedAt;

  InsightDto({
    required this.id,
    required this.summary,
    required this.recommendations,
    required this.urgencyFlag,
    required this.generatedAt,
  });

  factory InsightDto.fromJson(Map<String, dynamic> json) => InsightDto(
        id: json['id'] as String,
        summary: json['summary'] as String,
        recommendations: (json['recommendations'] as List).cast<String>(),
        urgencyFlag: json['urgencyFlag'] as bool? ?? false,
        generatedAt: DateTime.parse(json['generatedAt'] as String),
      );
}

class ArticleDto {
  final String id;
  final String titleAr;
  final String bodyAr;
  final List<String> conditionTags;
  final DateTime publishedAt;

  ArticleDto({
    required this.id,
    required this.titleAr,
    required this.bodyAr,
    required this.conditionTags,
    required this.publishedAt,
  });

  factory ArticleDto.fromJson(Map<String, dynamic> json) => ArticleDto(
        id: json['id'] as String,
        titleAr: json['titleAr'] as String,
        bodyAr: json['bodyAr'] as String,
        conditionTags: (json['conditionTags'] as List).cast<String>(),
        publishedAt: DateTime.parse(json['publishedAt'] as String),
      );
}

class CreateMedicationCommand {
  final String name;
  final String dosageAmount;
  final String dosageUnit;
  final String frequencyType;
  final List<String> scheduledTimes;
  final String startDate;
  final String? endDate;
  final String? instructions;

  CreateMedicationCommand({
    required this.name,
    required this.dosageAmount,
    required this.dosageUnit,
    required this.frequencyType,
    required this.scheduledTimes,
    required this.startDate,
    this.endDate,
    this.instructions,
  });

  Map<String, dynamic> toJson(String patientId) => {
        'name': name,
        'dosageAmount': dosageAmount,
        'dosageUnit': dosageUnit,
        'frequencyType': frequencyType,
        'scheduledTimes': scheduledTimes,
        'startDate': startDate,
        if (endDate != null) 'endDate': endDate,
        if (instructions != null) 'instructions': instructions,
      };
}

class RecordVitalCommand {
  final String readingType;
  final double value;
  final String unit;
  final double? latitude;
  final double? longitude;
  final String? notes;

  RecordVitalCommand({
    required this.readingType,
    required this.value,
    required this.unit,
    this.latitude,
    this.longitude,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'readingType': readingType,
        'value': value,
        'unit': unit,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (notes != null) 'notes': notes,
      };
}

class SetThresholdItemDto {
  final String readingType;
  final double? minValue;
  final double? maxValue;

  SetThresholdItemDto({
    required this.readingType,
    this.minValue,
    this.maxValue,
  });

  Map<String, dynamic> toJson() => {
        'readingType': readingType,
        if (minValue != null) 'minValue': minValue,
        if (maxValue != null) 'maxValue': maxValue,
      };
}