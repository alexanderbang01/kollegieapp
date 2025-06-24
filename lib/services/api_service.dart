import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Base URL til korrekt server
  static const String baseUrl = 'https://kollegie.socdata.dk/api';

  static const Duration timeout = Duration(seconds: 30);

  // Standard headers
  static Map<String, String> _getHeaders(String? authorization) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (authorization != null) {
      headers['Authorization'] = authorization;
    }

    return headers;
  }

  // GET request
  static Future<Map<String, dynamic>> get({
    required String endpoint,
    String? authorization,
    Map<String, String>? queryParams,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl$endpoint');

      if (queryParams != null) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await http
          .get(uri, headers: _getHeaders(authorization))
          .timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Netværksfejl: $e', 'data': null};
    }
  }

  // POST request
  static Future<Map<String, dynamic>> post({
    required String endpoint,
    String? authorization,
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: _getHeaders(authorization),
            body: body != null ? json.encode(body) : null,
          )
          .timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Netværksfejl: $e', 'data': null};
    }
  }

  // PUT request
  static Future<Map<String, dynamic>> put({
    required String endpoint,
    String? authorization,
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl$endpoint'),
            headers: _getHeaders(authorization),
            body: body != null ? json.encode(body) : null,
          )
          .timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Netværksfejl: $e', 'data': null};
    }
  }

  // DELETE request
  static Future<Map<String, dynamic>> delete({
    required String endpoint,
    String? authorization,
    Map<String, dynamic>? body,
  }) async {
    try {
      final request = http.Request('DELETE', Uri.parse('$baseUrl$endpoint'));
      request.headers.addAll(_getHeaders(authorization));

      if (body != null) {
        request.body = json.encode(body);
      }

      final streamedResponse = await request.send().timeout(timeout);
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Netværksfejl: $e', 'data': null};
    }
  }

  // Håndter response
  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final data = json.decode(response.body) as Map<String, dynamic>;

      // Tilføj HTTP status code til response
      data['statusCode'] = response.statusCode;

      return data;
    } catch (e) {
      return {
        'success': false,
        'message': 'Fejl ved parsing af response: $e',
        'data': null,
        'statusCode': response.statusCode,
      };
    }
  }
}
