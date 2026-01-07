import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../config/theme.dart';
import '../../core/services/firebase_service.dart';
import '../../core/services/auth_service.dart';
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
  final FirebaseService _firebaseService = FirebaseService();

  // -- Shared Controllers --
  final TextEditingController _fobController = TextEditingController();
  final TextEditingController _productController = TextEditingController();
  final TextEditingController _hsCodeController = TextEditingController();
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController =
      TextEditingController(text: "Guayaquil");

  // -- FCL Specific: Dynamic Container List --
  final List<Map<String, dynamic>> _fclContainerList = [];
  List<Map<String, dynamic>> _containerTypes = [];
  bool _isLoadingContainers = true;

  // -- Shared Fields --
  String? _selectedOriginCountry;
  final List<String> _originCountries = [
    'China',
    'Estados Unidos',
    'Alemania',
    'Japón',
    'Corea del Sur',
    'India',
    'Vietnam',
    'Tailandia',
    'Italia',
    'España',
    'Francia',
    'Reino Unido',
    'Brasil',
    'México',
    'Colombia',
    'Otro'
  ];

  // -- LCL Specific: Dynamic Bultos List --
  final List<Map<String, dynamic>> _bultosList = [];

  // -- LCL New Features --
  bool _lclUseInches = false; // Toggle between cm and inches
  String? _lclIsStackable; // null, 'Si', 'No', 'Si, es apilable'
  String? _lclIsDangerous; // null, 'No', 'Si'
  final TextEditingController _lclCommentsController = TextEditingController();
  final List<String> _embalajeTypes = [
    'Caja',
    'Pallet',
    'Saco',
    'Barril',
    'Bulto',
    'Otro'
  ];

  // -- LCL Manual Mode --
  bool _lclManualMode = false; // Toggle between bultos detail and manual input
  final TextEditingController _lclPiecesController = TextEditingController();
  final TextEditingController _lclTotalCbmController = TextEditingController();
  final TextEditingController _lclTotalWeightController =
      TextEditingController();

  // -- Air Specific --
  final List<Map<String, dynamic>> _airPiezasList = [];
  bool _airUseInches = false; // Toggle between cm and inches
  String? _airIsStackable; // null, 'Si', 'No'
  String? _airIsDangerous; // null, 'No', 'Si'
  final TextEditingController _airCommentsController = TextEditingController();
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
    _lclCommentsController.dispose();
    for (var bulto in _bultosList) {
      (bulto['length'] as TextEditingController?)?.dispose();
      (bulto['width'] as TextEditingController?)?.dispose();
      (bulto['height'] as TextEditingController?)?.dispose();
      (bulto['weight'] as TextEditingController?)?.dispose();
    }
    // Air controllers
    _airCommentsController.dispose();
    for (var pieza in _airPiezasList) {
      (pieza['length'] as TextEditingController?)?.dispose();
      (pieza['width'] as TextEditingController?)?.dispose();
      (pieza['height'] as TextEditingController?)?.dispose();
      (pieza['weight'] as TextEditingController?)?.dispose();
    }
    super.dispose();
  }

  /// Fetch container types from Firebase
  Future<void> _fetchContainerTypes() async {
    try {
      final response = await _firebaseService.getContainers();
      if (mounted) {
        setState(() {
          _containerTypes =
              response.isNotEmpty ? response : _getDefaultContainers();
          _isLoadingContainers = false;
          if (_fclContainerList.isEmpty && _containerTypes.isNotEmpty) {
            _addFCLContainer();
          }
        });
      }
    } catch (e) {
      // Error fetching containers - using fallback
      if (mounted) {
        setState(() {
          _containerTypes = _getDefaultContainers();
          _isLoadingContainers = false;
          if (_fclContainerList.isEmpty) {
            _addFCLContainer();
          }
        });
      }
    }
  }

  List<Map<String, dynamic>> _getDefaultContainers() {
    return [
      {
        "code": "20GP",
        "name": "20ft Standard",
        "volume_capacity_cbm": 28,
        "weight_capacity_kg": 21700
      },
      {
        "code": "40GP",
        "name": "40ft Standard",
        "volume_capacity_cbm": 56,
        "weight_capacity_kg": 26500
      },
      {
        "code": "40HC",
        "name": "40ft High Cube",
        "volume_capacity_cbm": 67,
        "weight_capacity_kg": 26500
      },
      {
        "code": "40NOR",
        "name": "40ft NOR Reefer",
        "volume_capacity_cbm": 54,
        "weight_capacity_kg": 27500
      },
    ];
  }

  /// Add a new FCL container row
  void _addFCLContainer() {
    setState(() {
      _fclContainerList.add({
        'type':
            _containerTypes.isNotEmpty ? _containerTypes[0]['code'] : '20GP',
        'quantity': 1,
        'weight': TextEditingController(),
      });
    });
  }

  /// Remove FCL container row
  void _removeFCLContainer(int index) {
    if (_fclContainerList.length > 1) {
      setState(() {
        (_fclContainerList[index]['weight'] as TextEditingController).dispose();
        _fclContainerList.removeAt(index);
      });
    }
  }

  /// Get total containers count
  int get _totalContainersCount =>
      _fclContainerList.fold<int>(0, (sum, c) => sum + (c['quantity'] as int));

  /// Get total weight estimate
  double get _totalWeightEstimate {
    double total = 0;
    for (var c in _fclContainerList) {
      double wt =
          double.tryParse((c['weight'] as TextEditingController).text) ?? 0;
      total += wt * (c['quantity'] as int);
    }
    return total;
  }

  void _addBulto() {
    setState(() {
      _bultosList.add({
        'length': TextEditingController(),
        'width': TextEditingController(),
        'height': TextEditingController(),
        'weight': TextEditingController(),
        'cantidad': 1,
        'embalaje': 'Caja',
      });
    });
  }

  void _removeBulto(int index) {
    if (_bultosList.length > 1) {
      setState(() {
        (_bultosList[index]['length'] as TextEditingController).dispose();
        (_bultosList[index]['width'] as TextEditingController).dispose();
        (_bultosList[index]['height'] as TextEditingController).dispose();
        (_bultosList[index]['weight'] as TextEditingController).dispose();
        _bultosList.removeAt(index);
      });
    }
  }

  /// Calculate total LCL CBM from bultos
  double get _totalLclCbm {
    double total = 0;
    for (var bulto in _bultosList) {
      double l =
          double.tryParse((bulto['length'] as TextEditingController).text) ?? 0;
      double w =
          double.tryParse((bulto['width'] as TextEditingController).text) ?? 0;
      double h =
          double.tryParse((bulto['height'] as TextEditingController).text) ?? 0;
      int qty = bulto['cantidad'] as int;
      double cbm = _lclUseInches
          ? (l * w * h * 0.0000164) // Cubic inches to CBM
          : (l * w * h / 1000000); // cm to CBM
      total += cbm * qty;
    }
    return total;
  }

  /// Calculate total LCL weight from bultos
  double get _totalLclWeight {
    double total = 0;
    for (var bulto in _bultosList) {
      double wt =
          double.tryParse((bulto['weight'] as TextEditingController).text) ?? 0;
      int qty = bulto['cantidad'] as int;
      total += wt * qty;
    }
    return total;
  }

  // ============ AIR HELPERS ============
  void _addAirPieza() {
    setState(() {
      _airPiezasList.add({
        'length': TextEditingController(),
        'width': TextEditingController(),
        'height': TextEditingController(),
        'weight': TextEditingController(),
        'cantidad': 1,
        'embalaje': 'Caja',
      });
    });
  }

  void _removeAirPieza(int index) {
    if (_airPiezasList.length > 1) {
      setState(() {
        (_airPiezasList[index]['length'] as TextEditingController).dispose();
        (_airPiezasList[index]['width'] as TextEditingController).dispose();
        (_airPiezasList[index]['height'] as TextEditingController).dispose();
        (_airPiezasList[index]['weight'] as TextEditingController).dispose();
        _airPiezasList.removeAt(index);
      });
    }
  }

  /// Calculate total Air CBM from piezas
  double get _totalAirCbm {
    double total = 0;
    for (var pieza in _airPiezasList) {
      double l =
          double.tryParse((pieza['length'] as TextEditingController).text) ?? 0;
      double w =
          double.tryParse((pieza['width'] as TextEditingController).text) ?? 0;
      double h =
          double.tryParse((pieza['height'] as TextEditingController).text) ?? 0;
      int qty = pieza['cantidad'] as int;
      double cbm = _airUseInches
          ? (l * w * h * 0.0000164) // Cubic inches to CBM
          : (l * w * h / 1000000); // cm to CBM
      total += cbm * qty;
    }
    return total;
  }

  /// Calculate total Air weight from piezas (actual weight)
  double get _totalAirWeight {
    double total = 0;
    for (var pieza in _airPiezasList) {
      double wt =
          double.tryParse((pieza['weight'] as TextEditingController).text) ?? 0;
      int qty = pieza['cantidad'] as int;
      total += wt * qty;
    }
    return total;
  }

  /// Calculate volumetric weight for air cargo
  double get _airVolumetricWeight {
    double total = 0;
    for (var pieza in _airPiezasList) {
      double l =
          double.tryParse((pieza['length'] as TextEditingController).text) ?? 0;
      double w =
          double.tryParse((pieza['width'] as TextEditingController).text) ?? 0;
      double h =
          double.tryParse((pieza['height'] as TextEditingController).text) ?? 0;
      int qty = pieza['cantidad'] as int;
      double vol = _airUseInches
          ? (l * w * h / 366) // Cubic inches / 366
          : (l * w * h / 6000); // cm³ / 6000
      total += vol * qty;
    }
    return total;
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
        // For FCL, calculate from container list
        for (var container in _fclContainerList) {
          final type = _containerTypes.firstWhere(
            (c) => c['code'] == container['type'],
            orElse: () => {'volume_capacity_cbm': 33.0},
          );
          double vol = double.tryParse(
                  type['volume_capacity_cbm']?.toString() ?? '33') ??
              33.0;
          totalVolume += vol * (container['quantity'] as int);
          double wt = double.tryParse(
                  (container['weight'] as TextEditingController).text) ??
              0;
          totalWeight += wt * (container['quantity'] as int);
        }
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

      // Get user data from AuthService
      final authService = AuthService();
      final userData = authService.userData;

      final payload = {
        'origin': _originController.text,
        'destination': _destinationController.text,
        'transport_type': transportType,
        'cargo_description': _productController.text,
        'cargo_weight_kg': totalWeight,
        'cargo_volume_cbm': totalVolume,
        'fob_value_usd': double.tryParse(_fobController.text) ?? 0,
        'company_name': userData?['company_name'] ?? 'Sin especificar',
        'contact_name':
            '${userData?['first_name'] ?? ''} ${userData?['last_name'] ?? ''}'
                    .trim()
                    .isNotEmpty
                ? '${userData?['first_name'] ?? ''} ${userData?['last_name'] ?? ''}'
                    .trim()
                : 'Usuario',
        'contact_email': authService.userEmail ?? 'sin@email.com',
        'contact_phone': userData?['phone'] ?? '0000000000',
        'city': _destinationController.text,
      };

      if (transportType == 'FCL') {
        // Send container configuration as list
        payload['container_config'] = _fclContainerList
            .map((c) => {
                  'type': c['type'],
                  'quantity': c['quantity'],
                  'weight': double.tryParse(
                          (c['weight'] as TextEditingController).text) ??
                      0,
                })
            .toList();
      }

      // Submitting quote to Firebase
      final quoteId = await _firebaseService.createQuote(payload);
      // Quote submitted successfully

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cotización enviada: $quoteId'),
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
          // Container Configuration Section
          FadeInDown(
            child: NeonCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildCardTitle(Icons.directions_boat,
                          "Configuración de Contenedores FCL", primaryColor),
                      TextButton.icon(
                        icon: Icon(Icons.add_circle, color: primaryColor),
                        label: Text("Agregar",
                            style: TextStyle(color: primaryColor)),
                        onPressed: _addFCLContainer,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: Colors.amber.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            color: Colors.amber, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Límite de peso: Máximo 21,000 Kg por contenedor.",
                            style: TextStyle(
                                color: Colors.amber[200], fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_isLoadingContainers)
                    const Center(child: CircularProgressIndicator())
                  else ...[
                    // Container Rows
                    ..._fclContainerList.asMap().entries.map((entry) {
                      final index = entry.key;
                      final container = entry.value;
                      return _buildFCLContainerRow(
                          index, container, surfaceDark, primaryColor);
                    }),
                    const SizedBox(height: 16),
                    // Totals Summary
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: primaryColor.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Total Contenedores",
                                  style: TextStyle(
                                      color: Colors.grey[400], fontSize: 11)),
                              Text("$_totalContainersCount",
                                  style: TextStyle(
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("Peso Total Estimado",
                                  style: TextStyle(
                                      color: Colors.grey[400], fontSize: 11)),
                              Text(
                                  "${_totalWeightEstimate.toStringAsFixed(0)} Kg",
                                  style: TextStyle(
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18)),
                            ],
                          ),
                        ],
                      ),
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

  /// Build a single FCL container row with type, quantity, weight
  Widget _buildFCLContainerRow(int index, Map<String, dynamic> container,
      Color surfaceDark, Color primaryColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Contenedor ${index + 1}",
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              if (_fclContainerList.length > 1)
                IconButton(
                  icon: const Icon(Icons.remove_circle,
                      color: Colors.red, size: 20),
                  onPressed: () => _removeFCLContainer(index),
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Container Type Dropdown
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Tipo",
                        style:
                            TextStyle(color: Colors.grey[400], fontSize: 10)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F1623),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: container['type'] as String,
                          isExpanded: true,
                          dropdownColor: const Color(0xFF0F1623),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 13),
                          items: _containerTypes.map((type) {
                            return DropdownMenuItem<String>(
                              value: type['code'] as String,
                              child: Text("${type['code']} - ${type['name']}"),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => container['type'] = value);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Quantity
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Cantidad",
                        style:
                            TextStyle(color: Colors.grey[400], fontSize: 10)),
                    const SizedBox(height: 4),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F1623),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                int qty = container['quantity'] as int;
                                container['quantity'] = (qty - 1).clamp(1, 99);
                              });
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(6),
                              child: Icon(Icons.remove,
                                  color: Colors.grey, size: 16),
                            ),
                          ),
                          Text(
                            '${container['quantity']}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                int qty = container['quantity'] as int;
                                container['quantity'] = (qty + 1).clamp(1, 99);
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Icon(Icons.add,
                                  color: primaryColor, size: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Weight
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Peso (Kg)",
                        style:
                            TextStyle(color: Colors.grey[400], fontSize: 10)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: container['weight'] as TextEditingController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: "10000",
                        hintStyle:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                        filled: true,
                        fillColor: const Color(0xFF0F1623),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (_) => setState(() {}), // Update totals
                    ),
                  ],
                ),
              ),
            ],
          ),
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
                      _buildCardTitle(Icons.inventory_2,
                          "Información de la Carga", Colors.blue),
                      // Unit Toggle (cm/inches)
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
                                  setState(() => _lclUseInches = false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: !_lclUseInches
                                      ? Colors.blue
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text("CM",
                                    style: TextStyle(
                                      color: !_lclUseInches
                                          ? Colors.white
                                          : Colors.grey,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    )),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(() => _lclUseInches = true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _lclUseInches
                                      ? Colors.blue
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text("IN",
                                    style: TextStyle(
                                      color: _lclUseInches
                                          ? Colors.white
                                          : Colors.grey,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    )),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Mode toggle: Detallado / Manual
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: surfaceDark,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () => setState(() => _lclManualMode = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: !_lclManualMode
                                    ? Colors.blue
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text("Detallado",
                                  style: TextStyle(
                                    color: !_lclManualMode
                                        ? Colors.white
                                        : Colors.grey,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  )),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(() => _lclManualMode = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: _lclManualMode
                                    ? Colors.blue
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text("Manual",
                                  style: TextStyle(
                                    color: _lclManualMode
                                        ? Colors.white
                                        : Colors.grey,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  )),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Conditional content based on mode
                  if (!_lclManualMode) ...[
                    // DETAILED MODE - Piezas with dimensions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Piezas con dimensiones",
                            style: TextStyle(
                                color: Colors.grey[400], fontSize: 12)),
                        TextButton.icon(
                          icon: const Icon(Icons.add_circle,
                              color: Colors.blue, size: 18),
                          label: const Text("Agregar Pieza",
                              style:
                                  TextStyle(color: Colors.blue, fontSize: 12)),
                          onPressed: _addBulto,
                        ),
                      ],
                    ),
                    ..._bultosList.asMap().entries.map((entry) {
                      final index = entry.key;
                      final bulto = entry.value;
                      return _buildBultoItem(
                          index, bulto, surfaceDark, primaryColor);
                    }),

                    // CBM Summary Banner
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: Colors.blue.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Total CBM",
                                  style: TextStyle(
                                      color: Colors.grey[400], fontSize: 10)),
                              Text("${_totalLclCbm.toStringAsFixed(3)} m³",
                                  style: const TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("Peso Total",
                                  style: TextStyle(
                                      color: Colors.grey[400], fontSize: 10)),
                              Text("${_totalLclWeight.toStringAsFixed(0)} Kg",
                                  style: const TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                            ],
                          ),
                        ],
                      ),
                    ),
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
                    _buildInputField("Cantidad de Piezas/Bultos",
                        _lclPiecesController, surfaceDark, Colors.blue,
                        keyboardType: TextInputType.number),
                    const SizedBox(height: 12),
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

                  // Cargo Options Section
                  const SizedBox(height: 20),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 12),

                  // Stackable dropdown
                  _buildLabel("¿La carga es APILABLE?"),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: surfaceDark,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _lclIsStackable,
                        isExpanded: true,
                        dropdownColor: surfaceDark,
                        hint: const Text("Seleccione una opción...",
                            style: TextStyle(color: Colors.grey)),
                        style: const TextStyle(color: Colors.white),
                        items: const [
                          DropdownMenuItem(
                              value: 'Si', child: Text('Sí, es apilable')),
                          DropdownMenuItem(
                              value: 'No', child: Text('No, no es apilable')),
                        ],
                        onChanged: (value) =>
                            setState(() => _lclIsStackable = value),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Dangerous goods dropdown
                  _buildLabel("¿Es carga PELIGROSA/DG CARGO/IMO?"),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: surfaceDark,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _lclIsDangerous,
                        isExpanded: true,
                        dropdownColor: surfaceDark,
                        hint: const Text("Seleccione una opción...",
                            style: TextStyle(color: Colors.grey)),
                        style: const TextStyle(color: Colors.white),
                        items: const [
                          DropdownMenuItem(value: 'No', child: Text('No')),
                          DropdownMenuItem(
                              value: 'Si',
                              child: Text('Sí, es carga peligrosa')),
                        ],
                        onChanged: (value) =>
                            setState(() => _lclIsDangerous = value),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Additional comments
                  _buildLabel("Comentarios Adicionales (Opcional)"),
                  TextField(
                    controller: _lclCommentsController,
                    maxLines: 2,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText:
                          "Ingrese cualquier comentario adicional sobre la carga...",
                      hintStyle:
                          const TextStyle(color: Colors.grey, fontSize: 12),
                      filled: true,
                      fillColor: surfaceDark,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
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

  Widget _buildBultoItem(int index, Map<String, dynamic> bulto,
      Color surfaceDark, Color primaryColor) {
    String unitLabel = _lclUseInches ? 'in' : 'cm';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Pieza ${index + 1}",
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              if (_bultosList.length > 1)
                IconButton(
                  icon: const Icon(Icons.remove_circle,
                      color: Colors.red, size: 20),
                  onPressed: () => _removeBulto(index),
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Row 1: Dimensions
          Row(
            children: [
              Expanded(
                  child: _buildSmallInput("L ($unitLabel)",
                      bulto['length'] as TextEditingController, surfaceDark)),
              const SizedBox(width: 6),
              Expanded(
                  child: _buildSmallInput("A ($unitLabel)",
                      bulto['width'] as TextEditingController, surfaceDark)),
              const SizedBox(width: 6),
              Expanded(
                  child: _buildSmallInput("H ($unitLabel)",
                      bulto['height'] as TextEditingController, surfaceDark)),
              const SizedBox(width: 6),
              Expanded(
                  child: _buildSmallInput("Kg",
                      bulto['weight'] as TextEditingController, surfaceDark)),
            ],
          ),
          const SizedBox(height: 12),
          // Row 2: Cantidad, Embalaje
          Row(
            children: [
              // Cantidad with +/- buttons
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Cantidad",
                        style:
                            TextStyle(color: Colors.grey[400], fontSize: 10)),
                    const SizedBox(height: 4),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F1623),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                int qty = bulto['cantidad'] as int;
                                bulto['cantidad'] = (qty - 1).clamp(1, 999);
                              });
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(6),
                              child: Icon(Icons.remove,
                                  color: Colors.grey, size: 16),
                            ),
                          ),
                          Text(
                            '${bulto['cantidad']}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                int qty = bulto['cantidad'] as int;
                                bulto['cantidad'] = (qty + 1).clamp(1, 999);
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Icon(Icons.add,
                                  color: primaryColor, size: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Embalaje dropdown
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Embalaje",
                        style:
                            TextStyle(color: Colors.grey[400], fontSize: 10)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F1623),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: bulto['embalaje'] as String,
                          isExpanded: true,
                          dropdownColor: const Color(0xFF0F1623),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 13),
                          items: _embalajeTypes.map((type) {
                            return DropdownMenuItem<String>(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => bulto['embalaje'] = value);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
    // Initialize air piezas list if empty
    if (_airPiezasList.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _addAirPieza());
    }

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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildCardTitle(Icons.flight, "Información de la Carga",
                          Colors.amber),
                      // Unit Toggle (cm/inches)
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
                                  setState(() => _airUseInches = false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: !_airUseInches
                                      ? Colors.amber
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text("CM",
                                    style: TextStyle(
                                      color: !_airUseInches
                                          ? Colors.black
                                          : Colors.grey,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    )),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(() => _airUseInches = true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _airUseInches
                                      ? Colors.amber
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text("IN",
                                    style: TextStyle(
                                      color: _airUseInches
                                          ? Colors.black
                                          : Colors.grey,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    )),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Pieza rows header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Piezas con dimensiones",
                          style:
                              TextStyle(color: Colors.grey[400], fontSize: 12)),
                      TextButton.icon(
                        icon: const Icon(Icons.add_circle,
                            color: Colors.amber, size: 18),
                        label: const Text("Agregar Pieza",
                            style:
                                TextStyle(color: Colors.amber, fontSize: 12)),
                        onPressed: _addAirPieza,
                      ),
                    ],
                  ),

                  // Pieza rows
                  ..._airPiezasList.asMap().entries.map((entry) {
                    final index = entry.key;
                    final pieza = entry.value;
                    return _buildAirPiezaItem(
                        index, pieza, surfaceDark, Colors.amber);
                  }),

                  // CBM/Weight Summary Banner
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: Colors.amber.withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Total CBM",
                                    style: TextStyle(
                                        color: Colors.grey[400], fontSize: 10)),
                                Text("${_totalAirCbm.toStringAsFixed(3)} m³",
                                    style: const TextStyle(
                                        color: Colors.amber,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text("Peso Real",
                                    style: TextStyle(
                                        color: Colors.grey[400], fontSize: 10)),
                                Text("${_totalAirWeight.toStringAsFixed(0)} Kg",
                                    style: const TextStyle(
                                        color: Colors.amber,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text("Peso Vol.",
                                    style: TextStyle(
                                        color: Colors.grey[400], fontSize: 10)),
                                Text(
                                    "${_airVolumetricWeight.toStringAsFixed(1)} Kg",
                                    style: const TextStyle(
                                        color: Colors.amber,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                            "Se cobra el mayor: peso real vs volumétrico (L×A×H/${_airUseInches ? '366' : '6000'})",
                            style: TextStyle(
                                color: Colors.amber[200], fontSize: 10)),
                      ],
                    ),
                  ),

                  // Cargo Options Section
                  const SizedBox(height: 20),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 12),

                  // Stackable dropdown
                  _buildLabel("¿La carga es APILABLE?"),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: surfaceDark,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _airIsStackable,
                        isExpanded: true,
                        dropdownColor: surfaceDark,
                        hint: const Text("Seleccione una opción...",
                            style: TextStyle(color: Colors.grey)),
                        style: const TextStyle(color: Colors.white),
                        items: const [
                          DropdownMenuItem(
                              value: 'Si', child: Text('Sí, es apilable')),
                          DropdownMenuItem(
                              value: 'No', child: Text('No, no es apilable')),
                        ],
                        onChanged: (value) =>
                            setState(() => _airIsStackable = value),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Dangerous goods dropdown
                  _buildLabel("¿Es carga PELIGROSA/DG CARGO/IMO?"),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: surfaceDark,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _airIsDangerous,
                        isExpanded: true,
                        dropdownColor: surfaceDark,
                        hint: const Text("Seleccione una opción...",
                            style: TextStyle(color: Colors.grey)),
                        style: const TextStyle(color: Colors.white),
                        items: const [
                          DropdownMenuItem(value: 'No', child: Text('No')),
                          DropdownMenuItem(
                              value: 'Si',
                              child: Text('Sí, es carga peligrosa')),
                        ],
                        onChanged: (value) =>
                            setState(() => _airIsDangerous = value),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Additional comments
                  _buildLabel("Comentarios Adicionales (Opcional)"),
                  TextField(
                    controller: _airCommentsController,
                    maxLines: 2,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText:
                          "Ingrese cualquier comentario adicional sobre la carga...",
                      hintStyle:
                          const TextStyle(color: Colors.grey, fontSize: 12),
                      filled: true,
                      fillColor: surfaceDark,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
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

  /// Build Air pieza item (similar to LCL bulto but with amber theme)
  Widget _buildAirPiezaItem(int index, Map<String, dynamic> pieza,
      Color surfaceDark, Color accentColor) {
    String unitLabel = _airUseInches ? 'in' : 'cm';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Pieza ${index + 1}",
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              if (_airPiezasList.length > 1)
                IconButton(
                  icon: const Icon(Icons.remove_circle,
                      color: Colors.red, size: 20),
                  onPressed: () => _removeAirPieza(index),
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Row 1: Dimensions
          Row(
            children: [
              Expanded(
                  child: _buildSmallInput("L ($unitLabel)",
                      pieza['length'] as TextEditingController, surfaceDark)),
              const SizedBox(width: 6),
              Expanded(
                  child: _buildSmallInput("A ($unitLabel)",
                      pieza['width'] as TextEditingController, surfaceDark)),
              const SizedBox(width: 6),
              Expanded(
                  child: _buildSmallInput("H ($unitLabel)",
                      pieza['height'] as TextEditingController, surfaceDark)),
              const SizedBox(width: 6),
              Expanded(
                  child: _buildSmallInput("Kg",
                      pieza['weight'] as TextEditingController, surfaceDark)),
            ],
          ),
          const SizedBox(height: 12),
          // Row 2: Cantidad, Embalaje
          Row(
            children: [
              // Cantidad with +/- buttons
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Cantidad",
                        style:
                            TextStyle(color: Colors.grey[400], fontSize: 10)),
                    const SizedBox(height: 4),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F1623),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                int qty = pieza['cantidad'] as int;
                                pieza['cantidad'] = (qty - 1).clamp(1, 999);
                              });
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(6),
                              child: Icon(Icons.remove,
                                  color: Colors.grey, size: 16),
                            ),
                          ),
                          Text('${pieza['cantidad']}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          InkWell(
                            onTap: () {
                              setState(() {
                                int qty = pieza['cantidad'] as int;
                                pieza['cantidad'] = (qty + 1).clamp(1, 999);
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child:
                                  Icon(Icons.add, color: accentColor, size: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Embalaje dropdown
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Embalaje",
                        style:
                            TextStyle(color: Colors.grey[400], fontSize: 10)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F1623),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: pieza['embalaje'] as String,
                          isExpanded: true,
                          dropdownColor: const Color(0xFF0F1623),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 13),
                          items: _embalajeTypes.map((type) {
                            return DropdownMenuItem<String>(
                                value: type, child: Text(type));
                          }).toList(),
                          onChanged: (value) =>
                              setState(() => pieza['embalaje'] = value),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
              const SizedBox(height: 12),

              // Country of Origin Dropdown
              _buildLabel("País de Origen/Fabricación"),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: surfaceDark,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedOriginCountry,
                    isExpanded: true,
                    dropdownColor: surfaceDark,
                    hint: const Text("Seleccione país de origen...",
                        style: TextStyle(color: Colors.grey)),
                    style: const TextStyle(color: Colors.white),
                    items: _originCountries.map((country) {
                      return DropdownMenuItem(
                          value: country, child: Text(country));
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => _selectedOriginCountry = value),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // HS Code (Optional)
              _buildInputField("Código HS (Opcional)", _hsCodeController,
                  surfaceDark, primaryColor,
                  keyboardType: TextInputType.number),

              const SizedBox(height: 8),
              const Text(
                "Si conoce el código arancelario de su producto, ingréselo aquí. De lo contrario, nuestra IA lo clasificará automáticamente.",
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                    fontStyle: FontStyle.italic),
              ),
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
