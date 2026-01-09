import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/port.dart';
import '../models/airport.dart';
import '../models/ciudad.dart';
import '../models/country.dart';
import '../models/hs_code.dart';
import '../models/incoterm.dart';
import '../models/unidad_medida.dart';
import '../models/proveedor.dart';
import '../models/system_config.dart';

class MasterDataService {
  // Singleton Pattern
  static final MasterDataService _instance = MasterDataService._internal();
  factory MasterDataService() => _instance;
  MasterDataService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- IN-MEMORY CACHE ---
  List<Port> _ports = [];
  List<Airport> _airports = [];
  List<Ciudad> _ciudades = [];
  List<Country> _countries = [];

  List<Incoterm> _incoterms = [];
  List<UnidadMedida> _unidades = [];
  List<Proveedor> _proveedores = [];

  // System Config & Rules
  final Map<String, double> _numericConstants = {};
  final Map<String, dynamic> _businessRules = {};

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // --- ACCESSORS ---
  List<Port> get ports => List.unmodifiable(_ports);
  List<Airport> get airports => List.unmodifiable(_airports);
  List<Ciudad> get ciudades => List.unmodifiable(_ciudades);
  List<Country> get countries => List.unmodifiable(_countries);

  List<Incoterm> get incoterms => List.unmodifiable(_incoterms);
  List<UnidadMedida> get unidades => List.unmodifiable(_unidades);
  List<Proveedor> get proveedores => List.unmodifiable(_proveedores);

  // --- INITIALIZATION (EAGER LOADING) ---
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      debugPrint("🚀 MasterDataService: Starting Cache Loading...");
      final startTime = DateTime.now();

      await Future.wait([
        _loadPorts(),
        _loadAirports(),
        _loadCiudades(),
        _loadCountries(), // Will use static list if DB empty
        _loadIncoterms(),
        _loadUnidades(),
        _loadProveedores(),
        _loadSystemConfig(),
      ]);

      _isInitialized = true;
      final duration = DateTime.now().difference(startTime);
      debugPrint(
          "✅ MasterDataService: Cache Loaded in ${duration.inMilliseconds}ms");
      debugPrint("   - Ports: ${_ports.length}");
      debugPrint("   - Airports: ${_airports.length}");
      debugPrint("   - Cities: ${_ciudades.length}");
      debugPrint("   - Config Keys: ${_numericConstants.length}");
    } catch (e) {
      debugPrint("❌ MasterDataService Error: $e");
      // Don't rethrow, app should try to utilize what loaded or retry later
    }
  }

  // --- LOADERS ---

  Future<void> _loadPorts() async {
    final snapshot = await _db.collection('ports').orderBy('puerto').get();
    _ports = snapshot.docs.map((d) => Port.fromJson(d.data(), d.id)).toList();
  }

  Future<void> _loadAirports() async {
    final snapshot =
        await _db.collection('airports').orderBy('aeropuerto').get();
    _airports =
        snapshot.docs.map((d) => Airport.fromJson(d.data(), d.id)).toList();
  }

  Future<void> _loadCiudades() async {
    final snapshot =
        await _db.collection('cobertura_ciudades').orderBy('ciudad').get();
    _ciudades =
        snapshot.docs.map((d) => Ciudad.fromJson(d.data(), d.id)).toList();
  }

  // 4. Crear el método de carga
  Future<void> _loadCountries() async {
    try {
      // Ordenamos por prioridad (1=China/USA) y luego alfabéticamente
      final snap = await _db
          .collection('countries')
          .orderBy('prioridad')
          .orderBy('nombre')
          .get();

      _countries = snap.docs.map((d) => Country.fromJson(d.data())).toList();
      debugPrint("   🌍 ${_countries.length} Países cargados");
    } catch (e) {
      debugPrint("⚠️ Error cargando países: $e");
    }
  }

  Future<void> _loadIncoterms() async {
    final snapshot = await _db.collection('incoterms').get();
    _incoterms = snapshot.docs.map((d) => Incoterm.fromJson(d.data())).toList();
  }

  Future<void> _loadUnidades() async {
    final snapshot = await _db.collection('unidades_medida').get();
    _unidades =
        snapshot.docs.map((d) => UnidadMedida.fromJson(d.data())).toList();
  }

  Future<void> _loadProveedores() async {
    final snapshot = await _db.collection('providers').orderBy('nombre').get();
    _proveedores =
        snapshot.docs.map((d) => Proveedor.fromJson(d.data(), d.id)).toList();
  }

  Future<void> _loadSystemConfig() async {
    // Load from multiple config collections
    final configSnapshot =
        await _db.collection('system_config').get(); // Global vars map
    final constantsSnapshot =
        await _db.collection('constantes_sistema').get(); // List of rules

    // Process global vars doc (if exists)
    if (configSnapshot.docs.isNotEmpty) {
      // Assuming global_vars is a single doc with map
      final globalDoc = configSnapshot.docs.firstWhere(
          (d) => d.id == 'global_vars',
          orElse: () => configSnapshot.docs.first);
      globalDoc.data().forEach((key, value) {
        if (value is num) {
          _numericConstants[key] = value.toDouble();
        }
      });
    }

    // Process constants dictionary list
    for (var doc in constantsSnapshot.docs) {
      final rule = ReglaNegocio.fromJson(doc.data(), doc.id);
      if (rule.value is num) {
        _numericConstants[rule.key] = rule.value.toDouble();
      }
      _businessRules[rule.key] = rule.value;
    }
  }

  // --- ON-DEMAND METHODS (No Cache) ---

  /// Search HS Codes by query (code or description)
  Future<List<HsCode>> searchHsCodes(String query) async {
    if (query.isEmpty) return [];

    // Firestore lacks full-text search, so we query common HS codes collection or basic prefix search
    // Best approach for Firestore: Client-side filtering if small, or prefix match
    // Given 4000+ records, prefix match on 'descripcion general' or 'partida arancelaria' is best.

    // Query 1: Match by Code Prefix
    final codeQuery = await _db
        .collection('hs_codes')
        .where('partida arancelaria', isGreaterThanOrEqualTo: query)
        .where('partida arancelaria', isLessThan: '${query}z')
        .limit(20)
        .get();

    // Query 2: Match by Description (Simple prefix/exact - limited in Firestore)
    // Note: Ideally use Algolia/Typesense. For now, we rely on 'hs_codes_comunes' for fast lookup
    final commonQuery = await _db
        .collection('hs_codes_comunes')
        .where('descripcion general',
            isGreaterThanOrEqualTo: query) // Simple text match attempt
        .where('descripcion general', isLessThan: '${query}z')
        .limit(20)
        .get();

    final results = <HsCode>[];

    for (var d in codeQuery.docs) {
      results.add(HsCode.fromJson(d.data(), d.id));
    }
    for (var d in commonQuery.docs) {
      results.add(HsCode.fromJson(d.data(), d.id));
    }

    return results
        .toSet()
        .toList(); // Dedup (needs equals/hashcode implementation in model or manually unique)
  }

  // --- UTILS ---

  double getConstant(String key, {double defaultValue = 0.0}) {
    return _numericConstants[key] ?? defaultValue;
  }
}
