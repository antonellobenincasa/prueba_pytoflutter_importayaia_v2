import 'dart:async';
import '../api/client.dart';

/// Service to fetch ports and airports from Python backend
/// Used for POL/POD autocomplete in quote request forms
class PortAirportService {
  final ApiClient _apiClient = ApiClient();

  // Cache for all data
  List<Map<String, dynamic>>? _allPorts;
  List<Map<String, dynamic>>? _allAirports;
  List<Map<String, dynamic>>? _ecuadorPorts;
  List<Map<String, dynamic>>? _ecuadorAirports;

  /// Fetch ALL ports from API once and cache
  Future<List<Map<String, dynamic>>> _fetchAllPorts() async {
    if (_allPorts != null) return _allPorts!;

    try {
      final response = await _apiClient.get('sales/ports/');
      if (response is List) {
        _allPorts = List<Map<String, dynamic>>.from(response);
        // Successfully loaded ports from API
        return _allPorts!;
      }
    } catch (e) {
      // Error fetching ports - using fallback
    }

    // Fallback ports with comprehensive list
    _allPorts = _getFallbackPorts();
    return _allPorts!;
  }

  /// Fetch ALL airports from API once and cache
  Future<List<Map<String, dynamic>>> _fetchAllAirports() async {
    if (_allAirports != null) return _allAirports!;

    try {
      final response = await _apiClient.get('sales/airports/');
      if (response is List) {
        _allAirports = List<Map<String, dynamic>>.from(response);
        // Successfully loaded airports from API
        return _allAirports!;
      }
    } catch (e) {
      // Error fetching airports - using fallback
    }

    // Fallback airports
    _allAirports = _getFallbackAirports();
    return _allAirports!;
  }

  /// Search worldwide ports by name, code, or country
  Future<List<Map<String, dynamic>>> searchPorts(String query) async {
    if (query.length < 2) return [];

    final allPorts = await _fetchAllPorts();
    final lowerQuery = query.toLowerCase();

    return allPorts.where((port) {
      final name = (port['name'] ?? '').toString().toLowerCase();
      final code = (port['un_locode'] ?? '').toString().toLowerCase();
      final country = (port['country'] ?? '').toString().toLowerCase();
      return name.contains(lowerQuery) ||
          code.contains(lowerQuery) ||
          country.contains(lowerQuery);
    }).toList();
  }

  /// Search worldwide airports by name, code, or country
  Future<List<Map<String, dynamic>>> searchAirports(String query) async {
    if (query.length < 2) return [];

    final allAirports = await _fetchAllAirports();
    final lowerQuery = query.toLowerCase();

    return allAirports.where((airport) {
      final name = (airport['name'] ?? '').toString().toLowerCase();
      final code = (airport['iata_code'] ?? '').toString().toLowerCase();
      final city = (airport['ciudad_exacta'] ?? '').toString().toLowerCase();
      final country = (airport['country'] ?? '').toString().toLowerCase();
      return name.contains(lowerQuery) ||
          code.contains(lowerQuery) ||
          city.contains(lowerQuery) ||
          country.contains(lowerQuery);
    }).toList();
  }

  /// Get Ecuador ports for POD (destination) selection
  Future<List<Map<String, dynamic>>> getEcuadorPorts() async {
    if (_ecuadorPorts != null) return _ecuadorPorts!;

    final allPorts = await _fetchAllPorts();
    _ecuadorPorts = allPorts.where((port) {
      final country = (port['country'] ?? '').toString().toLowerCase();
      return country.contains('ecuador');
    }).toList();

    // Add fallback Ecuador ports if none found
    if (_ecuadorPorts!.isEmpty) {
      _ecuadorPorts = [
        {
          'un_locode': 'ECGYE',
          'name': 'Guayaquil',
          'country': 'Ecuador',
          'region': 'Latinoamérica'
        },
        {
          'un_locode': 'ECMEC',
          'name': 'Manta',
          'country': 'Ecuador',
          'region': 'Latinoamérica'
        },
        {
          'un_locode': 'ECESM',
          'name': 'Esmeraldas',
          'country': 'Ecuador',
          'region': 'Latinoamérica'
        },
        {
          'un_locode': 'ECPBO',
          'name': 'Puerto Bolívar',
          'country': 'Ecuador',
          'region': 'Latinoamérica'
        },
        {
          'un_locode': 'ECPSJ',
          'name': 'Posorja',
          'country': 'Ecuador',
          'region': 'Latinoamérica'
        },
      ];
    }

    return _ecuadorPorts!;
  }

