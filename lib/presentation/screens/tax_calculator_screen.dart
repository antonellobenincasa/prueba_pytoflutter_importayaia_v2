import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../core/services/master_data_service.dart';
import '../../core/services/calculation_engine.dart';
import '../../core/models/country.dart';
import '../../core/models/hs_code.dart';

class TaxCalculatorScreen extends StatefulWidget {
  const TaxCalculatorScreen({super.key});

  @override
  State<TaxCalculatorScreen> createState() => _TaxCalculatorScreenState();
}

class _TaxCalculatorScreenState extends State<TaxCalculatorScreen> {
  // Services
  final MasterDataService _masterData = MasterDataService();
  final CalculationEngine _calculator = CalculationEngine();

  // Controllers
  final TextEditingController _fobController =
      TextEditingController(text: "12500.00");
  final TextEditingController _freightController =
      TextEditingController(text: "850.00");
  final TextEditingController _weightController =
      TextEditingController(text: "45");

  // State
  Country? _selectedCountry;
  HsCode? _selectedHsCode;
  bool _insuranceEnabled = true;
  bool _isCalculating = false;

  // Results
  TaxResult? _result;

  @override
  void initState() {
    super.initState();
    // Pre-select USA if available
    final countries = _masterData.countries;
    if (countries.isNotEmpty) {
      // Try finding US, otherwise first
      _selectedCountry = countries.firstWhere((c) => c.code == 'US',
          orElse: () => countries.first);
    }
  }

