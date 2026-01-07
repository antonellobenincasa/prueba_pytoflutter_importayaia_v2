// Servicio Central de Firebase/Firestore
// Reemplaza completamente al viejo ApiClient de Django

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // =========================================
  // USUARIOS
  // =========================================

  /// Obtener usuario actual
  User? get currentUser => _auth.currentUser;

  /// Obtener perfil del usuario actual
  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = currentUser;
    if (user == null) return null;

    final doc = await _db.collection('users').doc(user.uid).get();
    return doc.exists ? doc.data() : null;
  }

  /// Actualizar perfil del usuario
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    final user = currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    await _db.collection('users').doc(user.uid).update(data);
  }

  /// Obtener todos los usuarios (admin)
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final snapshot = await _db.collection('users').get();
    return snapshot.docs.map((d) => {'id': d.id, ...d.data()}).toList();
  }

  /// Verificar si un RUC ya está registrado
  /// Retorna null si el RUC está disponible, o el email del usuario que lo tiene si ya existe
  Future<String?> checkRucExists(String ruc, {String? excludeUserId}) async {
    if (ruc.isEmpty) return null;

    final query =
        await _db.collection('users').where('ruc', isEqualTo: ruc).get();

    for (final doc in query.docs) {
      // Si hay un userId a excluir (para edición de perfil), lo saltamos
      if (excludeUserId != null && doc.id == excludeUserId) continue;

      // RUC encontrado en otro usuario
      final data = doc.data();
      return data['email'] ?? 'usuario desconocido';
    }

    return null; // RUC disponible
  }

  /// Actualizar usuario por ID (admin)
  Future<void> updateUserById(String odId, Map<String, dynamic> data) async {
    await _db.collection('users').doc(odId).update(data);
  }

  // =========================================
  // PUERTOS
  // =========================================

  /// Obtener todos los puertos
  Future<List<Map<String, dynamic>>> getPorts({String? search}) async {
    Query<Map<String, dynamic>> query = _db.collection('ports');

    final snapshot = await query.get();
    var results = snapshot.docs.map((d) => {'id': d.id, ...d.data()}).toList();

    // Filtrar por búsqueda si se proporciona
    if (search != null && search.isNotEmpty) {
      final searchLower = search.toLowerCase();
      results = results.where((port) {
        final name = (port['name'] ?? '').toString().toLowerCase();
        final code = (port['code'] ?? '').toString().toLowerCase();
        return name.contains(searchLower) || code.contains(searchLower);
      }).toList();
    }

    return results;
  }

  /// Crear puerto
  Future<void> createPort(Map<String, dynamic> data) async {
    await _db.collection('ports').add({
      ...data,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  /// Actualizar puerto
  Future<void> updatePort(String id, Map<String, dynamic> data) async {
    await _db.collection('ports').doc(id).update(data);
  }

  /// Eliminar puerto
  Future<void> deletePort(String id) async {
    await _db.collection('ports').doc(id).delete();
  }

  // =========================================
  // AEROPUERTOS
  // =========================================

  /// Obtener todos los aeropuertos
  Future<List<Map<String, dynamic>>> getAirports({String? search}) async {
    final snapshot = await _db.collection('airports').get();
    var results = snapshot.docs.map((d) => {'id': d.id, ...d.data()}).toList();

    if (search != null && search.isNotEmpty) {
      final searchLower = search.toLowerCase();
      results = results.where((airport) {
        final name = (airport['name'] ?? '').toString().toLowerCase();
        final code = (airport['code'] ?? '').toString().toLowerCase();
        return name.contains(searchLower) || code.contains(searchLower);
      }).toList();
    }

    return results;
  }

  /// Crear aeropuerto
  Future<void> createAirport(Map<String, dynamic> data) async {
    await _db.collection('airports').add({
      ...data,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  /// Actualizar aeropuerto
  Future<void> updateAirport(String id, Map<String, dynamic> data) async {
    await _db.collection('airports').doc(id).update(data);
  }

  /// Eliminar aeropuerto
  Future<void> deleteAirport(String id) async {
    await _db.collection('airports').doc(id).delete();
  }

  // =========================================
  // CONTENEDORES
  // =========================================

  /// Obtener todos los contenedores
  Future<List<Map<String, dynamic>>> getContainers() async {
    final snapshot = await _db.collection('containers').get();
    return snapshot.docs.map((d) => {'id': d.id, ...d.data()}).toList();
  }

  // =========================================
  // COTIZACIONES (QUOTES)
  // =========================================

  /// Crear cotización
  Future<String> createQuote(Map<String, dynamic> data) async {
    final user = currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    final docRef = await _db.collection('quotes').add({
      ...data,
      'userId': user.uid,
      'userEmail': user.email,
      'status': 'pending',
      'created_at': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  /// Obtener cotizaciones del usuario
  Future<List<Map<String, dynamic>>> getUserQuotes() async {
    final user = currentUser;
    if (user == null) return [];

    final snapshot = await _db
        .collection('quotes')
        .where('userId', isEqualTo: user.uid)
        .orderBy('created_at', descending: true)
        .get();

    return snapshot.docs.map((d) => {'id': d.id, ...d.data()}).toList();
  }

  /// Obtener todas las cotizaciones (admin)
  Future<List<Map<String, dynamic>>> getAllQuotes() async {
    final snapshot = await _db
        .collection('quotes')
        .orderBy('created_at', descending: true)
        .get();
    return snapshot.docs.map((d) => {'id': d.id, ...d.data()}).toList();
  }

  /// Actualizar cotización
  Future<void> updateQuote(String id, Map<String, dynamic> data) async {
    await _db.collection('quotes').doc(id).update(data);
  }

  // =========================================
  // EMBARQUES (SHIPMENTS)
  // =========================================

  /// Obtener todos los embarques
  Future<List<Map<String, dynamic>>> getShipments() async {
    final snapshot = await _db
        .collection('shipments')
        .orderBy('created_at', descending: true)
        .get();
    return snapshot.docs.map((d) => {'id': d.id, ...d.data()}).toList();
  }

  /// Actualizar embarque
  Future<void> updateShipment(String id, Map<String, dynamic> data) async {
    await _db.collection('shipments').doc(id).update(data);
  }

  // =========================================
  // TARIFAS DE FLETE
  // =========================================

  Future<List<Map<String, dynamic>>> getFreightRates() async {
    final snapshot = await _db.collection('freight_rates').get();
    return snapshot.docs.map((d) => {'id': d.id, ...d.data()}).toList();
  }

  Future<void> createFreightRate(Map<String, dynamic> data) async {
    await _db.collection('freight_rates').add(data);
  }

  Future<void> updateFreightRate(String id, Map<String, dynamic> data) async {
    await _db.collection('freight_rates').doc(id).update(data);
  }

  // =========================================
  // CÓDIGOS HS (ARANCELES)
  // =========================================

  Future<List<Map<String, dynamic>>> getHsCodes() async {
    final snapshot = await _db.collection('hs_codes').get();
    return snapshot.docs.map((d) => {'id': d.id, ...d.data()}).toList();
  }

  Future<void> createHsCode(Map<String, dynamic> data) async {
    await _db.collection('hs_codes').add(data);
  }

  Future<void> updateHsCode(String id, Map<String, dynamic> data) async {
    await _db.collection('hs_codes').doc(id).update(data);
  }

  // =========================================
  // PROVEEDORES
  // =========================================

  Future<List<Map<String, dynamic>>> getProviders() async {
    final snapshot = await _db.collection('providers').get();
    return snapshot.docs.map((d) => {'id': d.id, ...d.data()}).toList();
  }

  Future<void> createProvider(Map<String, dynamic> data) async {
    await _db.collection('providers').add(data);
  }

  // =========================================
  // LOGS (ADMIN)
  // =========================================

  Future<List<Map<String, dynamic>>> getLogs({String? action}) async {
    Query<Map<String, dynamic>> query =
        _db.collection('logs').orderBy('timestamp', descending: true);

    if (action != null && action.isNotEmpty) {
      query = query.where('action', isEqualTo: action);
    }

    final snapshot = await query.limit(100).get();
    return snapshot.docs.map((d) => {'id': d.id, ...d.data()}).toList();
  }

  Future<void> logAction(String action, Map<String, dynamic> details) async {
    final user = currentUser;
    await _db.collection('logs').add({
      'action': action,
      'details': details,
      'userId': user?.uid,
      'userEmail': user?.email,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // =========================================
  // INVITACIONES FF (FREIGHT FORWARDERS)
  // =========================================

  Future<List<Map<String, dynamic>>> getFFInvitations() async {
    final snapshot = await _db.collection('ff_invitations').get();
    return snapshot.docs.map((d) => {'id': d.id, ...d.data()}).toList();
  }

  Future<void> createFFInvitation(Map<String, dynamic> data) async {
    await _db.collection('ff_invitations').add({
      ...data,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  // =========================================
  // PRE-LIQUIDACIONES / CÁLCULOS
  // =========================================

  Future<Map<String, dynamic>> calculatePreLiquidation(
    Map<String, dynamic> data,
  ) async {
    // Por ahora, cálculo simplificado local
    // En producción, podrías usar Cloud Functions
    final double fobValue = (data['fob_value'] ?? 0).toDouble();
    final double freightCost = (data['freight_cost'] ?? 0).toDouble();
    final double insuranceRate = 0.005; // 0.5%
    final double dutyRate = (data['duty_rate'] ?? 0.12).toDouble();

    final double insurance = fobValue * insuranceRate;
    final double cif = fobValue + freightCost + insurance;
    final double duties = cif * dutyRate;
    final double iva = (cif + duties) * 0.12;
    final double total = cif + duties + iva;

    return {
      'fob_value': fobValue,
      'freight_cost': freightCost,
      'insurance': insurance,
      'cif': cif,
      'duties': duties,
      'iva': iva,
      'total': total,
      'calculated_at': DateTime.now().toIso8601String(),
    };
  }

  // =========================================
  // COMPATIBILITY WRAPPERS (LEGACY API SUPPORT)
  // Maps old Django endpoints to Firestore methods
  // =========================================

  /// GET compatibility wrapper for admin screens
  Future<dynamic> get(
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    final search = queryParameters?['search'];

    if (path.contains('ports')) return getPorts(search: search);
    if (path.contains('airports')) return getAirports(search: search);
    if (path.contains('containers')) return getContainers();
    if (path.contains('leads') || path.contains('users')) return getAllUsers();
    if (path.contains('submissions') || path.contains('quotes')) {
      return getAllQuotes();
    }
    if (path.contains('shipments')) return getShipments();
    if (path.contains('freight-rates')) return getFreightRates();
    if (path.contains('hs-codes')) return getHsCodes();
    if (path.contains('providers')) return getProviders();
    if (path.contains('logs')) {
      return getLogs(action: queryParameters?['action']);
    }
    if (path.contains('ff-invitations')) return getFFInvitations();
    if (path.contains('ruc-approvals')) {
      // Get users with pending RUC status
      final users = await getAllUsers();
      return users.where((u) => u['ruc_status'] == 'pending').toList();
    }
    if (path.contains('profit-review')) return getAllQuotes();

    // Fallback: return empty list
    return [];
  }

  /// POST compatibility wrapper for admin screens
  Future<dynamic> post(String path, Map<String, dynamic> data) async {
    if (path.contains('ports')) {
      await createPort(data);
      return {'success': true};
    }
    if (path.contains('airports')) {
      await createAirport(data);
      return {'success': true};
    }
    if (path.contains('hs-codes')) {
      await createHsCode(data);
      return {'success': true};
    }
    if (path.contains('ff-invitations')) {
      await createFFInvitation(data);
      return {'success': true};
    }
    if (path.contains('providers')) {
      await createProvider(data);
      return {'success': true};
    }
    if (path.contains('leads') || path.contains('users')) {
      // Extract user ID from path and update
      final idMatch = RegExp(r'/([^/]+)/$').firstMatch(path);
      if (idMatch != null) {
        final userId = idMatch.group(1);
        if (userId != null) {
          await _db.collection('users').doc(userId).update(data);
        }
      }
      return {'success': true};
    }
    if (path.contains('submissions') || path.contains('quotes')) {
      final id = await createQuote(data);
      return {'id': id, 'success': true};
    }
    if (path.contains('ruc-approvals')) {
      // Handle RUC approval/rejection
      // Path format: accounts/admin/ruc-approvals/USER_ID/
      // Data: {'action': 'approve'} or {'action': 'reject'}
      final idMatch = RegExp(r'ruc-approvals/([^/]+)').firstMatch(path);
      final action = data['action'];

      if (idMatch != null && action != null) {
        final userId = idMatch.group(1);
        if (userId != null) {
          final isApproved = action == 'approve';

          // --- VALIDACIÓN DE RUC DUPLICADO (Solo al aprobar) ---
          if (isApproved) {
            // Obtener el RUC del usuario a aprobar
            final userDoc = await _db.collection('users').doc(userId).get();
            if (!userDoc.exists) {
              return {
                'success': false,
                'error': 'Usuario no encontrado',
              };
            }

            final userData = userDoc.data()!;
            final rucToApprove = userData['ruc']?.toString() ?? '';

            if (rucToApprove.isNotEmpty) {
              // Buscar si otro usuario ya tiene este RUC aprobado
              final duplicateQuery = await _db
                  .collection('users')
                  .where('ruc', isEqualTo: rucToApprove)
                  .where('ruc_status', isEqualTo: 'approved')
                  .get();

              // Filtrar para excluir el usuario actual
              final duplicates =
                  duplicateQuery.docs.where((doc) => doc.id != userId).toList();

              if (duplicates.isNotEmpty) {
                final existingUser = duplicates.first.data();
                final existingEmail =
                    existingUser['email'] ?? 'email desconocido';
                return {
                  'success': false,
                  'error':
                      'RUC duplicado: Este RUC ($rucToApprove) ya está registrado y aprobado para el usuario: $existingEmail',
                  'duplicate_email': existingEmail,
                };
              }
            }
          }
          // --- FIN VALIDACIÓN DE RUC DUPLICADO ---

          await _db.collection('users').doc(userId).update({
            'ruc_status': isApproved ? 'approved' : 'rejected',
            'is_active_importer': isApproved,
          });

          // Log the action
          await logAction('ruc_$action', {'user_id': userId});
        }
      }
      return {'success': true};
    }

    // Log the action
    await logAction('post', {'path': path, 'data': data});
    return {'success': true};
  }

  /// PUT compatibility wrapper
  Future<dynamic> put(String path, Map<String, dynamic> data) async {
    final id = data['id']?.toString();

    if (path.contains('ports') && id != null) {
      await updatePort(id, data);
      return {'success': true};
    }
    if (path.contains('airports') && id != null) {
      await updateAirport(id, data);
      return {'success': true};
    }
    if (path.contains('quotes') && id != null) {
      await updateQuote(id, data);
      return {'success': true};
    }
    if (path.contains('shipments') && id != null) {
      await updateShipment(id, data);
      return {'success': true};
    }
    if (path.contains('freight-rates') && id != null) {
      await updateFreightRate(id, data);
      return {'success': true};
    }
    if (path.contains('hs-codes') && id != null) {
      await updateHsCode(id, data);
      return {'success': true};
    }

    return {'success': true};
  }

  /// DELETE compatibility wrapper
  Future<dynamic> delete(
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    final id = queryParameters?['id'];

    if (path.contains('ports') && id != null) {
      await deletePort(id);
      return {'success': true};
    }
    if (path.contains('airports') && id != null) {
      await deleteAirport(id);
      return {'success': true};
    }

    return {'success': true};
  }
}
