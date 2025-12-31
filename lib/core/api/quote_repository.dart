import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'client.dart'; // Importamos esto para reusar la URL base (localhost vs 10.0.2.2)

class QuoteRepository {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Endpoint específico para calcular
  static const String _quoteEndpoint = 'api/quotes/calculate/';

  Future<Map<String, dynamic>> calculateQuote({
    required int polId,      // Puerto Origen
    required int podId,      // Puerto Destino
    required double weight,  // Peso
    required double volume,  // Volumen
    required double fobValue,// Valor FOB
    required String commodity, // Producto
  }) async {
    
    // 1. Obtener la URL correcta (detecta si es Web o Android automáticamente)
    final baseUrl = ApiClient.baseUrl; 
    final url = Uri.parse('$baseUrl/$_quoteEndpoint');

    // 2. Recuperar el Token de seguridad (la llave que nos dio el Login)
    String? token = await _storage.read(key: 'auth_token');

    // 3. Preparar los datos para enviar
    final Map<String, dynamic> data = {
      "pol_id": polId,
      "pod_id": podId,
      "weight_kg": weight,
      "volume_cbm": volume,
      "fob_value": fobValue,
      "commodity": commodity,
    };

    try {
      // 4. Enviar la petición al servidor
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          // ¡IMPORTANTE! Aquí pegamos la llave para que Django nos deje pasar
          "Authorization": "Bearer $token", 
        },
        body: jsonEncode(data),
      );

      // 5. Analizar la respuesta
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        // Si hay error, devolvemos el mensaje del servidor
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }
}