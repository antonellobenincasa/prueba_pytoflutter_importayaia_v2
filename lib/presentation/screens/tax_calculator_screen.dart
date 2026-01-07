import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../core/services/firebase_service.dart';

class TaxCalculatorScreen extends StatefulWidget {
  const TaxCalculatorScreen({super.key});

  @override
  State<TaxCalculatorScreen> createState() => _TaxCalculatorScreenState();
}

class _TaxCalculatorScreenState extends State<TaxCalculatorScreen> {
  // Firebase Service
  final FirebaseService _firebaseService = FirebaseService();

  // Controllers
  final TextEditingController _fobController = TextEditingController(
    text: "12500.00",
  );
  final TextEditingController _hsCodeController = TextEditingController(
    text: "8517.13.00",
  );
  final TextEditingController _freightController = TextEditingController(
    text: "850.00",
  );
  final TextEditingController _weightController = TextEditingController(
    text: "45",
  );

  // --- STATE ---
  String _originCountry = "US";
  bool _insuranceEnabled = true;
  bool _isCalculating = false;

  // Backend Response Values
  double _cifValue = 0.0;
  double _insuranceCost = 0.0;
  double _adValorem = 0.0;
  double _fodinfa = 0.0;
  double _iceTax = 0.0;
  final double _iceRate = 0.0;
  double _iva = 0.0;
  double _total = 0.0;

