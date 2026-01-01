// lib/core/api/auth_repository.dart
import 'package:flutter/foundation.dart'; // Para usar debugPrint en lugar de print
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'client.dart';

class AuthRepository {
  final ApiClient _client = ApiClient();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _loginEndpoint = 'accounts/login/';
  static const String _profileEndpoint =
      'accounts/profile/'; // Endpoint del perfil

  // Función para iniciar sesión
  Future<bool> login(String username, String password) async {
    try {
      final response = await _client.post(_loginEndpoint, {
        'email': username,
        'password': password,
      });

      if (response != null && response.containsKey('access')) {
        await _storage.write(key: 'auth_token', value: response['access']);

        // Descargar datos del perfil inmediatamente
        await _fetchAndStoreUserProfile();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      rethrow;
    }
  }

  // Descargar y guardar datos del usuario
  Future<void> _fetchAndStoreUserProfile() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) return;

      // Hacemos la petición al backend
      final response = await _client.get(_profileEndpoint);

      if (response != null) {
        // Guardamos los datos
        await _storage.write(
            key: 'user_full_name', value: response['full_name']);
        await _storage.write(key: 'user_email', value: response['email']);
        await _storage.write(key: 'user_ruc', value: response['ruc']);
        await _storage.write(
            key: 'user_company', value: response['company_name']);
      }
    } catch (e) {
      // Usamos debugPrint para evitar la advertencia de 'print'
      debugPrint("Error obteniendo perfil: $e");
    }
  }

  // Recuperar datos guardados para mostrar en pantalla
  Future<Map<String, String?>> getUserData() async {
    return {
      'name': await _storage.read(key: 'user_full_name'),
      'email': await _storage.read(key: 'user_email'),
      'ruc': await _storage.read(key: 'user_ruc'),
      'company': await _storage.read(key: 'user_company'),
    };
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }
}
