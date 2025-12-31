import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../core/api/quote_repository.dart';

class QuoteFormScreen extends StatefulWidget {
  const QuoteFormScreen({super.key});

  @override
  State<QuoteFormScreen> createState() => _QuoteFormScreenState();
}

class _QuoteFormScreenState extends State<QuoteFormScreen> {
  // Services
  final QuoteRepository _repository = QuoteRepository();
  
  // Form Key
  final _formKey = GlobalKey<FormState>();

  // State
  String _transportMode = "FCL"; // FCL, LCL, AIR
  bool _isLoading = false;
  String? _resultMessage;

  // -- FCL Controllers --
  final TextEditingController _fclQtyCtrl = TextEditingController(text: "1");
  final TextEditingController _fclWeightCtrl = TextEditingController(text: "10000"); // per container
  
  // -- LCL Controllers --
  final TextEditingController _lclQtyCtrl = TextEditingController(text: "1");
  final TextEditingController _lclLengthCtrl = TextEditingController();
  final TextEditingController _lclWidthCtrl = TextEditingController();
  final TextEditingController _lclHeightCtrl = TextEditingController();
  final TextEditingController _lclUnitWeightCtrl = TextEditingController();

  // -- Air Controllers --
  final TextEditingController _airGrossWeightCtrl = TextEditingController(text: "1000");

  // -- Common Controllers --
  final TextEditingController _fobController = TextEditingController(text: "15000.00");
  final TextEditingController _commodityController = TextEditingController(text: "Impresora 3d");
  final TextEditingController _originController = TextEditingController(); // POL / AOL
  final TextEditingController _hsCodeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  
  // -- Selection State --
  String _selectedRuc = "1708849037001";
  String _containerType = "20' Standard"; // FCL
  String _packageType = "Caja"; // LCL
  bool _isStackable = true; // LCL
  String _incoterm = "FOB";
  String _originCountry = "China";
  String _cargoType = "Carga General";
  
  // Route
  String _destinationCity = "Guayaquil"; 
  bool _podGuayaquil = true; // FCL/LCL
  bool _podPosorja = false; // FCL/LCL
  String _aodAirport = "José Joaquín de Olmedo, Ecuador"; // Air

  // Services Checkboxes
  bool _serviceCustoms = true;
  bool _serviceInsurance = true;
  bool _serviceTrucking = false;

  // -- LOGIC --

  double _calculateLCLVolume() {
     // simple CBM calc: (L*W*H)/1,000,000 * qty
    double l = double.tryParse(_lclLengthCtrl.text) ?? 0;
    double w = double.tryParse(_lclWidthCtrl.text) ?? 0;
    double h = double.tryParse(_lclHeightCtrl.text) ?? 0;
    int qty = int.tryParse(_lclQtyCtrl.text) ?? 1;
    return (l * w * h / 1000000) * qty;
  }

  double _calculateTotalWeight() {
    if (_transportMode == "FCL") {
       return (double.tryParse(_fclWeightCtrl.text) ?? 0) * (int.tryParse(_fclQtyCtrl.text) ?? 1);
    } else if (_transportMode == "LCL") {
       return (double.tryParse(_lclUnitWeightCtrl.text) ?? 0) * (int.tryParse(_lclQtyCtrl.text) ?? 1);
    } else { // AIR
       return double.tryParse(_airGrossWeightCtrl.text) ?? 0;
    }
  }

  void _calculateQuote() async {
    if (!_formKey.currentState!.validate()) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Complete campos requeridos")));
       return;
    }

    setState(() {
      _isLoading = true;
      _resultMessage = null;
    });

