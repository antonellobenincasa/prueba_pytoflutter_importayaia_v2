class ReglaNegocio {
  final String id;
  final String key;
  final dynamic value;
  final String unit;
  final String description;

  ReglaNegocio({
    required this.id,
    required this.key,
    required this.value,
    required this.unit,
    required this.description,
  });

  factory ReglaNegocio.fromJson(Map<String, dynamic> json, String id) {
    // Handle value type parsing (number vs string)
    dynamic parsedValue = json['valor'];
    if (parsedValue is String) {
      // Try parsing as double if it looks like a number
      if (double.tryParse(parsedValue) != null) {
        parsedValue = double.parse(parsedValue);
      }
    }

    return ReglaNegocio(
      id: id,
      key: json['constante'] ?? json['clave'] ?? '',
      value: parsedValue,
      unit: json['unidad'] ?? '',
      description: json['descripcion'] ?? '',
    );
  }
}
