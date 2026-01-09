class HsCode {
  final String id;
  final String code; // 8517.13.00.90
  final String description; // Smartphones
  final String adValorem; // 0%, 15%, Consultar, Mixto
  final String category; // Tecnología, Hogar
  final bool isCommon;
  final String? additionalNotes;

  HsCode({
    required this.id,
    required this.code,
    required this.description,
    required this.adValorem,
    required this.category,
    required this.isCommon,
    this.additionalNotes,
  });

  factory HsCode.fromJson(Map<String, dynamic> json, String id) {
    return HsCode(
      id: id,
      code: json['partida arancelaria'] ?? '',
      description: json['descripcion general'] ?? '',
      adValorem: json['advalorem']?.toString() ?? 'Consultar',
      category: json['categoria'] ?? 'General',
      isCommon: json['es_comun'] == 'TRUE' || json['es_comun'] == true,
      additionalNotes: json['notas_adicionales'],
    );
  }

  // Helper to parse ad-valorem value (handling text like "15%" or "Consultar")
  double? get adValoremValue {
    if (adValorem.contains('%')) {
      final sanitized = adValorem.replaceAll('%', '').trim();
      return double.tryParse(sanitized);
    }
    return null; // For "Consultar", "Mixto", or fixed fees
  }
}
