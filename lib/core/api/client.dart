import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  // ---------------------------------------------------------
  // CONFIGURACIÓN DE CONEXIÓN (Bypass Antigravity/Túneles)
  // ---------------------------------------------------------

  // Reemplaza los números de abajo con la IP que obtuviste en ipconfig.
  // Mantén el puerto :8000 y el http:// al inicio.
  static const String baseUrl =
      'http://192.168.68.69:8000'; // <--- ¡EDITA ESTA LÍNEA!

  // ---------------------------------------------------------

  final Map<String, String> headers = {
    "Content-Type": "application/json",
    "Accept": "application/json",
  };

  // Método POST genérico
  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    try {
      print('Intentando POST a: $url'); // Log para depurar
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      print('Error POST: $e');
      throw Exception(
          'Error de conexión con el servidor ($baseUrl). Verifica que Python esté corriendo y la IP sea correcta.');
    }
  }

  // Método GET genérico
  Future<dynamic> get(String endpoint) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    try {
      print('Intentando GET a: $url'); // Log para depurar
      final response = await http.get(url, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      print('Error GET: $e');
      throw Exception(
          'Error de conexión con el servidor ($baseUrl). Verifica que Python esté corriendo y la IP sea correcta.');
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