  /// Get Ecuador airports for POD (destination) selection
  Future<List<Map<String, dynamic>>> getEcuadorAirports() async {
    if (_ecuadorAirports != null) return _ecuadorAirports!;

    final allAirports = await _fetchAllAirports();
    _ecuadorAirports = allAirports.where((airport) {
      final country = (airport['country'] ?? '').toString().toLowerCase();
      return country.contains('ecuador');
    }).toList();

    // Add fallback Ecuador airports if none found
    if (_ecuadorAirports!.isEmpty) {
      _ecuadorAirports = [
        {
          'iata_code': 'GYE',
          'name': 'José Joaquín de Olmedo',
          'ciudad_exacta': 'Guayaquil',
          'country': 'Ecuador'
        },
        {
          'iata_code': 'UIO',
          'name': 'Mariscal Sucre',
          'ciudad_exacta': 'Quito',
          'country': 'Ecuador'
        },
        {
          'iata_code': 'CUE',
          'name': 'Mariscal Lamar',
          'ciudad_exacta': 'Cuenca',
          'country': 'Ecuador'
        },
        {
          'iata_code': 'MEC',
          'name': 'Eloy Alfaro',
          'ciudad_exacta': 'Manta',
          'country': 'Ecuador'
        },
      ];
    }

    return _ecuadorAirports!;
  }

