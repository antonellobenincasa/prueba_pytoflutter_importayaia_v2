import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Servicio de autenticación para gestionar el estado del usuario
/// Este es un servicio básico que será conectado al backend Python
class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  bool _isLoggedIn = false;
  String? _userToken;
  String? _userId;
  String? _userEmail;
  String? _userName;
  String? _userRuc;
  bool _isRucApproved = false;

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  String? get userToken => _userToken;
  String? get userId => _userId;
  String? get userEmail => _userEmail;
  String? get userName => _userName;
  String? get userRuc => _userRuc;
  bool get isRucApproved => _isRucApproved;

  /// Verifica si hay una sesión guardada al iniciar la app
  Future<bool> checkStoredSession() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      final email = await _storage.read(key: 'user_email');
      final name = await _storage.read(key: 'user_name');
      final ruc = await _storage.read(key: 'user_ruc');
      final rucApproved = await _storage.read(key: 'ruc_approved');

      if (token != null && token.isNotEmpty) {
        _userToken = token;
        _userEmail = email;
        _userName = name;
        _userRuc = ruc;
        _isRucApproved = rucApproved == 'true';
        _isLoggedIn = true;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error checking stored session: $e');
    }
    return false;
  }

  /// Login con email y contraseña
  /// TODO: Conectar con API backend Python
  Future<AuthResult> login(String email, String password) async {
    try {
      // Simulación de llamada al backend
      // En producción, esto se conectará a tu API Python
      await Future.delayed(const Duration(seconds: 1));

      // Validación básica
      if (email.isEmpty || password.isEmpty) {
        return AuthResult(
            success: false, message: 'Email y contraseña requeridos');
      }

      // TODO: Llamar al endpoint real del backend
      // final response = await http.post(
      //   Uri.parse('$baseUrl/api/auth/login'),
      //   body: {'email': email, 'password': password},
      // );

      // Simulación de respuesta exitosa
      _userToken = 'simulated_token_${DateTime.now().millisecondsSinceEpoch}';
      _userEmail = email;
      _userName = email.split('@').first;
      _userId = 'user_123';
      _isLoggedIn = true;

      // Guardar en storage seguro
      await _storage.write(key: 'auth_token', value: _userToken);
      await _storage.write(key: 'user_email', value: _userEmail);
      await _storage.write(key: 'user_name', value: _userName);

      notifyListeners();
      return AuthResult(success: true, message: 'Login exitoso');
    } catch (e) {
      return AuthResult(success: false, message: 'Error de conexión: $e');
    }
  }

  /// Registro de nuevo usuario
  /// TODO: Conectar con API backend Python
  Future<AuthResult> register({
    required String nombre,
    required String apellido,
    required String email,
    required String empresa,
    required String telefono,
    required String password,
    String? ruc,
    String? ciudad,
    String? pais,
  }) async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      // Validaciones básicas
      if (email.isEmpty || password.isEmpty || nombre.isEmpty) {
        return AuthResult(
            success: false, message: 'Campos requeridos incompletos');
      }

      if (password.length < 8) {
        return AuthResult(
            success: false,
            message: 'La contraseña debe tener mínimo 8 caracteres');
      }

      // TODO: Llamar al endpoint real del backend
      // final response = await http.post(
      //   Uri.parse('$baseUrl/api/auth/register'),
      //   body: {...},
      // );

      // Simulación de registro exitoso
      // El usuario debe verificar su email y esperar aprobación de RUC
      return AuthResult(
        success: true,
        message: 'Cuenta creada. Revisa tu email para verificar.',
        requiresVerification: true,
      );
    } catch (e) {
      return AuthResult(success: false, message: 'Error de registro: $e');
    }
  }

  /// Cerrar sesión
  Future<void> logout() async {
    _isLoggedIn = false;
    _userToken = null;
    _userId = null;
    _userEmail = null;
    _userName = null;
    _userRuc = null;
    _isRucApproved = false;

    await _storage.deleteAll();
    notifyListeners();
  }

  /// Verificar si el usuario puede acceder a funciones protegidas
  bool canAccessProtectedContent() {
    return _isLoggedIn;
    // En producción también verificar:
    // return _isLoggedIn && _isRucApproved;
  }
}

/// Resultado de operaciones de autenticación
class AuthResult {
  final bool success;
  final String message;
  final bool requiresVerification;
  final Map<String, dynamic>? data;

  AuthResult({
    required this.success,
    required this.message,
    this.requiresVerification = false,
    this.data,
  });
}
