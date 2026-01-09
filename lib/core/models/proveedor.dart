class Proveedor {
  final String id;
  final String name;
  final String type; // Naviera, Consolidadora, Aerolinea
  final String country;

  Proveedor({
    required this.id,
    required this.name,
    required this.type,
    required this.country,
  });

  factory Proveedor.fromJson(Map<String, dynamic> json, String id) {
    return Proveedor(
      id: id,
      name: json['nombre'] ?? '',
      type: json['tipo_servicio'] ?? '', // Based on proveedores.json structure
      country: json['pais'] ?? '',
    );
  }
}
