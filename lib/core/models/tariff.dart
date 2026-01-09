// Base class if needed later, currently separate for clarity
class TarifaFCL {
  final String id;
  final String originPort;
  final String destinationPort;
  final String carrier; // Naviera
  final double rate20;
  final double rate40;
  final double rate40HC;
  final String validity; // Valid until

  TarifaFCL({
    required this.id,
    required this.originPort,
    required this.destinationPort,
    required this.carrier,
    required this.rate20,
    required this.rate40,
    required this.rate40HC,
    required this.validity,
  });

  factory TarifaFCL.fromJson(Map<String, dynamic> json, String id) {
    return TarifaFCL(
      id: id,
      originPort: json['pol'] ?? '',
      destinationPort: json['pod'] ?? '',
      carrier: json['shipping_line'] ?? '',
      rate20: double.tryParse(json['20gp']?.toString() ?? '0') ?? 0.0,
      rate40: double.tryParse(json['40gp']?.toString() ?? '0') ?? 0.0,
      rate40HC: double.tryParse(json['40hc']?.toString() ?? '0') ?? 0.0,
      validity: json['validity'] ?? '',
    );
  }
}

class TarifaLCL {
  final String id;
  final String originPort;
  final String destinationPort;
  final double minimum;
  final double rateTonM3; // W/M rate
  final String transitTime;

  TarifaLCL({
    required this.id,
    required this.originPort,
    required this.destinationPort,
    required this.minimum,
    required this.rateTonM3,
    required this.transitTime,
  });

  factory TarifaLCL.fromJson(Map<String, dynamic> json, String id) {
    return TarifaLCL(
      id: id,
      originPort: json['pol'] ?? '',
      destinationPort: json['pod'] ?? '',
      minimum: double.tryParse(json['minimo']?.toString() ?? '0') ?? 0.0,
      rateTonM3: double.tryParse(json['tarifa_w_m']?.toString() ?? '0') ?? 0.0,
      transitTime: json['tt_dias'] ?? '',
    );
  }
}

class TarifaAerea {
  final String id;
  final String originAirport; // IATA code
  final String destinationAirport; // IATA code
  final double minimum;
  final double rate45;
  final double rate100;
  final double rate300;
  final double rate500;
  final double rate1000;

  TarifaAerea({
    required this.id,
    required this.originAirport,
    required this.destinationAirport,
    required this.minimum,
    required this.rate45,
    required this.rate100,
    required this.rate300,
    required this.rate500,
    required this.rate1000,
  });

  factory TarifaAerea.fromJson(Map<String, dynamic> json, String id) {
    return TarifaAerea(
      id: id,
      originAirport: json['origen_iata'] ?? '',
      destinationAirport: json['destino_iata'] ?? '',
      minimum: double.tryParse(json['minimo']?.toString() ?? '0') ?? 0.0,
      rate45: double.tryParse(json['45kg']?.toString() ?? '0') ?? 0.0,
      rate100: double.tryParse(json['100kg']?.toString() ?? '0') ?? 0.0,
      rate300: double.tryParse(json['300kg']?.toString() ?? '0') ?? 0.0,
      rate500: double.tryParse(json['500kg']?.toString() ?? '0') ?? 0.0,
      rate1000: double.tryParse(json['1000kg']?.toString() ?? '0') ?? 0.0,
    );
  }
}