  /// Calculate taxes using local calculation or Firebase
  /// Performs pre-liquidation calculation
  Future<void> _calculateFromBackend() async {
    setState(() {
      _isCalculating = true;
    });

    try {
      // 1. Get input values
      final double fobValue = double.tryParse(_fobController.text) ?? 0;
      final double freightValue = double.tryParse(_freightController.text) ?? 0;
      final String hsCode = _hsCodeController.text.trim();

      // Calculate insurance locally (0.35% of CFR, min $70)
      final double cfr = fobValue + freightValue;
      double insuranceValue = 0.0;
      if (_insuranceEnabled) {
        insuranceValue = cfr * 0.0035;
        if (insuranceValue < 70.0) insuranceValue = 70.0;
      }

      // 2. Use Firebase service for calculation
      final result = await _firebaseService.calculatePreLiquidation({
        'fob_value': fobValue,
        'freight_cost': freightValue,
        'insurance': insuranceValue,
        'hs_code': hsCode,
      });

      // 3. Update state with results
      if (mounted) {
        setState(() {
          _cifValue = result['cif'] ?? 0.0;
          _insuranceCost = insuranceValue;
          _adValorem = 0.0; // Will be calculated based on HS code
          _fodinfa = _cifValue * 0.005; // 0.5% of CIF
          _iceTax = 0.0;
          _iva = (_cifValue + _adValorem + _fodinfa) * 0.12; // 12% IVA
          _total = _adValorem + _fodinfa + _iva + _iceTax;

          _isCalculating = false;
        });
      }
    } catch (e) {
      // Error calculating taxes
      if (mounted) {
        setState(() {
          _isCalculating = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error en el cálculo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = AppColors.neonGreen; // #a2f40b
    const surfaceColor = Color(0xFF1C2210); // background-dark
    const cardColor = Color(0xFF232917); // surface-dark
    const textSecondary = Color(0xFFAFBA9C);
    const borderOlive = Color(0xFF4B543B);

    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        backgroundColor: surfaceColor.withValues(alpha: 0.95),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "PRE-LIQUIDACIÓN",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 1,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.white10, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          16,
          24,
          16,
          130,
        ), // Bottom space for fixed button
        child: Column(
          children: [
            // Section 1: Import Data
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.inventory_2, color: primaryColor),
                    SizedBox(width: 8),
                    Text(
                      "DATOS DE IMPORTACIÓN",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // FOB
                _buildLabel("Valor FOB (USD)", textSecondary),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderOlive),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        "\$",
                        style: TextStyle(color: textSecondary, fontSize: 18),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _fobController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "0.00",
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // HS Code
                _buildLabel("Partida Arancelaria", textSecondary),
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderOlive),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _hsCodeController,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            hintText: "Ej: 8517.13.00",
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                      Container(
                        height: 56,
                        width: 56,
                        decoration: const BoxDecoration(
                          border: Border(left: BorderSide(color: borderOlive)),
                        ),
                        child: const Icon(Icons.search, color: primaryColor),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 4, top: 4),
                  child: Text(
                    "Smartphones y dispositivos móviles",
                    style: TextStyle(color: textSecondary, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 16),

                // Origin
                _buildLabel("País de Origen", textSecondary),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderOlive),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _originCountry,
                      isExpanded: true,
                      dropdownColor: cardColor,
                      icon: const Icon(Icons.expand_more, color: primaryColor),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      items: const [
                        DropdownMenuItem(
                          value: "US",
                          child: Text("Estados Unidos (USA)"),
                        ),
                        DropdownMenuItem(value: "CN", child: Text("China")),
                        DropdownMenuItem(
                          value: "EU",
                          child: Text("Unión Europea"),
                        ),
                        DropdownMenuItem(value: "CO", child: Text("Colombia")),
                      ],
                      onChanged: (v) => setState(() => _originCountry = v!),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            Container(height: 1, color: borderOlive.withValues(alpha: 0.5)),
            const SizedBox(height: 24),

            // Section 2: Logistics
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.local_shipping, color: primaryColor),
                    SizedBox(width: 8),
                    Text(
                      "LOGÍSTICA Y SEGURO",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Flete Estimado", textSecondary),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: borderOlive),
                            ),
                            child: Row(
                              children: [
                                const Text(
                                  "\$",
                                  style: TextStyle(
                                    color: textSecondary,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: TextField(
                                    controller: _freightController,
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "0.00",
                                      hintStyle: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Peso (Kg)", textSecondary),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: borderOlive),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _weightController,
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "0.00",
                                      hintStyle: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                ),
                                const Text(
                                  "kg",
                                  style: TextStyle(
                                    color: textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Insurance Toggle
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: borderOlive.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Seguro Internacional",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '0.35% del CFR (mínimo \$70 USD)',
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: _insuranceEnabled,
                        onChanged: (v) => setState(() => _insuranceEnabled = v),
                        activeThumbColor: primaryColor,
                        activeTrackColor: Colors.white10,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: Colors.white10,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Section 3: Results
            FadeInUp(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [cardColor, Color(0xFF161912)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderOlive.withValues(alpha: 0.6)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "ESTIMACIÓN TOTAL",
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.yellow.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: Colors.yellow.withValues(alpha: 0.3),
                            ),
                          ),
                          child: const Text(
                            "REFERENCIAL",
                            style: TextStyle(
                              color: Colors.yellow,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Seguro Internacional (informativo)
                    _buildResultRow("Seguro Internacional", _insuranceCost),
                    const Divider(color: Colors.white10, height: 16),
                    // Tributos
                    _buildResultRow("Ad Valorem (0%)", _adValorem),
                    _buildResultRow("FODINFA (0.5%)", _fodinfa),
                    // ICE solo se muestra si aplica
                    if (_iceTax > 0)
                      _buildResultRow(
                        "ICE (${(_iceRate * 100).toStringAsFixed(0)}%)",
                        _iceTax,
                      ),
                    _buildResultRow("IVA (15%)", _iva),
                    const Divider(color: Colors.white10, height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          "Total a Pagar",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "\$${_total.toStringAsFixed(2)}",
                          style: const TextStyle(
                            color: primaryColor,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        color: surfaceColor.withValues(alpha: 0.8),
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: _isCalculating ? null : _calculateFromBackend,
            icon: _isCalculating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  )
                : const Icon(Icons.calculate),
            label: Text(
              _isCalculating ? "CALCULANDO..." : "CALCULAR IMPUESTOS",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.black,
              elevation: 10,
              shadowColor: primaryColor.withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, double val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          Text(
            "\$${val.toStringAsFixed(2)}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
