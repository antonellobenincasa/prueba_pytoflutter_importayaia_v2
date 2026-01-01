import 'package:flutter/material.dart';
import '../../config/theme.dart';
import 'quote_detail_screen.dart';

class QuoteFormScreen extends StatefulWidget {
  const QuoteFormScreen({super.key});

  @override
  State<QuoteFormScreen> createState() => _QuoteFormScreenState();
}

class _QuoteFormScreenState extends State<QuoteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nueva Cotización"),
        backgroundColor: AppColors.darkBlueBackground,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Detalles de la Carga",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              _buildTextField(
                  "Puerto de Origen", Icons.flight_takeoff, _originController),
              const SizedBox(height: 16),
              _buildTextField(
                  "Puerto de Destino", Icons.flight_land, _destController),
              const SizedBox(height: 16),
              _buildTextField(
                  "Peso Estimado (kg)", Icons.scale, _weightController,
                  isNumber: true),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Navegar al detalle (simulado)
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const QuoteDetailScreen(quoteId: "COT-NUEVA-123"),
                        ));
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.neonGreen,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16))),
                  child: const Text("Calcular Cotización",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, IconData icon, TextEditingController controller,
      {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10)),
          child: TextField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
                prefixIcon: Icon(icon, color: AppColors.neonGreen),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
          ),
        ),
      ],
    );
  }
}
