// REPOSITORIO DE COTIZACIONES - MIGRADO A FIREBASE
// Durante la migración a Firebase, este repositorio ya no llama al backend Django.
// Las cotizaciones se guardarán/leerán desde Firestore.

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuoteRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Colección de cotizaciones en Firestore
  static const String _quotesCollection = 'quotes';

  /// Calcula/guarda una cotización (por ahora solo es placeholder)
  Future<Map<String, dynamic>> calculateQuote({
    required int polId,
    required int podId,
    required double weight,
    required double volume,
    required double fobValue,
    required String commodity,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    // Datos de la cotización
    final Map<String, dynamic> quoteData = {
      'userId': user.uid,
      'polId': polId,
      'podId': podId,
      'weightKg': weight,
      'volumeCbm': volume,
      'fobValue': fobValue,
      'commodity': commodity,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    };

    try {
      // Guardar en Firestore
      DocumentReference docRef =
          await _db.collection(_quotesCollection).add(quoteData);

      debugPrint('QuoteRepository: Cotización guardada con ID: ${docRef.id}');

      // Devolver los datos con el ID
      return {
        'id': docRef.id,
        'success': true,
        'message': 'Cotización guardada exitosamente',
        ...quoteData,
      };
    } catch (e) {
      debugPrint('QuoteRepository: Error al guardar cotización: $e');
      throw Exception('Error al calcular cotización: $e');
    }
  }

  /// Obtiene las cotizaciones del usuario actual
  Future<List<Map<String, dynamic>>> getUserQuotes() async {
    final user = _auth.currentUser;
    if (user == null) {
      return [];
    }

    try {
      QuerySnapshot snapshot = await _db
          .collection(_quotesCollection)
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      debugPrint('QuoteRepository: Error al obtener cotizaciones: $e');
      return [];
    }
  }
}
