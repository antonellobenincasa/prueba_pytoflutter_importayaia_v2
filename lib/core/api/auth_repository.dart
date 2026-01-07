// lib/core/api/auth_repository.dart
// This file is now deprecated - Firebase Auth is used directly in auth_service.dart
// Keeping for backward compatibility

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/firebase_service.dart';

class AuthRepository {
  final FirebaseService _firebaseService = FirebaseService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Login via Firebase Auth is now handled by auth_service.dart
  // This method is deprecated
  Future<bool> login(String username, String password) async {
    debugPrint('AuthRepository.login is deprecated - use AuthService instead');
    return false;
  }

  // Recuperar datos guardados para mostrar en pantalla
  Future<Map<String, String?>> getUserData() async {
    // Try to get from Firebase first
    try {
      final profile = await _firebaseService.getUserProfile();
      if (profile != null) {
        return {
          'name': '${profile['first_name'] ?? ''} ${profile['last_name'] ?? ''}'
              .trim(),
          'email': profile['email']?.toString(),
          'ruc': profile['ruc']?.toString(),
          'company': profile['company_name']?.toString(),
        };
      }
    } catch (e) {
      debugPrint('Error getting user profile: $e');
    }

    // Fallback to local storage
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
    // Firebase handles tokens internally
    return await _storage.read(key: 'auth_token');
  }
}
