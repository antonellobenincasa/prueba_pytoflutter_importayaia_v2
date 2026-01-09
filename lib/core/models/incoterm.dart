class Incoterm {
  final String code; // EXW, FOB, CIF
  final String name; // Ex Works, Free on Board
  final String description;
  final bool insuranceIncluded;
  final bool freightIncluded;

  Incoterm({
    required this.code,
    required this.name,
    required this.description,
    required this.insuranceIncluded,
    required this.freightIncluded,
  });

  factory Incoterm.fromJson(Map<String, dynamic> json) {
    return Incoterm(
      code: json['codigo'] ?? '',
      name: json['nombre'] ?? '',
      description: json['descripcion'] ?? '',
      insuranceIncluded: json['seguro_incluido'] == true,
      freightIncluded: json['flete_incluido'] == true,
    );
  }
}
