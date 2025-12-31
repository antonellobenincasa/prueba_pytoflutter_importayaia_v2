import 'package:flutter/material.dart';
import '../../config/theme.dart';
import 'package:animate_do/animate_do.dart';

class CostSimulatorScreen extends StatefulWidget {
  const CostSimulatorScreen({super.key});

  @override
  State<CostSimulatorScreen> createState() => _CostSimulatorScreenState();
}

class _CostSimulatorScreenState extends State<CostSimulatorScreen> {
  bool _isFCL = true;

  // Controllers
  final TextEditingController _fobController = TextEditingController();
  final TextEditingController _freightController = TextEditingController();
  final TextEditingController _productController = TextEditingController();
  final TextEditingController _hsCodeController = TextEditingController();
  final TextEditingController _adValoremController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController(text: "1");

  // Selection
  String _containerType = "20R"; // 20R, 40R, 40HC, 40NOR
  String _incoterm = "FOB";
  bool _includeISD = false;
  
  // Results
  double _totalCost = 0.0;

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFA2F40B); // Neon Green for FCL
    const primaryBlue = Color(0xFF197FE6); // Blue for LCL logic if we wanted distinct, but sticking to main theme is better.
    // However, HTML LCL uses Blue "primary": "#197fe6". User might prefer consistency or distinct.
    // User request says "update... distinct screens". 
    // I will use dynamic primary color.
    
    final activeColor = _isFCL ? primaryColor : primaryBlue;
    final bgDark = const Color(0xFF101622);
    final surfaceDark = const Color(0xFF1C222E);
    final surfaceHighlight = const Color(0xFF252B3B);

    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        child: Column(
          children: [
            // AppBar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.white10))
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   _buildCircleBtn(Icons.arrow_back, () => Navigator.pop(context), activeColor),
                   Column(
                     children: [
                       const Text("AduanaExpertoIA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                       Text("ImportaYA.ia", style: TextStyle(color: activeColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                     ],
                   ),
                   _buildCircleBtn(Icons.more_vert, (){}, activeColor),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Simulador Costos", style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                    Text(
                      _isFCL ? "Calcula impuestos para carga marítima FCL." : "Cálculo optimizado para carga suelta LCL.", 
                      style: const TextStyle(color: Colors.grey, fontSize: 14)
                    ),
                    const SizedBox(height: 20),

                    // Toggle FCL/LCL
                    Container(
                      height: 48,
                      decoration: BoxDecoration(color: surfaceHighlight, borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          Expanded(child: _buildToggleItem("FCL (Contenedor)", true, activeColor)),
                          Expanded(child: _buildToggleItem("LCL (Suelta)", false, activeColor)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // FCL Specific: Container Config
                    if (_isFCL) ...[
                      FadeInDown(
                        child: _buildCard(surfaceDark, surfaceHighlight, activeColor, [
                          _buildCardTitle(Icons.local_shipping, "Configuración de Carga", activeColor),
                          const SizedBox(height: 16),
                          const Text("Tipo de Contenedor", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: ["20R", "40R", "40HC", "40NOR"].map((type) => 
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: _buildChoiceChip(type, _containerType == type, activeColor, () => setState(() => _containerType = type)),
                                )
                              ).toList(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text("Cantidad de Contenedores", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          _buildCounterInput(activeColor, surfaceHighlight)
                        ]),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Financials (Shared but adaptable)
                    _buildCard(surfaceDark, surfaceHighlight, activeColor, [
                      _buildCardTitle(Icons.payments, "Valores de Importación", activeColor),
                      const SizedBox(height: 16),
                      _buildLabel("Incoterm"),
                      _buildDropdown(["FOB", "CIF", "EXW", "DDP"], surfaceHighlight, activeColor),
                      const SizedBox(height: 4),
                      Text("Término de comercio internacional acordado.", style: TextStyle(color: activeColor.withOpacity(0.7), fontSize: 10)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildCurrencyInput("Valor FOB", _fobController, surfaceHighlight, activeColor)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildCurrencyInput("Flete", _freightController, surfaceHighlight, activeColor)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildCheckbox("Incluir Impuesto ISD (5%)", _includeISD, (v) => setState(() => _includeISD = v!), activeColor, surfaceHighlight),
                    ]),

                    const SizedBox(height: 16),

                    // Tariff Classification
                    _buildCard(surfaceDark, surfaceHighlight, activeColor, [
                      _buildCardTitle(Icons.category, "Clasificación Arancelaria", activeColor),
                      const SizedBox(height: 16),
                      _buildLabel("Producto"),
                      _buildTextInput("Ej: Zapatillas deportivas", _productController, surfaceHighlight, activeColor),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(flex: 3, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                             _buildLabel("Código HS"),
                             _buildTextInput("8517.12...", _hsCodeController, surfaceHighlight, activeColor)
                          ])),
                          const SizedBox(width: 16),
                          Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                             _buildLabel("Ad-Valorem"),
                             _buildTextInput("0", _adValoremController, surfaceHighlight, activeColor, suffix: "%", textAlign: TextAlign.right)
                          ])),
                        ],
                      )
                    ]),
                    
                    const SizedBox(height: 100), // Space for footer
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: bgDark.withOpacity(0.95), border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05)))),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
             onPressed: (){},
             style: ElevatedButton.styleFrom(backgroundColor: activeColor, foregroundColor: _isFCL ? Colors.black : Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
             icon: const Icon(Icons.calculate),
             label: const Text("Calcular Costos", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleItem(String label, bool isFCLOption, Color activeColor) {
    bool selected = isFCLOption == _isFCL;
    return GestureDetector(
      onTap: () => setState(() => _isFCL = isFCLOption),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? Colors.white : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? activeColor : Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 12
          ),
        ),
      ),
    );
  }

  Widget _buildCard(Color bg, Color border, Color accent, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _buildCardTitle(IconData icon, String text, Color color) {
    return Row(children: [Icon(icon, color: color, size: 20), const SizedBox(width: 8), Text(text, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))]);
  }

  Widget _buildCircleBtn(IconData icon, VoidCallback onTap, Color color) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.05)),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }

  Widget _buildChoiceChip(String label, bool selected, Color color, VoidCallback onSelect) {
    return GestureDetector(
      onTap: onSelect,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.1) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? color : Colors.transparent)
        ),
        child: Text(label, style: TextStyle(color: selected ? color : Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
      ),
    );
  }

  Widget _buildCounterInput(Color color, Color bg) {
    return Container(
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.remove, color: Colors.grey), onPressed: (){}),
          Expanded(child: TextField(controller: _quantityController, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), decoration: const InputDecoration(border: InputBorder.none))),
          IconButton(icon: const Icon(Icons.add, color: Colors.grey), onPressed: (){}),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(text, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)));

  Widget _buildDropdown(List<String> items, Color bg, Color activeColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.1))),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _incoterm,
          dropdownColor: bg,
          isExpanded: true,
          icon: const Icon(Icons.expand_more, color: Colors.grey),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (v) => setState(() => _incoterm = v!),
        ),
      ),
    );
  }

  Widget _buildCurrencyInput(String label, TextEditingController ctrl, Color bg, Color activeColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        Stack(
          alignment: Alignment.centerLeft,
          children: [
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true, fillColor: bg,
                contentPadding: const EdgeInsets.only(left: 32, right: 12, top: 12, bottom: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.transparent)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: activeColor)),
              ),
            ),
            const Positioned(left: 12, child: Text("\$", style: TextStyle(color: Colors.grey)))
          ],
        )
      ],
    );
  }

  Widget _buildTextInput(String hint, TextEditingController ctrl, Color bg, Color activeColor, {String? suffix, TextAlign textAlign = TextAlign.start}) {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        TextField(
          controller: ctrl,
          textAlign: textAlign,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true, fillColor: bg, hintText: hint, hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
            contentPadding: EdgeInsets.only(left: 12, right: suffix != null ? 32 : 12, top: 12, bottom: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.transparent)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: activeColor)),
          ),
        ),
        if (suffix != null) Positioned(right: 12, child: Text(suffix, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)))
      ],
    );
  }

  Widget _buildCheckbox(String label, bool value, Function(bool?) onChanged, Color activeColor, Color bg) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: bg.withOpacity(0.5), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.transparent)),
        child: Row(
          children: [
            Container(
              width: 20, height: 20,
              decoration: BoxDecoration(
                color: value ? activeColor : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: value ? activeColor : Colors.grey)
              ),
              child: value ? const Icon(Icons.check, size: 16, color: Colors.black) : null,
            ),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