  /// Comprehensive fallback ports including user-reported missing ports
  List<Map<String, dynamic>> _getFallbackPorts() {
    return [
      // --- ASIA ---
      {
        'un_locode': 'CNSHA',
        'name': 'Shanghai',
        'country': 'China',
        'region': 'Asia'
      },
      {
        'un_locode': 'CNNBG',
        'name': 'Ningbo-Zhoushan',
        'country': 'China',
        'region': 'Asia'
      },
      {
        'un_locode': 'CNNGB',
        'name': 'Ningbo',
        'country': 'China',
        'region': 'Asia'
      },
      {
        'un_locode': 'CNSZX',
        'name': 'Shenzhen',
        'country': 'China',
        'region': 'Asia'
      },
      {
        'un_locode': 'CNGGZ',
        'name': 'Guangzhou',
        'country': 'China',
        'region': 'Asia'
      },
      {
        'un_locode': 'CNQGD',
        'name': 'Qingdao',
        'country': 'China',
        'region': 'Asia'
      },
      {
        'un_locode': 'CNTSN',
        'name': 'Tianjin',
        'country': 'China',
        'region': 'Asia'
      },
      {
        'un_locode': 'CNXMN',
        'name': 'Xiamen',
        'country': 'China',
        'region': 'Asia'
      },
      {
        'un_locode': 'CNFOC',
        'name': 'Fuzhou',
        'country': 'China',
        'region': 'Asia'
      },
      {
        'un_locode': 'CNDLC',
        'name': 'Dalian',
        'country': 'China',
        'region': 'Asia'
      },
      {
        'un_locode': 'HKHKG',
        'name': 'Hong Kong',
        'country': 'Hong Kong',
        'region': 'Asia'
      },
      {
        'un_locode': 'SGSIN',
        'name': 'Singapore',
        'country': 'Singapore',
        'region': 'Asia'
      },
      {
        'un_locode': 'KRPUS',
        'name': 'Busan',
        'country': 'South Korea',
        'region': 'Asia'
      },
      {
        'un_locode': 'JPTYO',
        'name': 'Tokyo',
        'country': 'Japan',
        'region': 'Asia'
      },
      {
        'un_locode': 'JPYOK',
        'name': 'Yokohama',
        'country': 'Japan',
        'region': 'Asia'
      },
      {
        'un_locode': 'TWKHH',
        'name': 'Kaohsiung',
        'country': 'Taiwan',
        'region': 'Asia'
      },
      {
        'un_locode': 'MYPKG',
        'name': 'Port Klang',
        'country': 'Malaysia',
        'region': 'Asia'
      },
      {
        'un_locode': 'THLCH',
        'name': 'Laem Chabang',
        'country': 'Thailand',
        'region': 'Asia'
      },
      {
        'un_locode': 'VNSGN',
        'name': 'Ho Chi Minh',
        'country': 'Vietnam',
        'region': 'Asia'
      },
      {
        'un_locode': 'INNSA',
        'name': 'Nhava Sheva',
        'country': 'India',
        'region': 'Asia'
      },
      {
        'un_locode': 'AEJEA',
        'name': 'Jebel Ali',
        'country': 'UAE',
        'region': 'Asia'
      },

      // --- NORTH AMERICA ---
      {
        'un_locode': 'USLAX',
        'name': 'Los Angeles',
        'country': 'USA',
        'region': 'North America'
      },
      {
        'un_locode': 'USLGB',
        'name': 'Long Beach',
        'country': 'USA',
        'region': 'North America'
      },
      {
        'un_locode': 'USNYC',
        'name': 'New York',
        'country': 'USA',
        'region': 'North America'
      },
      {
        'un_locode': 'USSAV',
        'name': 'Savannah',
        'country': 'USA',
        'region': 'North America'
      },
      {
        'un_locode': 'USHOU',
        'name': 'Houston',
        'country': 'USA',
        'region': 'North America'
      },
      {
        'un_locode': 'USSEA',
        'name': 'Seattle',
        'country': 'USA',
        'region': 'North America'
      },
      {
        'un_locode': 'USMIA',
        'name': 'Miami',
        'country': 'USA',
        'region': 'North America'
      },
      {
        'un_locode': 'CAVAN',
        'name': 'Vancouver',
        'country': 'Canada',
        'region': 'North America'
      },
      {
        'un_locode': 'MXZLO',
        'name': 'Manzanillo',
        'country': 'Mexico',
        'region': 'North America'
      },

      // --- EUROPE ---
      {
        'un_locode': 'NLRTM',
        'name': 'Rotterdam',
        'country': 'Netherlands',
        'region': 'Europe'
      },
      {
        'un_locode': 'BEANR',
        'name': 'Antwerp',
        'country': 'Belgium',
        'region': 'Europe'
      },
      {
        'un_locode': 'DEHAM',
        'name': 'Hamburg',
        'country': 'Germany',
        'region': 'Europe'
      },
      {
        'un_locode': 'DEBRV',
        'name': 'Bremerhaven',
        'country': 'Germany',
        'region': 'Europe'
      },
      {
        'un_locode': 'GBFXT',
        'name': 'Felixstowe',
        'country': 'UK',
        'region': 'Europe'
      },
      {
        'un_locode': 'FRLEH',
        'name': 'Le Havre',
        'country': 'France',
        'region': 'Europe'
      },
      {
        'un_locode': 'ESVLC',
        'name': 'Valencia',
        'country': 'Spain',
        'region': 'Europe'
      },
      {
        'un_locode': 'ESALG',
        'name': 'Algeciras',
        'country': 'Spain',
        'region': 'Europe'
      },
      {
        'un_locode': 'ESBCN',
        'name': 'Barcelona',
        'country': 'Spain',
        'region': 'Europe'
      },
      {
        'un_locode': 'ITGOA',
        'name': 'Genoa',
        'country': 'Italy',
        'region': 'Europe'
      },
      {
        'un_locode': 'GRPIR',
        'name': 'Piraeus',
        'country': 'Greece',
        'region': 'Europe'
      },

      // --- LATIN AMERICA ---
      {
        'un_locode': 'PABLB',
        'name': 'Balboa',
        'country': 'Panama',
        'region': 'Latin America'
      },
      {
        'un_locode': 'PAONX',
        'name': 'Colon',
        'country': 'Panama',
        'region': 'Latin America'
      },
      {
        'un_locode': 'BRSSZ',
        'name': 'Santos',
        'country': 'Brazil',
        'region': 'Latin America'
      },
      {
        'un_locode': 'ARBUE',
        'name': 'Buenos Aires',
        'country': 'Argentina',
        'region': 'Latin America'
      },
      {
        'un_locode': 'CLSAI',
        'name': 'San Antonio',
        'country': 'Chile',
        'region': 'Latin America'
      },
      {
        'un_locode': 'CLVAP',
        'name': 'Valparaiso',
        'country': 'Chile',
        'region': 'Latin America'
      },
      {
        'un_locode': 'PECLL',
        'name': 'Callao',
        'country': 'Peru',
        'region': 'Latin America'
      },
      {
        'un_locode': 'COCTG',
        'name': 'Cartagena',
        'country': 'Colombia',
        'region': 'Latin America'
      },
      {
        'un_locode': 'COBUN',
        'name': 'Buenaventura',
        'country': 'Colombia',
        'region': 'Latin America'
      },

      // --- ECUADOR (POD) ---
      {
        'un_locode': 'ECGYE',
        'name': 'Guayaquil',
        'country': 'Ecuador',
        'region': 'Latin America'
      },
      {
        'un_locode': 'ECMEC',
        'name': 'Manta',
        'country': 'Ecuador',
        'region': 'Latin America'
      },
      {
        'un_locode': 'ECESM',
        'name': 'Esmeraldas',
        'country': 'Ecuador',
        'region': 'Latin America'
      },
      {
        'un_locode': 'ECPBO',
        'name': 'Puerto Bolívar',
        'country': 'Ecuador',
        'region': 'Latin America'
      },
      {
        'un_locode': 'ECPSJ',
        'name': 'Posorja',
        'country': 'Ecuador',
        'region': 'Latin America'
      },

      // --- AFRICA/MIDDLE EAST ---
      {
        'un_locode': 'MAPTM',
        'name': 'Tanger Med',
        'country': 'Morocco',
        'region': 'Africa'
      },
      {
        'un_locode': 'EGPSD',
        'name': 'Port Said',
        'country': 'Egypt',
        'region': 'Africa'
      },
      {
        'un_locode': 'ZADUR',
        'name': 'Durban',
        'country': 'South Africa',
        'region': 'Africa'
      },

      // --- OCEANIA ---
      {
        'un_locode': 'AUSYD',
        'name': 'Sydney',
        'country': 'Australia',
        'region': 'Oceania'
      },
      {
        'un_locode': 'AUMEL',
        'name': 'Melbourne',
        'country': 'Australia',
        'region': 'Oceania'
      },
      {
        'un_locode': 'NZAKL',
        'name': 'Auckland',
        'country': 'New Zealand',
        'region': 'Oceania'
      },
    ];
  }

