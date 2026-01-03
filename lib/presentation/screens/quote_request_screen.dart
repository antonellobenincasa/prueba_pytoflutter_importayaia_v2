import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../config/theme.dart';
import '../../core/api/client.dart';
import '../widgets/neon_card.dart';
import '../widgets/port_autocomplete_field.dart';

class QuoteRequestScreen extends StatefulWidget {
  const QuoteRequestScreen({super.key});

  @override
  State<QuoteRequestScreen> createState() => _QuoteRequestScreenState();
}

class _QuoteRequestScreenState extends State<QuoteRequestScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiClient _apiClient = ApiClient();

  // -- Shared Controllers --
  final TextEditingController _fobController = TextEditingController();
  final TextEditingController _productController = TextEditingController();
  final TextEditingController _hsCodeController = TextEditingController();
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController =
      TextEditingController(text: "Guayaquil");

  // -- FCL Specific --
  String _selectedContainerType = "20GP";
  int _containerQuantity = 1;
  List<Map<String, dynamic>> _containerTypes = [];
  bool _isLoadingContainers = true;

  // -- LCL Specific: Dynamic Bultos List --
  final List<Map<String, TextEditingController>> _bultosList = [];

  // -- LCL Manual Mode --
  bool _lclManualMode = false; // Toggle between bultos detail and manual input
  final TextEditingController _lclPiecesController = TextEditingController();
  final TextEditingController _lclTotalCbmController = TextEditingController();
  final TextEditingController _lclTotalWeightController =
      TextEditingController();

  // -- Air Specific --
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _volumeController = TextEditingController();

  // -- Shared State --
  String _incoterm = "FOB";
  bool _includeInsurance = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _addBulto(); // Start with one bulto for LCL
    _fetchContainerTypes();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    // Rebuild to update port/airport labels and behavior
    setState(() {
      // Clear origin when switching between maritime and air modes
      final wasAirMode = _tabController.previousIndex == 2;
      final isAirMode = _tabController.index == 2;
      if (wasAirMode != isAirMode) {
        _originController.clear();
      }
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _fobController.dispose();
    // _freightController removed - backend calculates freight
    _productController.dispose();
    _hsCodeController.dispose();
    _originController.dispose();
    _destinationController.dispose();
    _weightController.dispose();
    _volumeController.dispose();
    // LCL Manual Mode controllers
    _lclPiecesController.dispose();
    _lclTotalCbmController.dispose();
    _lclTotalWeightController.dispose();
    for (var bulto in _bultosList) {
      bulto['length']?.dispose();
      bulto['width']?.dispose();
      bulto['height']?.dispose();
      bulto['weight']?.dispose();
    }
    super.dispose();
  }

  /// Fetch container types from backend
  Future<void> _fetchContainerTypes() async {
    try {
      final response = await _apiClient.get('sales/containers/');
      if (mounted) {
        setState(() {
          _containerTypes = List<Map<String, dynamic>>.from(response);
          if (_containerTypes.isNotEmpty) {
            _selectedContainerType = _containerTypes[0]['code'] ?? "20GP";
          }
          _isLoadingContainers = false;
        });
      }
    } catch (e) {
      // Error fetching containers - using fallback
      if (mounted) {
        setState(() {
          _containerTypes = [
            {
              "code": "20GP",
              "name": "20' Standard",
              "volume_capacity_cbm": "28-30"
            },
            {
              "code": "40GP",
              "name": "40' Standard",
              "volume_capacity_cbm": "60-65"
            },
            {
              "code": "40HC",
              "name": "40' High Cube",
              "volume_capacity_cbm": "67-69"
            },
            {
              "code": "40NOR",
              "name": "40' NOR (Reefer)",
              "volume_capacity_cbm": "50-55"
            },
          ];
          _isLoadingContainers = false;
        });
      }
    }
  }

  void _addBulto() {
    setState(() {
      _bultosList.add({
        'length': TextEditingController(),
        'width': TextEditingController(),
        'height': TextEditingController(),
        'weight': TextEditingController(),
      });
    });
  }

  void _removeBulto(int index) {
    if (_bultosList.length > 1) {
      setState(() {
        _bultosList[index]['length']?.dispose();
        _bultosList[index]['width']?.dispose();
        _bultosList[index]['height']?.dispose();
        _bultosList[index]['weight']?.dispose();
        _bultosList.removeAt(index);
      });
    }
  }

  /// Submit quote to backend
  Future<void> _submitQuote() async {
    setState(() => _isSubmitting = true);

    try {
      String transportType;
      double totalWeight = 0;
      double totalVolume = 0;

      if (_tabController.index == 0) {
        transportType = 'FCL';
        // For FCL, get capacity from selected container
        final container = _containerTypes.firstWhere(
          (c) => c['code'] == _selectedContainerType,
          orElse: () => {'volume_capacity_cbm': '33.00'},
        );
        totalVolume = double.tryParse(
                container['volume_capacity_cbm']?.toString() ?? '33') ??
            33.0;
        totalVolume *= _containerQuantity;
      } else if (_tabController.index == 1) {
        transportType = 'LCL';
        // Calculate from bultos
        for (var bulto in _bultosList) {
          double l = double.tryParse(bulto['length']?.text ?? '') ?? 0;
          double w = double.tryParse(bulto['width']?.text ?? '') ?? 0;
          double h = double.tryParse(bulto['height']?.text ?? '') ?? 0;
          double wt = double.tryParse(bulto['weight']?.text ?? '') ?? 0;
          totalVolume += (l * w * h) / 1000000; // cm to CBM
          totalWeight += wt;
        }
      } else {
        transportType = 'AIR';
        totalWeight = double.tryParse(_weightController.text) ?? 0;
        totalVolume = double.tryParse(_volumeController.text) ?? 0;
      }

      final payload = {
        'origin': _originController.text,
        'destination': _destinationController.text,
        'transport_type': transportType,
        'cargo_description': _productController.text,
        'cargo_weight_kg': totalWeight,
        'cargo_volume_cbm': totalVolume,
        'fob_value_usd': double.tryParse(_fobController.text) ?? 0,
        'company_name': '', // Will be filled from user profile
        'contact_name': '',
        'contact_email': '',
        'contact_phone': '',
        'city': _destinationController.text,
      };

      if (transportType == 'FCL') {
        payload['container_type'] = _selectedContainerType;
        payload['container_quantity'] = _containerQuantity;
      }

      // Submitting quote
      final response = await _apiClient.post('sales/submissions/', payload);
      // Quote submitted successfully

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Cotización enviada: ${response['submission_number'] ?? 'OK'}'),
            backgroundColor: AppColors.neonGreen,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      // Error submitting quote
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = AppColors.neonGreen;
    const bgDark = Color(0xFF050A14);
    const surfaceDark = Color(0xFF0F1623);

    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        child: Column(
          children: [
            // AppBar
            _buildAppBar(primaryColor),

            // Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: surfaceDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                labelStyle:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                tabs: const [
                  Tab(text: "MARÍTIMO FCL"),
                  Tab(text: "MARÍTIMO LCL"),
                  Tab(text: "AÉREO"),
                ],
              ),
            ),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildFCLTab(surfaceDark, primaryColor),
                  _buildLCLTab(surfaceDark, primaryColor),
                  _buildAirTab(surfaceDark, primaryColor),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: _buildSubmitButton(primaryColor, bgDark),
    );
  }

  Widget _buildAppBar(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Column(
            children: [
              Text("Solicitar Cotización",
                  style: Theme.of(context).textTheme.titleMedium),
              Text("ImportaYA.ia",
                  style: TextStyle(
                      color: primaryColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1)),
            ],
          ),
          const SizedBox(width: 48), // Balance
        ],
      ),
    );
  }

  // ============ FCL TAB ============
  Widget _buildFCLTab(Color surfaceDark, Color primaryColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInDown(
            child: NeonCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCardTitle(Icons.directions_boat, "Tipo de Contenedor",
                      primaryColor),
                  const SizedBox(height: 16),
                  if (_isLoadingContainers)
                    const Center(child: CircularProgressIndicator())
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _containerTypes.map((container) {
                        final isSelected =
                            _selectedContainerType == container['code'];
                        return GestureDetector(
                          onTap: () => setState(
                              () => _selectedContainerType = container['code']),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? primaryColor.withValues(alpha: 0.2)
                                  : surfaceDark,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? primaryColor
                                    : Colors.grey.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  container['code'],
                                  style: TextStyle(
                                    color: isSelected
                                        ? primaryColor
                                        : Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${container['volume_capacity_cbm']} CBM',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 16),
                  _buildLabel("Cantidad de Contenedores"),
                  _buildQuantitySelector(primaryColor, surfaceDark),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildSharedFields(surfaceDark, primaryColor),
        ],
      ),
    );
  }

  // ============ LCL TAB ============
  Widget _buildLCLTab(Color surfaceDark, Color primaryColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Toggle between detail and manual mode
          FadeInDown(
            child: NeonCard(
              glowColor: Colors.blue,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildCardTitle(
                          Icons.inventory_2, "Datos de Carga LCL", Colors.blue),
                      // Toggle button
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: surfaceDark,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () =>
                                  setState(() => _lclManualMode = false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: !_lclManualMode
                                      ? Colors.blue
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  "Detallado",
                                  style: TextStyle(
                                    color: !_lclManualMode
                                        ? Colors.white
                                        : Colors.grey,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () =>
                                  setState(() => _lclManualMode = true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _lclManualMode
                                      ? Colors.blue
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  "Manual",
                                  style: TextStyle(
                                    color: _lclManualMode
                                        ? Colors.white
                                        : Colors.grey,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Conditional content based on mode
                  if (!_lclManualMode) ...[
                    // DETAILED MODE - Bultos with dimensions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Bultos con dimensiones",
                            style: TextStyle(
                                color: Colors.grey[400], fontSize: 12)),
                        IconButton(
                          onPressed: _addBulto,
                          icon:
                              const Icon(Icons.add_circle, color: Colors.blue),
                          tooltip: "Agregar Bulto",
                        ),
                      ],
                    ),
                    ..._bultosList.asMap().entries.map((entry) {
                      final index = entry.key;
                      final controllers = entry.value;
                      return _buildBultoItem(
                          index, controllers, surfaceDark, primaryColor);
                    }),
                  ] else ...[
                    // MANUAL MODE - Direct input of totals
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: Colors.blue.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline,
                              color: Colors.blue, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Si no conoces las dimensiones exactas, ingresa los totales directamente",
                              style: TextStyle(
                                  color: Colors.blue[200], fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Pieces
                    _buildInputField("Cantidad de Piezas/Bultos",
                        _lclPiecesController, surfaceDark, Colors.blue,
                        keyboardType: TextInputType.number),
                    const SizedBox(height: 12),
                    // Row with CBM and Weight
                    Row(
                      children: [
                        Expanded(
                          child: _buildInputField("Total CBM",
                              _lclTotalCbmController, surfaceDark, Colors.blue,
                              keyboardType: TextInputType.number, suffix: "m³"),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInputField(
                              "Peso Total (Kg)",
                              _lclTotalWeightController,
                              surfaceDark,
                              Colors.blue,
                              keyboardType: TextInputType.number,
                              suffix: "kg"),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildSharedFields(surfaceDark, primaryColor),
        ],
      ),
    );
  }

  Widget _buildBultoItem(
      int index,
      Map<String, TextEditingController> controllers,
      Color surfaceDark,
      Color primaryColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Bulto ${index + 1}",
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              if (_bultosList.length > 1)
                IconButton(
                  icon: const Icon(Icons.remove_circle,
                      color: Colors.red, size: 20),
                  onPressed: () => _removeBulto(index),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                  child: _buildSmallInput(
                      "L (cm)", controllers['length']!, surfaceDark)),
              const SizedBox(width: 8),
              Expanded(
                  child: _buildSmallInput(
                      "W (cm)", controllers['width']!, surfaceDark)),
              const SizedBox(width: 8),
              Expanded(
                  child: _buildSmallInput(
                      "H (cm)", controllers['height']!, surfaceDark)),
              const SizedBox(width: 8),
              Expanded(
                  child: _buildSmallInput(
                      "Kg", controllers['weight']!, surfaceDark)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallInput(
      String hint, TextEditingController controller, Color bg) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
        filled: true,
        fillColor: bg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // ============ AIR TAB ============
  Widget _buildAirTab(Color surfaceDark, Color primaryColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInDown(
            child: NeonCard(
              glowColor: Colors.amber,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCardTitle(
                      Icons.flight, "Datos de Carga Aérea", Colors.amber),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInputField("Peso Bruto (kg)",
                            _weightController, surfaceDark, primaryColor),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildInputField("Volumen (CBM)",
                            _volumeController, surfaceDark, primaryColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            color: Colors.amber, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Se cobra por peso volumétrico: (L×W×H cm) / 6000",
                            style: TextStyle(
                                color: Colors.amber[200], fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildSharedFields(surfaceDark, primaryColor),
        ],
      ),
    );
  }

  // ============ SHARED FIELDS ============
  Widget _buildSharedFields(Color surfaceDark, Color primaryColor) {
    // Determine if we're in Air mode based on tab index
    final bool isAirMode = _tabController.index == 2;

    return Column(
      children: [
        NeonCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCardTitle(isAirMode ? Icons.flight : Icons.route,
                  isAirMode ? "Ruta Aérea" : "Ruta Marítima", primaryColor),
              const SizedBox(height: 16),
              // Origin POL - Worldwide ports/airports
              PortAutocompleteField(
                label: isAirMode ? "Aeropuerto Origen" : "Puerto Origen (POL)",
                hint: isAirMode
                    ? "Ej: Miami, Shanghai, Frankfurt..."
                    : "Ej: Shanghai, Los Angeles, Rotterdam...",
                controller: _originController,
                isAirport: isAirMode,
                isDestination: false,
                accentColor: primaryColor,
                backgroundColor: surfaceDark,
              ),
              const SizedBox(height: 12),
              // Destination POD - Ecuador only
              PortAutocompleteField(
                label: isAirMode
                    ? "Aeropuerto Destino (Ecuador)"
                    : "Puerto Destino (POD - Ecuador)",
                hint: isAirMode
                    ? "Guayaquil (GYE), Quito (UIO)..."
                    : "Guayaquil (ECGYE), Manta...",
                controller: _destinationController,
                isAirport: isAirMode,
                isDestination: true,
                accentColor: primaryColor,
                backgroundColor: surfaceDark,
              ),
              const SizedBox(height: 12),
              _buildInputField("Descripción del Producto", _productController,
                  surfaceDark, primaryColor),
            ],
          ),
        ),

        const SizedBox(height: 16),

        NeonCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCardTitle(Icons.payments, "Valores", primaryColor),
              const SizedBox(height: 16),
              // Solo Valor FOB - El flete lo calcula el backend con IA
              _buildCurrencyInput(
                  "Valor FOB (USD)", _fobController, surfaceDark, primaryColor),
              const SizedBox(height: 12),
              _buildIncotermDropdown(surfaceDark, primaryColor),
              const SizedBox(height: 12),
              _buildInsuranceToggle(primaryColor),
            ],
          ),
        ),

        const SizedBox(height: 100), // Space for bottom button
      ],
    );
  }

  // ============ HELPER WIDGETS ============
  Widget _buildCardTitle(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(text, style: Theme.of(context).textTheme.titleSmall),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child:
          Text(text, style: const TextStyle(color: Colors.grey, fontSize: 12)),
    );
  }

  Widget _buildQuantitySelector(Color primaryColor, Color bg) {
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove, color: Colors.grey),
            onPressed: () => setState(() =>
                _containerQuantity = (_containerQuantity - 1).clamp(1, 99)),
          ),
          SizedBox(
            width: 40,
            child: Text(
              '$_containerQuantity',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
          ),
          IconButton(
            icon: Icon(Icons.add, color: primaryColor),
            onPressed: () => setState(() =>
                _containerQuantity = (_containerQuantity + 1).clamp(1, 99)),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(
      String label, TextEditingController controller, Color bg, Color accent,
      {TextInputType? keyboardType, String? suffix}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: bg,
            hintStyle: const TextStyle(color: Colors.grey),
            suffixText: suffix,
            suffixStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: accent),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrencyInput(
      String label, TextEditingController controller, Color bg, Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixText: "\$ ",
            prefixStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: bg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: accent),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIncotermDropdown(Color bg, Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("Incoterm"),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _incoterm,
              isExpanded: true,
              dropdownColor: bg,
              icon: Icon(Icons.expand_more, color: accent),
              style: const TextStyle(color: Colors.white),
              items: ["FOB", "CIF", "EXW", "DDP", "CFR"]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => _incoterm = v!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInsuranceToggle(Color accent) {
    return GestureDetector(
      onTap: () => setState(() => _includeInsurance = !_includeInsurance),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _includeInsurance
              ? accent.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                _includeInsurance ? accent : Colors.grey.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              _includeInsurance
                  ? Icons.check_box
                  : Icons.check_box_outline_blank,
              color: _includeInsurance ? accent : Colors.grey,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                "Incluir Seguro Internacional (0.35% del CFR)",
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(Color primaryColor, Color bgDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgDark.withValues(alpha: 0.95),
        border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: _isSubmitting ? null : _submitQuote,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.black,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          icon: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.black),
                )
              : const Icon(Icons.send),
          label: Text(
            _isSubmitting ? "Enviando..." : "Solicitar Cotización",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