  void _calculateTaxes() {
    setState(() => _isCalculating = true);

    try {
      // 1. Inputs
      final double fob = double.tryParse(_fobController.text) ?? 0;
      final double freight = double.tryParse(_freightController.text) ?? 0;

      // Validation
      if (_selectedHsCode == null) {
        _showError("Por favor seleccione una partida arancelaria válida.");
        setState(() => _isCalculating = false);
        return;
      }

      // 2. Constants from MasterData
      final double ivaRate =
          _masterData.getConstant('iva_rate', defaultValue: 0.15);
      final double fodinfaRate =
          _masterData.getConstant('fodinfa_rate', defaultValue: 0.005);
      final double insuranceRate =
          _masterData.getConstant('insurance_rate', defaultValue: 0.0035);
      final double insuranceMin =
          _masterData.getConstant('insurance_minimum', defaultValue: 70.0);

      // 3. Calculate Insurance Logic
      // Insurance is usually 0.35% of CFR (FOB + Freight), min $70
      double insurance = 0.0;
      if (_insuranceEnabled) {
        double cfr = fob + freight;
        insurance = cfr * insuranceRate;
        if (insurance < insuranceMin) insurance = insuranceMin;
      }

      // 4. Engine Call
      final result = _calculator.calculatePreLiquidation(
        fob: fob,
        freight: freight,
        insurance: insurance,
        hsCode: _selectedHsCode!,
        ivaRate: ivaRate,
        fodinfaRate: fodinfaRate,
        iceRate: 0.0, // ICE logic can be enhanced if HS Code has ICE data
      );

      setState(() {
        _result = result;
        _isCalculating = false;
      });
    } catch (e) {
      _showError("Error en cálculo: $e");
      setState(() => _isCalculating = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Theme Awareness
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryColor = AppColors.neonGreen;
    final surfaceColor = theme.scaffoldBackgroundColor;
    final cardColor = theme.cardColor; // Dynamic
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final textSecondary = isDark ? const Color(0xFFAFBA9C) : Colors.grey[600]!;
    // Border color logic
    final borderOlive =
        isDark ? const Color(0xFF4B543B) : Colors.grey.withAlpha(50);

    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        // Transparentish app bar adaptation
        backgroundColor: surfaceColor.withAlpha(242),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "PRE-LIQUIDACIÓN SENAE",
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 1,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
              color: isDark ? Colors.white10 : Colors.grey.withAlpha(25),
              height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 130),
        child: Column(
          children: [
            // --- SECTION 1: IMPORT DATA ---
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.inventory_2, color: AppColors.neonGreen),
                    const SizedBox(width: 8),
                    Text(
                      "DATOS DE IMPORTACIÓN",
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Valor FOB
                _buildLabel("Valor FOB (USD)", textSecondary),
                _buildCurrencyInput(
                    _fobController, cardColor, borderOlive, textColor),
                const SizedBox(height: 16),

                // Partida Arancelaria (Autocomplete)
                _buildLabel("Partida Arancelaria (Buscar por nombre o código)",
                    textSecondary),
                Autocomplete<HsCode>(
                  displayStringForOption: (HsCode option) =>
                      "${option.code} - ${option.description}",
                  optionsBuilder: (TextEditingValue textEditingValue) async {
                    if (textEditingValue.text.length < 2) {
                      return const Iterable<HsCode>.empty();
                    }
                    return await _masterData
                        .searchHsCodes(textEditingValue.text);
                  },
                  onSelected: (HsCode selection) {
                    setState(() => _selectedHsCode = selection);
                  },
                  fieldViewBuilder:
                      (context, controller, focusNode, onFieldSubmitted) {
                    return Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderOlive),
                      ),
                      child: TextField(
                        controller: controller,
                        focusNode: focusNode,
                        style: TextStyle(color: textColor, fontSize: 14),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          hintText: "Ej: Smartphones, 8517...",
                          hintStyle: TextStyle(
                              color: isDark ? Colors.grey : Colors.grey[400]),
                          suffixIcon: const Icon(Icons.search,
                              color: AppColors.neonGreen),
                        ),
                      ),
                    );
                  },
                  optionsViewBuilder: (context, onSelected, options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        color: cardColor,
                        elevation: 10,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: MediaQuery.of(context).size.width - 32,
                          constraints: const BoxConstraints(maxHeight: 250),
                          child: ListView.separated(
                            padding: EdgeInsets.zero,
                            itemCount: options.length,
                            separatorBuilder: (_, __) => Divider(
                                height: 1,
                                color:
                                    isDark ? Colors.white10 : Colors.grey[200]),
                            itemBuilder: (BuildContext context, int index) {
                              final HsCode option = options.elementAt(index);
                              return ListTile(
                                title: Text(option.description,
                                    style: TextStyle(
                                        color: textColor,
                                        fontWeight: FontWeight.bold)),
                                subtitle: Text(
                                    "HS: ${option.code} • AdVal: ${option.adValorem}",
                                    style: TextStyle(color: textSecondary)),
                                onTap: () => onSelected(option),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
                if (_selectedHsCode != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 4),
                    child: Text(
                      "Seleccionado: ${_selectedHsCode!.code} (${_selectedHsCode!.adValorem})",
                      style: const TextStyle(
                          color: AppColors.neonGreen, fontSize: 12),
                    ),
                  ),

                const SizedBox(height: 16),

                // Country Autocomplete
                _buildLabel("País de Origen", textSecondary),
                Autocomplete<Country>(
                  displayStringForOption: (Country c) => "${c.flag} ${c.name}",
                  initialValue: TextEditingValue(
                      text: _selectedCountry != null
                          ? "${_selectedCountry!.flag} ${_selectedCountry!.name}"
                          : ""),
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return _masterData.countries;
                    }
                    return _masterData.countries.where((Country c) => c.name
                        .toLowerCase()
                        .contains(textEditingValue.text.toLowerCase()));
                  },
                  onSelected: (Country selection) =>
                      setState(() => _selectedCountry = selection),
                  fieldViewBuilder:
                      (context, controller, focusNode, onFieldSubmitted) {
                    return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderOlive),
                        ),
                        child: TextField(
                          controller: controller,
                          focusNode: focusNode,
                          style: TextStyle(color: textColor, fontSize: 16),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Seleccione país",
                            hintStyle: TextStyle(
                                color: isDark ? Colors.grey : Colors.grey[400]),
                            icon: const Icon(Icons.public,
                                color: AppColors.neonGreen),
                          ),
                        ));
                  },
                  optionsViewBuilder: (context, onSelected, options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        color: cardColor,
                        elevation: 10,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: MediaQuery.of(context).size.width - 32,
                          constraints: const BoxConstraints(maxHeight: 250),
                          child: ListView.separated(
                            padding: EdgeInsets.zero,
                            itemCount: options.length,
                            separatorBuilder: (_, __) => Divider(
                                height: 1,
                                color:
                                    isDark ? Colors.white10 : Colors.grey[200]),
                            itemBuilder: (BuildContext context, int index) {
                              final Country option = options.elementAt(index);
                              return ListTile(
                                leading: Text(option.flag,
                                    style: const TextStyle(fontSize: 20)),
                                title: Text(option.name,
                                    style: TextStyle(color: textColor)),
                                onTap: () => onSelected(option),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),
            Container(height: 1, color: borderOlive.withAlpha(128)),
            const SizedBox(height: 24),

            // --- SECTION 2: LOGISTICS ---
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.local_shipping,
                        color: AppColors.neonGreen),
                    const SizedBox(width: 8),
                    Text(
                      "LOGÍSTICA Y SEGURO",
                      style: TextStyle(
                        color: textColor,
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
                          _buildCurrencyInput(_freightController, cardColor,
                              borderOlive, textColor),
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
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "0.00",
                                      hintStyle: TextStyle(
                                          color: isDark
                                              ? Colors.grey
                                              : Colors.grey[400]),
                                    ),
                                  ),
                                ),
                                Text("kg",
                                    style: TextStyle(
                                        color: textSecondary, fontSize: 14)),
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
                    border: Border.all(color: borderOlive.withAlpha(128)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Seguro Internacional",
                              style: TextStyle(
                                color: textColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '0.35% del CFR (mínimo \$70 USD)',
                              style:
                                  TextStyle(color: textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _insuranceEnabled,
                        onChanged: (v) => setState(() => _insuranceEnabled = v),
                        activeThumbColor: primaryColor,
                        activeTrackColor:
                            isDark ? Colors.white10 : Colors.grey[300],
                        inactiveThumbColor: isDark ? Colors.white : Colors.grey,
                        inactiveTrackColor:
                            isDark ? Colors.white10 : Colors.grey[200],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // --- SECTION 3: RESULTS ---
            if (_result != null)
              FadeInUp(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        cardColor,
                        isDark ? const Color(0xFF161912) : Colors.grey[100]!
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderOlive.withAlpha(153)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(102),
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
                          Text(
                            "LIQUIDACIÓN SENAE",
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.yellow.withAlpha(51),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                  color: Colors.yellow.withAlpha(77)),
                            ),
                            child: const Text(
                              "ESTIMADO",
                              style: TextStyle(
                                  color: Colors.yellow,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Details (CIF)
                      _buildResultRow("CIF (Base Imponible)", _result!.cif,
                          isBold: true,
                          textColor: textColor,
                          textSecondary: textSecondary),
                      Divider(
                          color: isDark ? Colors.white10 : Colors.grey[300],
                          height: 16),
                      // Taxes
                      _buildResultRow(
                          "Ad Valorem (${_selectedHsCode?.adValorem ?? '?'})",
                          _result!.adValorem,
                          textColor: textColor,
                          textSecondary: textSecondary),
                      _buildResultRow("FODINFA", _result!.fodinfa,
                          textColor: textColor, textSecondary: textSecondary),
                      if (_result!.ice > 0)
                        _buildResultRow("ICE", _result!.ice,
                            textColor: textColor, textSecondary: textSecondary),
                      _buildResultRow("IVA (15%)", _result!.iva,
                          textColor: textColor, textSecondary: textSecondary),

                      Divider(
                          color: isDark ? Colors.white10 : Colors.grey[300],
                          height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "Total Tributos",
                            style: TextStyle(
                                color: textColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w500),
                          ),
                          Text(
                            "\$${_result!.totalTaxes.toStringAsFixed(2)}",
                            style: const TextStyle(
                              color: AppColors.neonGreen,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "Costo Total Importación: \$${_result!.totalImportCost.toStringAsFixed(2)}",
                          style: TextStyle(color: textSecondary, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomSheet: Container(
        color: surfaceColor.withAlpha(204),
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: _isCalculating ? null : _calculateTaxes,
            icon: _isCalculating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.black))
                : const Icon(Icons.calculate),
            label: Text(
              _isCalculating ? "CALCULANDO..." : "CALCULAR LIQUIDACIÓN",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.black,
              elevation: 10,
              shadowColor: primaryColor.withAlpha(102),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
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
        style:
            TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildCurrencyInput(TextEditingController controller, Color cardColor,
      Color borderColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          const Text("\$",
              style: TextStyle(color: Color(0xFFAFBA9C), fontSize: 18)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: TextStyle(
                  color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "0.00",
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, double val,
      {bool isBold = false,
      required Color textColor,
      required Color textSecondary}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isBold ? textColor : textSecondary, // Adapted
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            "\$${val.toStringAsFixed(2)}",
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
