class Country {
  final String code; // ISO Code e.g., US
  final String name; // e.g., Estados Unidos
  final String region;
  final String flag; // Emoji flag
  final int prioridad;

  Country({
    required this.code,
    required this.name,
    this.region = '',
    this.flag = '',
    this.prioridad = 99,
  });

  // Getter alias for compatibility with new code expecting 'nombre'
  String get nombre => name;

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      code: json['code'] ?? json['codigo'] ?? '',
      name: json['name'] ?? json['nombre'] ?? '',
      region: json['region'] ?? '',
      flag: json['flag'] ?? '',
      prioridad: json['prioridad'] is int ? json['prioridad'] : 99,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'region': region,
      'flag': flag,
      'prioridad': prioridad,
    };
  }
}
