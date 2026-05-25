import 'package:dio/dio.dart';

class AppException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;

  AppException({
    required this.message,
    this.code,
    this.statusCode,
  });

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException({super.message = 'Network error occurred', super.code, super.statusCode});
}

class ServerException extends AppException {
  ServerException({super.message = 'Server error occurred', super.code, super.statusCode});
}

class AuthException extends AppException {
  AuthException({super.message = 'Authentication error', super.code, super.statusCode});
}

class ValidationException extends AppException {
  final List<String> errors;
  ValidationException({
    super.message = 'Validation error',
    this.errors = const [],
    super.code,
    super.statusCode,
  });
}

class NotFoundException extends AppException {
  NotFoundException({super.message = 'Resource not found', super.code, super.statusCode});
}

class ConflictException extends AppException {
  ConflictException({super.message = 'Conflict error', super.code, super.statusCode});
}

Exception handleDioError(dynamic error) {
  if (error is! DioException) return AppException(message: error.toString());

  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.connectionError:
      return NetworkException(message: 'Connection timeout');
    case DioExceptionType.badResponse:
      final statusCode = error.response?.statusCode;
      final data = error.response?.data;
      final message = data is Map ? (data['message'] ?? 'Server error') : 'Server error';
      final code = data is Map ? data['code'] : null;

      if (statusCode == 400) {
        return ValidationException(
          message: message,
          errors: data is Map && data['errors'] != null ? List<String>.from(data['errors']) : [],
          code: code,
          statusCode: statusCode,
        );
      }
      if (statusCode == 401) {
        return AuthException(message: message, code: code, statusCode: statusCode);
      }
      if (statusCode == 403) {
        return AuthException(message: message, code: code, statusCode: statusCode);
      }
      if (statusCode == 404) {
        return NotFoundException(message: message, code: code, statusCode: statusCode);
      }
      if (statusCode == 409) {
        return ConflictException(message: message, code: code, statusCode: statusCode);
      }
      return ServerException(message: message, code: code, statusCode: statusCode);
    default:
      return AppException(message: error.message ?? 'Unknown error');
  }
}