    try {
      double volume = 0;
      double weight = _calculateTotalWeight();

      if (_transportMode == "FCL") {
          // Estimate volume
          int qty = int.tryParse(_fclQtyCtrl.text) ?? 1;
          if (_containerType.contains("20'")) volume = 33.0 * qty;
          else if (_containerType.contains("40' HC")) volume = 76.0 * qty;
          else volume = 67.0 * qty;
      } else if (_transportMode == "LCL") {
         volume = _calculateLCLVolume();
      } else { // AIR
         // Air usually uses chargeable weight, but we pass gross for now to backend
         volume = weight / 167; // approx default vol ratio if needed, or 0
      }

      final result = await _repository.calculateQuote(
        polId: 1, 
        podId: 1, 
        commodity: _commodityController.text,
        weight: weight,
        volume: volume,
        fobValue: double.tryParse(_fobController.text) ?? 0,
      );

      setState(() {
        _resultMessage = "Cotización ${_transportMode}\nCIF: ${result['total_cif'] ?? 'N/A'}\nImpuestos: ${result['total_tax'] ?? 'N/A'}"; 
        _isLoading = false;
      });
      _showResultDialog();

    } catch (e) {
      setState(() { _isLoading = false; });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
    }
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Row(children: [Icon(Icons.check_circle, color: AppColors.neonGreen), SizedBox(width: 8), Text("Cotización Exitosa", style: TextStyle(color: Colors.white))]),
        content: Text(_resultMessage ?? "", style: const TextStyle(color: Colors.white70)),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close Dialog
              Navigator.pop(context); // Go back to Home/Dashboard (Assuming pushed from Dashboard)
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonGreen, foregroundColor: Colors.black),
            child: const Text("ACEPTAR"),
          )
        ],
      ),
    );
  }

  // --- UI ---

  @override
  Widget build(BuildContext context) {
    // Colors
    final primaryColor = const Color(0xFF00Cba9);
    final accentColor = const Color(0xFFA4F40B); // Lime for Checkboxes/Buttons sometimes
    final surfaceColor = AppColors.darkBlueBackground;
    final cardColor = const Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        leading: Builder(builder: (c) => IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(c))),
        title: const Text("Solicitar Cotización", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               // 1. Selector de Transporte (Sticky like but simple row)
               Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   _buildModeButton("Marítimo FCL", "FCL", Icons.directions_boat),
                   const SizedBox(width: 8),
                   _buildModeButton("Marítimo LCL", "LCL", Icons.inventory_2),
                   const SizedBox(width: 8),
                   _buildModeButton("Aéreo", "AIR", Icons.flight),
                 ],
               ),
               const SizedBox(height: 20),

               // Contact & RUC (Common)
               _buildSectionCard(
                 title: "Datos de Contacto", 
                 icon: Icons.person, 
                 child: Column(
                   children: [
                     Row(children: [Expanded(child: _buildReadOnly("Nombre", "Prueba")), const SizedBox(width: 10), Expanded(child: _buildReadOnly("Apellido", "Prueba"))]),
                     const SizedBox(height: 10),
                     _buildReadOnly("Razón Social", "PRUEBA S.A.S."),
                     const SizedBox(height: 10),
                     Row(
                       children: [
                         Radio(value: "1708849037001", groupValue: _selectedRuc, onChanged: (v){}, activeColor: primaryColor),
                         const Text("RUC 1708849037001", style: TextStyle(color: Colors.white)),
                         const Spacer(),
                         const Icon(Icons.check_circle, color: Colors.green, size: 18)
                       ],
                     )
                   ],
                 )
               ),
               const SizedBox(height: 16),

               // Dynamic Configuration Section
               if (_transportMode == "FCL") _buildFCLConfig(),
               if (_transportMode == "LCL") _buildLCLConfig(),
               if (_transportMode == "AIR") _buildAirConfig(),

               const SizedBox(height: 16),

               // Route (Dynamic Labels)
               _buildSectionCard(
                 title: "Ruta y Transporte", 
                 icon: Icons.map,
                 child: Column(
                   children: [
                      // Origin
                      _buildInput(
                        _transportMode == "AIR" ? "AOL Aeropuerto de Origen *" : "POL Puerto de Origen *", 
                        _originController..text = (_originController.text.isEmpty ? (_transportMode == "AIR" ? "Hong Kong Int." : "Shanghai") : _originController.text)
                      ),
                      const SizedBox(height: 12),
                      
                      // Destination
                      const Text("Destino (Ecuador) *", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      if (_transportMode == "AIR")
                         Container(
                           width: double.infinity,
                           padding: const EdgeInsets.all(12),
                           decoration: BoxDecoration(color: const Color(0xFF334155), borderRadius: BorderRadius.circular(8)),
                           child: Text(_aodAirport, style: const TextStyle(color: Colors.white)),
                         )
                      else 
                         Column(
                           children: [
                             CheckboxListTile(
                               value: _podGuayaquil, 
                               onChanged: (v) => setState(() => _podGuayaquil = v!),
                               title: const Text("Guayaquil (GYE)", style: TextStyle(color: Colors.white, fontSize: 14)),
                               contentPadding: EdgeInsets.zero,
                               activeColor: primaryColor,
                               controlAffinity: ListTileControlAffinity.leading,
                             ),
                             CheckboxListTile(
                               value: _podPosorja, 
                               onChanged: (v) => setState(() => _podPosorja = v!),
                               title: const Text("Posorja (POS)", style: TextStyle(color: Colors.white, fontSize: 14)),
                               contentPadding: EdgeInsets.zero,
                               activeColor: primaryColor,
                               controlAffinity: ListTileControlAffinity.leading,
                             ),
                           ],
                         )
                   ],
                 )
               ),
               
               const SizedBox(height: 16),

               // Product Info
               _buildSectionCard(
                 title: "Información del Producto",
                 icon: Icons.inventory,
                 child: Column(
                   children: [
                     _buildInput("Descripción *", _commodityController, lines: 3),
                     const SizedBox(height: 12),
                     Row(
                       children: [
                         Expanded(child: _buildInput("País Origen", TextEditingController(text: _originCountry))),
                         const SizedBox(width: 10),
                         Expanded(child: _buildInput("Valor FOB (USD) *", _fobController, isNumber: true)),
                       ],
                     ),
                     const SizedBox(height: 12),
                     _buildDropdown("Carga Peligrosa?", _cargoType, ["Carga General", "Carga Peligrosa"], (v) => setState(() => _cargoType = v!)),
                   ],
                 )
               ),

               const SizedBox(height: 16),

               // Integral Services
               _buildSectionCard(
                 title: "Servicios Integrales",
                 icon: Icons.add_moderator,
                 child: Column(
                   children: [
                      _buildCheckbox("Agenciamiento Aduanero", _serviceCustoms, (v) => setState(() => _serviceCustoms = v!)),
                      _buildCheckbox("Seguro TODO Riesgo", _serviceInsurance, (v) => setState(() => _serviceInsurance = v!)),
                      _buildCheckbox("Transporte Terrestre", _serviceTrucking, (v) => setState(() => _serviceTrucking = v!)),
                      if (_serviceTrucking)
                        Padding(
                          padding: const EdgeInsets.only(left: 16, top: 10),
                          child: _buildInput("Dirección de Entrega", _addressController),
                        )
                   ],
                 )
               ),

               const SizedBox(height: 30),

               // Submit
               SizedBox(
                 width: double.infinity,
                 height: 55,
                 child: ElevatedButton.icon(
                   onPressed: _isLoading ? null : _calculateQuote,
                   style: ElevatedButton.styleFrom(backgroundColor: accentColor, foregroundColor: Colors.black),
                   icon: _isLoading ? const SizedBox(width:20,height:20,child:CircularProgressIndicator(strokeWidth:2)) : const Icon(Icons.send),
                   label: const Text("SOLICITAR COTIZACIÓN", style: TextStyle(fontWeight: FontWeight.bold)),
                 ),
               ),
               const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildFCLConfig() {
    return _buildSectionCard(
      title: "Configuración FCL",
      icon: Icons.view_in_ar,
      child: Column(
        children: [
          _buildDropdown("Tipo Contenedor", _containerType, ["20' Standard", "40' Standard", "40' HC"], (v) => setState(() => _containerType = v!)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildInput("Cantidad", _fclQtyCtrl, isNumber: true)),
              const SizedBox(width: 10),
              Expanded(child: _buildInput("Peso/Contenedor (KG)", _fclWeightCtrl, isNumber: true)),
            ],
          )
        ],
      )
    );
  }

  Widget _buildLCLConfig() {
    return _buildSectionCard(
      title: "Dimensiones y Peso (LCL)",
      icon: Icons.view_in_ar,
      child: Column(
        children: [
           Row(
             children: [
               Expanded(child: _buildInput("Cant.", _lclQtyCtrl, isNumber: true)),
               const SizedBox(width: 10),
               Expanded(child: _buildDropdown("Tipo", _packageType, ["Caja", "Pallet", "Bulto"], (v) => setState(() => _packageType = v!))),
             ],
           ),
           const SizedBox(height: 12),
           const Text("Medidas (cm)", style: TextStyle(color: Colors.grey, fontSize: 12)),
           Row(
             children: [
               Expanded(child: _buildInput("Largo", _lclLengthCtrl, isNumber: true)),
               const SizedBox(width: 5),
               Expanded(child: _buildInput("Ancho", _lclWidthCtrl, isNumber: true)),
               const SizedBox(width: 5),
               Expanded(child: _buildInput("Alto", _lclHeightCtrl, isNumber: true)),
             ],
           ),
           const SizedBox(height: 12),
           Row(
             children: [
               Expanded(child: _buildInput("Peso Unitario (KG)", _lclUnitWeightCtrl, isNumber: true)),
               const SizedBox(width: 10),
                Expanded(child: _buildDropdown("Apilable?", _isStackable ? "Sí" : "No", ["Sí", "No"], (v) => setState(() => _isStackable = v == "Sí"))),
             ],
           )
        ],
      )
    );
  }

  Widget _buildAirConfig() {
    return _buildSectionCard(
      title: "Carga Aérea",
      icon: Icons.flight_takeoff,
      child: Column(
        children: [
          _buildInput("Peso Bruto Estimado (KG) *", _airGrossWeightCtrl, isNumber: true),
          const SizedBox(height: 10),
          Container(
             padding: const EdgeInsets.all(10),
             decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
             child: const Text("Nota: El peso cobrable será el mayor entre el peso bruto y el peso volumétrico (1:167).", style: TextStyle(color: Colors.blueAccent, fontSize: 11)),
          )
        ],
      )
    );
  }

  // --- HELPERS ---

  Widget _buildSectionCard({required String title, required IconData icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, color: const Color(0xFF00Cba9), size: 18), const SizedBox(width: 8), Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildModeButton(String label, String mode, IconData icon) {
    bool isActive = _transportMode == mode;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _transportMode = mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isActive ? Colors.transparent : Colors.grey.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: isActive ? Colors.black : Colors.grey, size: 20),
              const SizedBox(height: 4),
              Text(label, textAlign: TextAlign.center, style: TextStyle(color: isActive ? Colors.black : Colors.grey, fontWeight: FontWeight.bold, fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController ctrl, {bool isNumber = false, int lines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        const SizedBox(height: 4),
        TextFormField(
          controller: ctrl,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          maxLines: lines,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
             filled: true, fillColor: const Color(0xFF334155),
             border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
             contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
             isDense: true,
          ),
          validator: (v) => v!.isEmpty ? "Req." : null,
        )
      ],
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: const Color(0xFF334155), borderRadius: BorderRadius.circular(8)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items.contains(value) ? value : items.first,
              isExpanded: true,
              dropdownColor: const Color(0xFF334155),
              style: const TextStyle(color: Colors.white, fontSize: 13),
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: onChanged,
            ),
          ),
        )
      ],
    );
  }

  Widget _buildReadOnly(String label, String value) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
       Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)), 
       const SizedBox(height: 2),
       Text(value, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold))
    ]);
  }

  Widget _buildCheckbox(String label, bool val, ValueChanged<bool?> fn) {
    return Row(children: [
      Checkbox(value: val, onChanged: fn, activeColor: const Color(0xFF00Cba9), materialTapTargetSize: MaterialTapTargetSize.shrinkWrap), 
      Text(label, style: const TextStyle(color: Colors.white))
    ]);
  }
}