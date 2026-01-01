import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api/client.dart'; // Importamos tu cliente real

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final ApiClient _apiClient = ApiClient(); // Instancia del cliente real

  bool _isLoggedIn = false;
  String? _userToken;
  String? _refreshToken;
  String? _userId;
  String? _userEmail;
  String? _userName;
  String? _userRuc;

  // User profile data from backend
  Map<String, dynamic>? _userData;

  // Access control flags
  bool _isRucApproved = false;
  String? _rucStatus; // 'pending', 'approved', 'rejected', null
  bool _hasCompletedImport = false;
  bool _isProfileComplete = false;

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  String? get userToken => _userToken;
  String? get userId => _userId;
  String? get userEmail => _userEmail;
  String? get userName => _userName;
  String? get userRuc => _userRuc;
  bool get isRucApproved => _isRucApproved;
  String? get rucStatus => _rucStatus;
  bool get hasCompletedImport => _hasCompletedImport;
  bool get isProfileComplete => _isProfileComplete;
  Map<String, dynamic>? get userData => _userData;

  /// Verifica si hay una sesión guardada
  Future<bool> checkStoredSession() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      final email = await _storage.read(key: 'user_email');

      if (token != null && token.isNotEmpty) {
        _userToken = token;
        _userEmail = email;
        _isLoggedIn = true;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error checking stored session: $e');
    }
    return false;
  }

  /// Login REAL conectado al backend Python (Puerto 8001)
  Future<AuthResult> login(String email, String password) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        return AuthResult(
            success: false, message: 'Email y contraseña requeridos');
      }

      print('📡 Enviando Login a Django...');

      // Llamada REAL al servidor
      final response = await _apiClient.post('accounts/login/', {
        'email': email,
        'password': password,
      });

      print('✅ Respuesta recibida: $response');

      // Django devuelve: { "tokens": { "access": "...", "refresh": "..." }, "user": {...} }
      final tokens = response['tokens'];
      final token =
          tokens?['access'] ?? response['access'] ?? response['token'];
      final refresh = tokens?['refresh'];

      if (token != null) {
        _userToken = token;
        _refreshToken = refresh;
        _userEmail = email;
        _isLoggedIn = true;

        // Guardar datos del usuario desde la respuesta
        if (response['user'] != null) {
          _userData = response['user'];
          _userId = _userData?['id']?.toString();
          _userName =
              '${_userData?['first_name'] ?? ''} ${_userData?['last_name'] ?? ''}'
                  .trim();
          _rucStatus = _userData?['ruc_status'];
          _isRucApproved = _userData?['ruc_approved'] ?? false;
          _hasCompletedImport = _userData?['has_approved_quote'] ?? false;
        }

        await _storage.write(key: 'auth_token', value: _userToken);
        await _storage.write(key: 'refresh_token', value: _refreshToken);
        await _storage.write(key: 'user_email', value: _userEmail);

        notifyListeners();
        return AuthResult(
            success: true, message: 'Bienvenido', data: _userData);
      } else {
        return AuthResult(
            success: false, message: 'Error: No se recibió token');
      }
    } catch (e) {
      print('❌ Error en Login: $e');
      return AuthResult(
          success: false,
          message: 'Fallo al iniciar sesión. Revisa usuario/clave.');
    }
  }

  /// Registro REAL conectado al backend Python
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
      if (email.isEmpty || password.length < 8) {
        return AuthResult(
            success: false, message: 'Datos inválidos o contraseña corta');
      }

      print('📡 Enviando Registro a Django...');

      // Construimos el objeto de datos que espera Django
      // NOTA: Debe coincidir con UserRegistrationSerializer de Django
      final Map<String, dynamic> registerData = {
        'email': email,
        'password': password,
        'password_confirm': password, // Requerido por el serializer
        'first_name': nombre,
        'last_name': apellido,
        'company_name': empresa,
        'phone': telefono,
      };

      // Agregar campos opcionales solo si tienen valor
      if (ciudad != null && ciudad.isNotEmpty) {
        registerData['city'] = ciudad;
      }

      // Llamada REAL al servidor
      final response =
          await _apiClient.post('accounts/register/', registerData);

      print('✅ Registro exitoso: $response');

      // Django devuelve tokens en registro también - auto-login
      final tokens = response['tokens'];
      final token = tokens?['access'];
      final refresh = tokens?['refresh'];

      if (token != null) {
        // Auto-login: guardar tokens y datos de usuario
        _userToken = token;
        _refreshToken = refresh;
        _userEmail = email;
        _isLoggedIn = true;
        _userName = '$nombre $apellido'.trim();

        // Guardar datos del usuario desde la respuesta
        if (response['user'] != null) {
          _userData = response['user'];
          _userId = _userData?['id']?.toString();
          _rucStatus = _userData?['ruc_status'];
          _isRucApproved = _userData?['ruc_approved'] ?? false;
          _hasCompletedImport = _userData?['has_approved_quote'] ?? false;
        }

        await _storage.write(key: 'auth_token', value: _userToken);
        await _storage.write(key: 'refresh_token', value: _refreshToken);
        await _storage.write(key: 'user_email', value: _userEmail);

        notifyListeners();
      }

      return AuthResult(
        success: true,
        message: 'Cuenta creada exitosamente.',
        requiresVerification: false, // Auto-logged in, no verification needed
        data: _userData,
      );
    } catch (e) {
      print('❌ Error en Registro: $e');
      // Manejo de errores comunes de Django (ej: Email ya existe)
      if (e.toString().contains('unique') || e.toString().contains('exists')) {
        return AuthResult(
            success: false, message: 'Este correo ya está registrado.');
      }
      return AuthResult(
          success: false, message: 'Error al registrar: ${e.toString()}');
    }
  }

  /// Cerrar sesión
  Future<void> logout() async {
    _isLoggedIn = false;
    _userToken = null;
    await _storage.deleteAll();
    notifyListeners();
  }

  bool canAccessProtectedContent() => _isLoggedIn;
}

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
