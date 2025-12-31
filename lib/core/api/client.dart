import 'dart:convert';
import 'package:flutter/foundation.dart'; // Necesario para 'kIsWeb'
import 'package:http/http.dart' as http;
// Importamos dart:io de forma condicional para evitar errores graves en web


class ApiClient {
  static String get baseUrl {
    // 1. REGLA DE ORO: Si es Web, usa localhost siempre.
    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    }
    
    // 2. Solo si NO es web, intentamos chequear el sistema operativo
    // (Este chequeo es seguro porque ya descartamos la web arriba)
    try {
      // Para Android Emulator usamos la IP especial 10.0.2.2
      // Nota: Usamos una cadena string para evitar importar Platform directamente si da problemas
      if (defaultTargetPlatform == TargetPlatform.android) {
        return 'http://10.0.2.2:8000';
      }
    } catch (e) {
      // Si falla algo, usamos localhost por defecto
    }

    // 3. Para iOS Simulator y otros
    return 'http://127.0.0.1:8000'; 
  }

  final Map<String, String> headers = {
    "Content-Type": "application/json",
    "Accept": "application/json",
  };

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Error de conexión ($baseUrl): $e');
    }
  }

  Future<dynamic> get(String endpoint) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    try {
      final response = await http.get(url, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Error de conexión ($baseUrl): $e');
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      // Manejo simple de errores para debug
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }
}