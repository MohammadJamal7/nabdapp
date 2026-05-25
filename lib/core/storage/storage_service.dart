import 'package:hive_flutter/hive_flutter.dart';
import '../constants/api_constants.dart';

class StorageService {
  static late Box _secureBox;
  static late Box _generalBox;

  static const String _schemaVersionKey = '_schema_version';
  static const int _currentSchemaVersion = 2; // Increment to invalidate old sessions

   static Future<void> init() async {
    await Hive.initFlutter();
    _secureBox = await Hive.openBox('secure_box');
    _generalBox = await Hive.openBox('general_box');
    
    // Check schema version and clear if outdated
    final storedVersion = read<int>(_schemaVersionKey) ?? 0;
    if (storedVersion < _currentSchemaVersion) {
      await clearAll();
      await write(_schemaVersionKey, _currentSchemaVersion);
    }
  }

  static Future<void> write(String key, dynamic value) async {
    if (key == StorageKeys.accessToken || 
        key == StorageKeys.refreshToken || 
        key == StorageKeys.tokenExpiry ||
        key == StorageKeys.userRole ||
        key == StorageKeys.userId ||
        key == StorageKeys.patientId ||
        key == StorageKeys.fcmToken) {
      await _secureBox.put(key, value);
    } else {
      await _generalBox.put(key, value);
    }
  }

  static T? read<T>(String key) {
    final box = key == StorageKeys.accessToken || 
                key == StorageKeys.refreshToken || 
                key == StorageKeys.tokenExpiry ||
                key == StorageKeys.userRole ||
                key == StorageKeys.userId ||
                key == StorageKeys.patientId ||
                key == StorageKeys.fcmToken
        ? _secureBox
        : _generalBox;
    return box.get(key) as T?;
  }

  static Future<void> delete(String key) async {
    final box = key == StorageKeys.accessToken || 
                key == StorageKeys.refreshToken || 
                key == StorageKeys.tokenExpiry ||
                key == StorageKeys.userRole ||
                key == StorageKeys.userId ||
                key == StorageKeys.patientId ||
                key == StorageKeys.fcmToken
        ? _secureBox
        : _generalBox;
    await box.delete(key);
  }

  static Future<void> clearAll() async {
    // Preserve schema version
    final schemaVersion = read<int>(_schemaVersionKey);
    await _secureBox.clear();
    await _generalBox.clear();
    if (schemaVersion != null) {
      await write(_schemaVersionKey, schemaVersion);
    }
  }

  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime expiresAt,
  }) async {
    await write(StorageKeys.accessToken, accessToken);
    await write(StorageKeys.refreshToken, refreshToken);
    await write(StorageKeys.tokenExpiry, expiresAt.toIso8601String());
  }

  static String? get accessToken => read<String>(StorageKeys.accessToken);
  static String? get refreshToken => read<String>(StorageKeys.refreshToken);
  static DateTime? get tokenExpiry {
    final expiryStr = read<String>(StorageKeys.tokenExpiry);
    return expiryStr != null ? DateTime.parse(expiryStr) : null;
  }
  static String? get userRole => read<String>(StorageKeys.userRole);
  static String? get userId => read<String>(StorageKeys.userId);
  static String? get patientId => read<String>(StorageKeys.patientId);

  static Future<void> saveUserSession({
    required String userId,
    required String role,
    String? patientId,
  }) async {
    await write(StorageKeys.userId, userId);
    await write(StorageKeys.userRole, role);
    if (patientId != null) {
      await write(StorageKeys.patientId, patientId);
    }
  }

  static bool get isAuthenticated => accessToken != null && accessToken!.isNotEmpty;
  
  static bool get isTokenExpired {
    final expiry = tokenExpiry;
    if (expiry == null) return true;
    return DateTime.now().isAfter(expiry);
  }
}