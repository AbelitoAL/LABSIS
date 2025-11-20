// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiService {
  // GET request
  static Future<Map<String, dynamic>> get(
    String endpoint, {
    String? token,
  }) async {
    try {
      final url = Uri.parse(ApiConfig.buildUrl(endpoint));
      final headers = token != null
          ? ApiConfig.headersWithAuth(token)
          : ApiConfig.headers;

      final response = await http.get(url, headers: headers);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Error en la petición GET: $e');
    }
  }

  // POST request
  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    try {
      final url = Uri.parse(ApiConfig.buildUrl(endpoint));
      final headers = token != null
          ? ApiConfig.headersWithAuth(token)
          : ApiConfig.headers;

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Error en la petición POST: $e');
    }
  }

  // PUT request
  static Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    try {
      final url = Uri.parse(ApiConfig.buildUrl(endpoint));
      final headers = token != null
          ? ApiConfig.headersWithAuth(token)
          : ApiConfig.headers;

      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Error en la petición PUT: $e');
    }
  }

  // DELETE request
  static Future<Map<String, dynamic>> delete(
    String endpoint, {
    String? token,
  }) async {
    try {
      final url = Uri.parse(ApiConfig.buildUrl(endpoint));
      final headers = token != null
          ? ApiConfig.headersWithAuth(token)
          : ApiConfig.headers;

      final response = await http.delete(url, headers: headers);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Error en la petición DELETE: $e');
    }
  }

  // Manejar respuesta
  static Map<String, dynamic> _handleResponse(http.Response response) {
    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw Exception(
        data['message'] ?? 'Error en la petición: ${response.statusCode}',
      );
    }
  }
}