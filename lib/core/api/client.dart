import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  // ---------------------------------------------------------
  // CONFIGURACIÓN DE CONEXIÓN
  // ---------------------------------------------------------

  // Usamos localhost para mejor compatibilidad CORS en browser
  static const String baseUrl = 'http://127.0.0.1:8001/api';

  // ---------------------------------------------------------

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Map<String, String> get headers => {
        "Content-Type": "application/json",
        "Accept": "application/json",
      };

  Future<Map<String, String>> getAuthHeaders() async {
    final token = await _storage.read(key: 'auth_token');
    return {
      "Content-Type": "application/json",
      "Accept": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  // Método POST genérico
  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    try {
      final authHeaders = await getAuthHeaders();
      final response = await http.post(
        url,
        headers: authHeaders,
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception(
          'Error de conexión con el servidor ($baseUrl). Verifica que Python esté corriendo.');
    }
  }

  // Método GET genérico (sin autenticación)
  Future<dynamic> get(String endpoint,
      {Map<String, String>? queryParameters}) async {
    Uri url = Uri.parse('$baseUrl/$endpoint');
    if (queryParameters != null) {
      url = url.replace(queryParameters: queryParameters);
    }

    try {
      final authHeaders = await getAuthHeaders();
      final response = await http.get(url, headers: authHeaders);
      return _handleResponse(response);
    } catch (e) {
      throw Exception(
          'Error de conexión con el servidor ($baseUrl). Verifica que Python esté corriendo.');
    }
  }

  // Método PUT genérico con autenticación
  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    try {
      final authHeaders = await getAuthHeaders();
      final response = await http.put(
        url,
        headers: authHeaders,
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception(
          'Error de conexión con el servidor ($baseUrl). Verifica que Python esté corriendo.');
    }
  }

  // Método DELETE genérico con autenticación
  Future<dynamic> delete(String endpoint,
      {Map<String, String>? queryParameters}) async {
    Uri url = Uri.parse('$baseUrl/$endpoint');
    if (queryParameters != null) {
      url = url.replace(queryParameters: queryParameters);
    }

    try {
      final authHeaders = await getAuthHeaders();
      final response = await http.delete(url, headers: authHeaders);
      return _handleResponse(response);
    } catch (e) {
      throw Exception(
          'Error de conexión con el servidor ($baseUrl). Verifica que Python esté corriendo.');
    }
  }

  // Método PATCH con autenticación
  Future<dynamic> patch(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    try {
      final authHeaders = await getAuthHeaders();
      final response = await http.patch(
        url,
        headers: authHeaders,
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception(
          'Error de conexión con el servidor ($baseUrl). Verifica que Python esté corriendo.');
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Decodificamos utf8 para que las tildes y ñ se vean bien
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception(
          'Error del servidor (${response.statusCode}): ${response.body}');
    }
  }
}
