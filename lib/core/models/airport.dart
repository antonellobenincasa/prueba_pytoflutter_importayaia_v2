class Airport {
  final String id;
  final String iataCode; // e.g., MIA
  final String name; // e.g., Miami International Airport
  final String country; // e.g., Estados Unidos
  final String city; // e.g., Miami

  Airport({
    required this.id,
    required this.iataCode,
    required this.name,
    required this.country,
    required this.city,
  });

  factory Airport.fromJson(Map<String, dynamic> json, String id) {
    return Airport(
      id: id,
      iataCode: json['codigo_iata'] ?? '',
      name: json['aeropuerto'] ?? '',
      country: json['pais'] ?? '',
      city: json['ciudad'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codigo_iata': iataCode,
      'aeropuerto': name,
      'pais': country,
      'ciudad': city,
    };
  }
}
