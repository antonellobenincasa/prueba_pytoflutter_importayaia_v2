import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  // ---------------------------------------------------------
  // CONFIGURACIÓN DE CONEXIÓN
  // ---------------------------------------------------------

  // Usamos 127.0.0.1 y el puerto 8001/api como confirmamos antes.
  static const String baseUrl = 'http://127.0.0.1:8001/api';

  // ---------------------------------------------------------

  final Map<String, String> headers = {
    "Content-Type": "application/json",
    "Accept": "application/json",
  };

  // Método POST genérico
  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    try {
      print('Intentando POST a: $url');
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      print('Error POST: $e');
      throw Exception(
          'Error de conexión con el servidor ($baseUrl). Verifica que Python esté corriendo.');
    }
  }

  // Método GET genérico
  Future<dynamic> get(String endpoint) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    try {
      print('Intentando GET a: $url');
      final response = await http.get(url, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      print('Error GET: $e');
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
