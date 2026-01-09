class Ciudad {
  final String id;
  final String name; // e.g., Guayaquil
  final String province; // e.g., Guayas
  final String region; // Costa, Sierra, Oriente
  final bool isCapital;
  final String logisticId; // e.g., GYE

  Ciudad({
    required this.id,
    required this.name,
    required this.province,
    required this.region,
    required this.isCapital,
    required this.logisticId,
  });

  factory Ciudad.fromJson(Map<String, dynamic> json, String id) {
    return Ciudad(
      id: id,
      name: json['ciudad'] ?? '',
      province: json['provincia'] ?? '',
      region: json['region'] ?? '',
      isCapital: json['es_capital'] == 'TRUE' || json['es_capital'] == true,
      logisticId: json['id_logistico'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ciudad': name,
      'provincia': province,
      'region': region,
      'es_capital': isCapital,
      'id_logistico': logisticId,
    };
  }
}
