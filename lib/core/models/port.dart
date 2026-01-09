class Port {
  final String id;
  final String code; // UN/LOCODE e.g., CNSHA
  final String name; // e.g., Shanghai
  final String country; // e.g., China
  final String countryCode; // e.g., CN
  final String? tier;

  Port({
    required this.id,
    required this.code,
    required this.name,
    required this.country,
    required this.countryCode,
    this.tier,
  });

  factory Port.fromJson(Map<String, dynamic> json, String id) {
    return Port(
      id: id,
      code: json['codigo'] ?? '',
      name: json['puerto'] ?? '',
      country: json['pais'] ?? '',
      countryCode: json['pais_codigo'] ?? '',
      tier: json['tier'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codigo': code,
      'puerto': name,
      'pais': country,
      'pais_codigo': countryCode,
      if (tier != null) 'tier': tier,
    };
  }
}
