import 'dart:io';

import 'package:dio/dio.dart';

import '../error/failures.dart';

Failure mapDioError(DioException error) {
  if (error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.sendTimeout ||
      error.type == DioExceptionType.receiveTimeout) {
    return const NetworkFailure('Connection timed out. Please try again.');
  }

  if (error.error is SocketException) {
    return const NetworkFailure(
      'No internet connection. Please check your network.',
    );
  }

  final response = error.response;
  if (response == null) {
    return const UnknownFailure('Something went wrong. Please try again.');
  }

  final statusCode = response.statusCode ?? 0;
  final message = _extractMessage(response.data) ?? error.message;

  switch (statusCode) {
    case 400:
    case 409:
      return ValidationFailure(message ?? 'Invalid request.');
    case 401:
    case 403:
      return UnauthorizedFailure(message ?? 'Authentication failed.');
    case 404:
      return NotFoundFailure(message ?? 'Not found.');
    default:
      if (statusCode >= 500) {
        return ServerFailure(message ?? 'Something went wrong on our end.');
      }
      return UnknownFailure(
        message ?? 'Something went wrong. Please try again.',
      );
  }
}

String? _extractMessage(dynamic data) {
  try {
    if (data is String && data.isNotEmpty) return data;
    if (data is Map<String, dynamic>) {
      if (data['message'] != null) return data['message'].toString();
      if (data['error'] != null) return data['error'].toString();
      if (data['errors'] is Map) {
        return (data['errors'] as Map).values.join(', ');
      }
      if (data['errors'] is List) {
        return (data['errors'] as List).join(', ');
      }
    }
  } catch (_) {}
  return null;
}
