import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService extends ChangeNotifier {
  // --- INSTANCIAS DE FIREBASE ---
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // --- ESTADO LOCAL COMPATIBLE CON TU UI ---
  bool _isLoading = false;
  bool _isLoggedIn = false;

  // Datos del Usuario (Compatibilidad Legacy)
  String? _userEmail;
  String? _userName;
  String? _userRuc;

  // Perfil completo
  Map<String, dynamic>? _userData;

  // Banderas de Control
  bool _isRucApproved = false;
  String? _rucStatus;
  final bool _hasCompletedImport = false;
  bool _isActiveImporter = false;

  // --- GETTERS CRÍTICOS ---
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _auth.currentUser != null;
  String? get userToken => _auth.currentUser?.uid;

  // CORRECCIÓN: Usamos directo Firebase, ya no la variable _userId
  String? get userId => _auth.currentUser?.uid;

  String? get userEmail => _userEmail ?? _auth.currentUser?.email;
  String? get userName => _userName ?? _auth.currentUser?.displayName;
  String? get userRuc => _userRuc;
  bool get isRucApproved => _isRucApproved;
  String? get rucStatus => _rucStatus;
  bool get hasCompletedImport => _hasCompletedImport;
  bool get isActiveImporter => _isActiveImporter;
  Map<String, dynamic>? get userData => _userData;

  // Getter para corregir el error en login_screen.dart
  String? get userRole => _userData?['role'] ?? 'user';

  // --- 1. VERIFICAR SESIÓN ---
  Future<bool> checkStoredSession() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        _isLoggedIn = true;
        _userEmail = user.email;
        // BORRADO: _userId = user.uid; (Ya no existe la variable, no es necesaria)

        await fetchUserProfile(); // Cargamos datos reales
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint("Error verificando sesión: $e");
    }
    return false;
  }

  // --- 2. LOGIN ---
  Future<AuthResult> login(String email, String password) async {
    _setLoading(true);
    try {
      UserCredential cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      await _checkSessionAndLoadProfile(cred.user!);

      _setLoading(false);
      return AuthResult(success: true, message: 'Bienvenido', data: _userData);
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      return AuthResult(success: false, message: e.message ?? 'Error Auth');
    } catch (e) {
      _setLoading(false);
      return AuthResult(success: false, message: 'Error: $e');
    }
  }

  // --- 3. REGISTRO ---
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
    _setLoading(true);
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      final String fullName = "$nombre $apellido".trim();

      // Estructura de Usuario en Firebase
      final Map<String, dynamic> userMap = {
        'uid': cred.user!.uid,
        'email': email,
        'first_name': nombre,
        'last_name': apellido,
        'full_name': fullName,
        'company_name': empresa,
        'phone': telefono,
        'ruc': ruc ?? '',
        'city': ciudad ?? '',
        'country': pais ?? 'Ecuador',
        'is_active_importer': false,
        'ruc_status': 'pending',
        'role': 'importer', // Rol por defecto
        'created_at': FieldValue.serverTimestamp(),
      };

      await _db.collection('users').doc(cred.user!.uid).set(userMap);
      await cred.user!.updateDisplayName(fullName);
      await _checkSessionAndLoadProfile(cred.user!);

      _setLoading(false);
      return AuthResult(
          success: true,
          message: 'Cuenta creada.',
          requiresVerification: true,
          data: userMap);
    } catch (e) {
      _setLoading(false);
      return AuthResult(success: false, message: 'Error al registrar: $e');
    }
  }

  // --- 4. LOGOUT ---
  Future<void> logout() async {
    await _auth.signOut();
    await _storage.deleteAll();
    _limpiarEstadoLocal();
    notifyListeners();
  }

  // --- FUNCIONES DE SOPORTE ---

  Future<bool> fetchUserProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      DocumentSnapshot doc = await _db.collection('users').doc(user.uid).get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _userData = data;
        _userName = data['full_name'];
        _userRuc = data['ruc'];
        _rucStatus = data['ruc_status'];
        _isRucApproved = data['is_active_importer'] == true;
        _isActiveImporter = _isRucApproved;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint("Error leyendo perfil: $e");
    }
    return false;
  }

  Future<void> _checkSessionAndLoadProfile(User user) async {
    _isLoggedIn = true;
    _userEmail = user.email;
    // BORRADO: _userId = user.uid; (Ya no existe la variable)
    await fetchUserProfile();
  }

  void _limpiarEstadoLocal() {
    _isLoggedIn = false;
    _userData = null;
    _isRucApproved = false;
  }

  // Helpers de acceso
  bool canAccessQuoteFeatures() => _isLoggedIn && _isRucApproved;
  bool canAccessPremiumFeatures() => _isLoggedIn && _hasCompletedImport;
  bool canAccessProtectedContent() => _isLoggedIn;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
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