  /// Comprehensive fallback airports
  List<Map<String, dynamic>> _getFallbackAirports() {
    return [
      // --- ASIA ---
      {
        'iata_code': 'PVG',
        'name': 'Pudong International',
        'ciudad_exacta': 'Shanghai',
        'country': 'China'
      },
      {
        'iata_code': 'CAN',
        'name': 'Baiyun International',
        'ciudad_exacta': 'Guangzhou',
        'country': 'China'
      },
      {
        'iata_code': 'SZX',
        'name': 'Bao\'an International',
        'ciudad_exacta': 'Shenzhen',
        'country': 'China'
      },
      {
        'iata_code': 'NGB',
        'name': 'Lishe International',
        'ciudad_exacta': 'Ningbo',
        'country': 'China'
      },
      {
        'iata_code': 'HKG',
        'name': 'Hong Kong International',
        'ciudad_exacta': 'Hong Kong',
        'country': 'Hong Kong'
      },
      {
        'iata_code': 'SIN',
        'name': 'Changi Airport',
        'ciudad_exacta': 'Singapore',
        'country': 'Singapore'
      },
      {
        'iata_code': 'ICN',
        'name': 'Incheon International',
        'ciudad_exacta': 'Seoul',
        'country': 'South Korea'
      },
      {
        'iata_code': 'NRT',
        'name': 'Narita International',
        'ciudad_exacta': 'Tokyo',
        'country': 'Japan'
      },
      {
        'iata_code': 'TPE',
        'name': 'Taoyuan International',
        'ciudad_exacta': 'Taipei',
        'country': 'Taiwan'
      },
      {
        'iata_code': 'BKK',
        'name': 'Suvarnabhumi',
        'ciudad_exacta': 'Bangkok',
        'country': 'Thailand'
      },
      {
        'iata_code': 'DXB',
        'name': 'Dubai International',
        'ciudad_exacta': 'Dubai',
        'country': 'UAE'
      },

      // --- NORTH AMERICA ---
      {
        'iata_code': 'LAX',
        'name': 'Los Angeles International',
        'ciudad_exacta': 'Los Angeles',
        'country': 'USA'
      },
      {
        'iata_code': 'MIA',
        'name': 'Miami International',
        'ciudad_exacta': 'Miami',
        'country': 'USA'
      },
      {
        'iata_code': 'JFK',
        'name': 'John F. Kennedy',
        'ciudad_exacta': 'New York',
        'country': 'USA'
      },
      {
        'iata_code': 'ORD',
        'name': 'O\'Hare International',
        'ciudad_exacta': 'Chicago',
        'country': 'USA'
      },
      {
        'iata_code': 'DFW',
        'name': 'Dallas/Fort Worth',
        'ciudad_exacta': 'Dallas',
        'country': 'USA'
      },
      {
        'iata_code': 'ATL',
        'name': 'Hartsfield-Jackson',
        'ciudad_exacta': 'Atlanta',
        'country': 'USA'
      },

      // --- EUROPE ---
      {
        'iata_code': 'FRA',
        'name': 'Frankfurt Airport',
        'ciudad_exacta': 'Frankfurt',
        'country': 'Germany'
      },
      {
        'iata_code': 'AMS',
        'name': 'Schiphol Airport',
        'ciudad_exacta': 'Amsterdam',
        'country': 'Netherlands'
      },
      {
        'iata_code': 'CDG',
        'name': 'Charles de Gaulle',
        'ciudad_exacta': 'Paris',
        'country': 'France'
      },
      {
        'iata_code': 'LHR',
        'name': 'Heathrow Airport',
        'ciudad_exacta': 'London',
        'country': 'UK'
      },
      {
        'iata_code': 'MAD',
        'name': 'Barajas Airport',
        'ciudad_exacta': 'Madrid',
        'country': 'Spain'
      },
      {
        'iata_code': 'BCN',
        'name': 'El Prat Airport',
        'ciudad_exacta': 'Barcelona',
        'country': 'Spain'
      },

      // --- LATIN AMERICA ---
      {
        'iata_code': 'GYE',
        'name': 'José Joaquín de Olmedo',
        'ciudad_exacta': 'Guayaquil',
        'country': 'Ecuador'
      },
      {
        'iata_code': 'UIO',
        'name': 'Mariscal Sucre',
        'ciudad_exacta': 'Quito',
        'country': 'Ecuador'
      },
      {
        'iata_code': 'CUE',
        'name': 'Mariscal Lamar',
        'ciudad_exacta': 'Cuenca',
        'country': 'Ecuador'
      },
      {
        'iata_code': 'MEC',
        'name': 'Eloy Alfaro',
        'ciudad_exacta': 'Manta',
        'country': 'Ecuador'
      },
      {
        'iata_code': 'LIM',
        'name': 'Jorge Chávez',
        'ciudad_exacta': 'Lima',
        'country': 'Peru'
      },
      {
        'iata_code': 'BOG',
        'name': 'El Dorado',
        'ciudad_exacta': 'Bogota',
        'country': 'Colombia'
      },
      {
        'iata_code': 'PTY',
        'name': 'Tocumen International',
        'ciudad_exacta': 'Panama City',
        'country': 'Panama'
      },
      {
        'iata_code': 'GRU',
        'name': 'Guarulhos',
        'ciudad_exacta': 'Sao Paulo',
        'country': 'Brazil'
      },
      {
        'iata_code': 'EZE',
        'name': 'Ministro Pistarini',
        'ciudad_exacta': 'Buenos Aires',
        'country': 'Argentina'
      },
      {
        'iata_code': 'SCL',
        'name': 'Arturo Merino Benitez',
        'ciudad_exacta': 'Santiago',
        'country': 'Chile'
      },
    ];
  }
}
