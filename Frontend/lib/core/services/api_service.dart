
import 'package:dio/dio.dart';
import '../utils/logger.dart';
import '../config/app_config.dart';
import 'token_service.dart';

class ApiService {
  static const Duration _timeout = Duration(seconds: 30);
  
  // Create Dio instance with proper configuration
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConfig.baseUrl,
    connectTimeout: _timeout,
    receiveTimeout: _timeout,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  /// Make a GET request
  static Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      Logger.info('Making GET request to: $endpoint');
      
      // Add JWT token to headers if available
      final finalHeaders = await _addAuthHeaders(headers);
      Logger.info('Headers: $finalHeaders');
      Logger.info('Query Parameters: ${queryParameters ?? {}}');
      
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: Options(headers: finalHeaders),
      );

      return _handleResponse(response);
    } catch (e) {
      Logger.error('GET request failed for $endpoint', e);
      rethrow;
    }
  }

  /// Make a POST request
  static Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      Logger.info('Making POST request to: $endpoint');
      
      // Add JWT token to headers if available
      final finalHeaders = await _addAuthHeaders(headers);
      Logger.info('Headers: $finalHeaders');
      Logger.info('Body: $body');
      
      final response = await _dio.post(
        endpoint,
        data: body,
        queryParameters: queryParameters,
        options: Options(headers: finalHeaders),
      );

      return _handleResponse(response);
    } catch (e) {
      Logger.error('POST request failed for $endpoint', e);
      rethrow;
    }
  }

  /// Make a PUT request
  static Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      Logger.info('Making PUT request to: $endpoint');
      
      // Add JWT token to headers if available
      final finalHeaders = await _addAuthHeaders(headers);
      Logger.info('Headers: $finalHeaders');
      Logger.info('Body: $body');
      
      final response = await _dio.put(
        endpoint,
        data: body,
        queryParameters: queryParameters,
        options: Options(headers: finalHeaders),
      );

      return _handleResponse(response);
    } catch (e) {
      Logger.error('PUT request failed for $endpoint', e);
      rethrow;
    }
  }

  /// Make a DELETE request
  static Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      Logger.info('Making DELETE request to: $endpoint');
      
      // Add JWT token to headers if available
      final finalHeaders = await _addAuthHeaders(headers);
      Logger.info('Headers: $finalHeaders');
      Logger.info('Query Parameters: ${queryParameters ?? {}}');
      
      final response = await _dio.delete(
        endpoint,
        queryParameters: queryParameters,
        options: Options(headers: finalHeaders),
      );

      return _handleResponse(response);
    } catch (e) {
      Logger.error('DELETE request failed for $endpoint', e);
      rethrow;
    }
  }

  /// Add authentication headers to requests
  static Future<Map<String, String>> _addAuthHeaders(Map<String, String>? headers) async {
    final finalHeaders = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    // Add custom headers if provided
    if (headers != null) {
      finalHeaders.addAll(headers);
    }
    
    // Add JWT token if available and not already provided
    if (!finalHeaders.containsKey('Authorization')) {
      try {
        final token = await TokenService.getToken();
        if (token != null && token.isNotEmpty) {
          finalHeaders['Authorization'] = 'Bearer $token';
          Logger.info('JWT token added to request headers');
        }
      } catch (e) {
        Logger.error('Failed to add JWT token to headers', e);
      }
    }
    
    return finalHeaders;
  }

  /// Handle Dio response
  static Map<String, dynamic> _handleResponse(Response response) {
    Logger.info('API Response: ${response.statusCode} - ${response.data}');
    
    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      if (response.data == null) {
        return {'success': true};
      }
      return response.data as Map<String, dynamic>;
    } else {
      throw ApiException(
        statusCode: response.statusCode!,
        message: _extractErrorMessage(response.data),
        data: _extractErrorData(response.data),
      );
    }
  }

  /// Extract error message from response
  static String _extractErrorMessage(dynamic responseData) {
    try {
      if (responseData is Map<String, dynamic>) {
        return responseData['message'] ?? responseData['error'] ?? 'Unknown error occurred';
      }
      return 'Unknown error occurred';
    } catch (e) {
      return 'Failed to parse error message';
    }
  }

  /// Extract error data from response
  static Map<String, dynamic>? _extractErrorData(dynamic responseData) {
    try {
      if (responseData is Map<String, dynamic>) {
        return responseData['data'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

/// Custom exception for API errors
class ApiException implements Exception {
  final int statusCode;
  final String message;
  final Map<String, dynamic>? data;

  ApiException({
    required this.statusCode,
    required this.message,
    this.data,
  });

  @override
  String toString() {
    return 'ApiException: $statusCode - $message';
  }
}
