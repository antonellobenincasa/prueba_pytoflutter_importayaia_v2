class UnidadMedida {
  final String code; // Kg, m3, Unit
  final String name;
  final String type; // Peso, Volumen, Cantidad

  UnidadMedida({
    required this.code,
    required this.name,
    required this.type,
  });

  factory UnidadMedida.fromJson(Map<String, dynamic> json) {
    return UnidadMedida(
      code: json['codigo'] ?? '',
      name: json['nombre'] ?? '',
      type: json['tipo'] ?? '',
    );
  }
}
