import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../config/theme.dart';
import '../../core/services/firebase_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/master_data_service.dart'; // IMPORTANTE
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

  // Acceso a la Data Maestra (Cerebro)
  final MasterDataService _masterData = MasterDataService();

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
  // NOTA: _originCountries ya no es fijo, viene de _masterData.countries

  // -- LCL Specific: Dynamic Bultos List --
  final List<Map<String, dynamic>> _bultosList = [];

  // -- LCL New Features --
  bool _lclUseInches = false;
  String? _lclIsStackable;
  String? _lclIsDangerous;
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
  bool _lclManualMode = false;
  final TextEditingController _lclPiecesController = TextEditingController();
  final TextEditingController _lclTotalCbmController = TextEditingController();
  final TextEditingController _lclTotalWeightController =
      TextEditingController();

  // -- Air Specific --
  final List<Map<String, dynamic>> _airPiezasList = [];
  bool _airUseInches = false;
  String? _airIsStackable;
  String? _airIsDangerous;
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
    _addBulto();
    _fetchContainerTypes();

    // Inicializar Incoterm por defecto si existe en la base de datos
    if (_masterData.incoterms.isNotEmpty) {
      _incoterm = _masterData.incoterms.first.code;
    }
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    setState(() {
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
    _productController.dispose();
    _hsCodeController.dispose();
    _originController.dispose();
    _destinationController.dispose();
    _weightController.dispose();
    _volumeController.dispose();
    _lclPiecesController.dispose();
    _lclTotalCbmController.dispose();
    _lclTotalWeightController.dispose();
    _lclCommentsController.dispose();
    // Limpieza de controladores en listas
    for (var bulto in _bultosList) {
      (bulto['length'] as TextEditingController?)?.dispose();
      (bulto['width'] as TextEditingController?)?.dispose();
      (bulto['height'] as TextEditingController?)?.dispose();
      (bulto['weight'] as TextEditingController?)?.dispose();
    }
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
      {"code": "20GP", "name": "20ft Standard", "volume_capacity_cbm": 28},
      {"code": "40GP", "name": "40ft Standard", "volume_capacity_cbm": 56},
      {"code": "40HC", "name": "40ft High Cube", "volume_capacity_cbm": 67},
      {"code": "40NOR", "name": "40ft NOR Reefer", "volume_capacity_cbm": 54},
    ];
  }

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

  void _removeFCLContainer(int index) {
    if (_fclContainerList.length > 1) {
      setState(() {
        (_fclContainerList[index]['weight'] as TextEditingController).dispose();
        _fclContainerList.removeAt(index);
      });
    }
  }

  int get _totalContainersCount =>
      _fclContainerList.fold<int>(0, (sum, c) => sum + (c['quantity'] as int));

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
      double cbm =
          _lclUseInches ? (l * w * h * 0.0000164) : (l * w * h / 1000000);
      total += cbm * qty;
    }
    return total;
  }

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
      double cbm =
          _airUseInches ? (l * w * h * 0.0000164) : (l * w * h / 1000000);
      total += cbm * qty;
    }
    return total;
  }

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
      double vol = _airUseInches ? (l * w * h / 366) : (l * w * h / 6000);
      total += vol * qty;
    }
    return total;
  }

  Future<void> _submitQuote() async {
    setState(() => _isSubmitting = true);
    try {
      String transportType;
      double totalWeight = 0;
      double totalVolume = 0;

      if (_tabController.index == 0) {
        transportType = 'FCL';
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
        totalVolume = _totalLclCbm;
        totalWeight = _totalLclWeight;
      } else {
        transportType = 'AIR';
        totalVolume = _totalAirCbm;
        totalWeight = _totalAirWeight;
      }

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
        'origin_country': _selectedOriginCountry, // Campo importante
        'incoterm': _incoterm,
        'insurance_requested': _includeInsurance,
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
      };

      if (transportType == 'FCL') {
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

      final quoteId = await _firebaseService.createQuote(payload);

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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const primaryColor = AppColors.neonGreen;
    final bgBackgroundColor = theme.scaffoldBackgroundColor;
    final surfaceColor = theme.cardColor;

    return Scaffold(
      backgroundColor: bgBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(primaryColor),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                labelColor: isDark ? Colors.black : Colors.white,
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
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildFCLTab(surfaceColor, primaryColor),
                  _buildLCLTab(surfaceColor, primaryColor),
                  _buildAirTab(surfaceColor, primaryColor),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: _buildSubmitButton(primaryColor, bgBackgroundColor),
    );
  }

  Widget _buildAppBar(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).appBarTheme.backgroundColor,
        border:
            Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back,
                color: Theme.of(context).iconTheme.color),
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
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  // ============ TABS ============
  Widget _buildFCLTab(Color surfaceDark, Color primaryColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final infoTextColor = isDark ? Colors.amber[200] : Colors.brown[700];
    final labelColor = isDark ? Colors.grey[400] : Colors.grey[600];

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
                            "Peso máximo: 27,000 Kg por contenedor. Posible cobro OWS por sobrepeso.",
                            style:
                                TextStyle(color: infoTextColor, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_isLoadingContainers)
                    const Center(child: CircularProgressIndicator())
                  else ...[
                    ..._fclContainerList.asMap().entries.map((entry) {
                      return _buildFCLContainerRow(
                          entry.key, entry.value, surfaceDark, primaryColor);
                    }),
                    const SizedBox(height: 16),
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
                                      color: labelColor, fontSize: 11)),
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
                                      color: labelColor, fontSize: 11)),
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

  Widget _buildFCLContainerRow(int index, Map<String, dynamic> container,
      Color surfaceDark, Color primaryColor) {
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Contenedor ${index + 1}",
                  style:
                      TextStyle(color: textColor, fontWeight: FontWeight.bold)),
              if (_fclContainerList.length > 1)
                IconButton(
                  icon: const Icon(Icons.remove_circle,
                      color: Colors.red, size: 20),
                  onPressed: () => _removeFCLContainer(index),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
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
                          color: surfaceDark,
                          borderRadius: BorderRadius.circular(6)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: container['type'] as String,
                          isExpanded: true,
                          dropdownColor: surfaceDark,
                          style: TextStyle(color: textColor, fontSize: 13),
                          items: _containerTypes.map((type) {
                            return DropdownMenuItem(
                                value: type['code'] as String,
                                child:
                                    Text("${type['code']} - ${type['name']}"));
                          }).toList(),
                          onChanged: (value) =>
                              setState(() => container['type'] = value),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
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
                          color: surfaceDark,
                          borderRadius: BorderRadius.circular(6)),
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
                                    color: Colors.grey, size: 16)),
                          ),
                          Text('${container['quantity']}',
                              style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold)),
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
                                    color: primaryColor, size: 16)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
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
                      style: TextStyle(color: textColor, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: "10000",
                        hintStyle:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                        filled: true,
                        fillColor: surfaceDark,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 10),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide.none),
                      ),
                      onChanged: (_) => setState(() {}),
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

  Widget _buildLCLTab(Color surfaceDark, Color primaryColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final infoTextColor = isDark ? Colors.blue[200] : Colors.blue[800];
    final labelColor = isDark ? Colors.grey[400] : Colors.grey[600];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                            color: surfaceDark,
                            borderRadius: BorderRadius.circular(8)),
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
                                        fontWeight: FontWeight.w600)),
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
                                        fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                          color: surfaceDark,
                          borderRadius: BorderRadius.circular(8)),
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
                                      fontWeight: FontWeight.w500)),
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
                                      fontWeight: FontWeight.w500)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (!_lclManualMode) ...[
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
                      return _buildBultoItem(
                          entry.key, entry.value, surfaceDark, primaryColor);
                    }),
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
                                      color: labelColor, fontSize: 10)),
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
                                      color: labelColor, fontSize: 10)),
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
                              style:
                                  TextStyle(color: infoTextColor, fontSize: 12),
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
                            child: _buildInputField(
                                "Total CBM",
                                _lclTotalCbmController,
                                surfaceDark,
                                Colors.blue,
                                keyboardType: TextInputType.number,
                                suffix: "m³")),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildInputField(
                                "Peso Total (Kg)",
                                _lclTotalWeightController,
                                surfaceDark,
                                Colors.blue,
                                keyboardType: TextInputType.number,
                                suffix: "kg")),
                      ],
                    ),
                  ],
                  const SizedBox(height: 20),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 12),
                  _buildLabel("¿La carga es APILABLE?"),
                  _buildDropdown(_lclIsStackable,
                      (v) => setState(() => _lclIsStackable = v), surfaceDark, [
                    const DropdownMenuItem(
                        value: 'Si', child: Text('Sí, es apilable')),
                    const DropdownMenuItem(
                        value: 'No', child: Text('No, no es apilable')),
                  ]),
                  const SizedBox(height: 12),
                  _buildLabel("¿Es carga PELIGROSA/DG CARGO/IMO?"),
                  _buildDropdown(_lclIsDangerous,
                      (v) => setState(() => _lclIsDangerous = v), surfaceDark, [
                    const DropdownMenuItem(value: 'No', child: Text('No')),
                    const DropdownMenuItem(
                        value: 'Si', child: Text('Sí, es carga peligrosa')),
                  ]),
                  const SizedBox(height: 12),
                  _buildLabel("Comentarios Adicionales (Opcional)"),
                  TextField(
                    controller: _lclCommentsController,
                    maxLines: 2,
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color),
                    decoration: InputDecoration(
                      hintText: "Ingrese cualquier comentario adicional...",
                      hintStyle:
                          const TextStyle(color: Colors.grey, fontSize: 12),
                      filled: true,
                      fillColor: surfaceDark,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none),
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
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: surfaceDark,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Pieza ${index + 1}",
                  style:
                      TextStyle(color: textColor, fontWeight: FontWeight.bold)),
              if (_bultosList.length > 1)
                IconButton(
                  icon: const Icon(Icons.remove_circle,
                      color: Colors.red, size: 20),
                  onPressed: () => _removeBulto(index),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 12),
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
          Row(
            children: [
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
                            color: surfaceDark,
                            borderRadius: BorderRadius.circular(6)),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () => setState(() => bulto['cantidad'] =
                                    ((bulto['cantidad'] as int) - 1)
                                        .clamp(1, 999)),
                                child: const Padding(
                                    padding: EdgeInsets.all(6),
                                    child: Icon(Icons.remove,
                                        color: Colors.grey, size: 16)),
                              ),
                              Text('${bulto['cantidad']}',
                                  style: TextStyle(
                                      color: textColor,
                                      fontWeight: FontWeight.bold)),
                              InkWell(
                                onTap: () => setState(() => bulto['cantidad'] =
                                    ((bulto['cantidad'] as int) + 1)
                                        .clamp(1, 999)),
                                child: Padding(
                                    padding: const EdgeInsets.all(6),
                                    child: Icon(Icons.add,
                                        color: primaryColor, size: 16)),
                              ),
                            ]),
                      ),
                    ]),
              ),
              const SizedBox(width: 12),
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
                            color: surfaceDark,
                            borderRadius: BorderRadius.circular(6)),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: bulto['embalaje'] as String,
                            isExpanded: true,
                            dropdownColor: surfaceDark,
                            style: TextStyle(color: textColor, fontSize: 13),
                            items: _embalajeTypes
                                .map((type) => DropdownMenuItem(
                                    value: type, child: Text(type)))
                                .toList(),
                            onChanged: (value) =>
                                setState(() => bulto['embalaje'] = value),
                          ),
                        ),
                      ),
                    ]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============ AIR TAB ============
  Widget _buildAirTab(Color surfaceDark, Color primaryColor) {
    if (_airPiezasList.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _addAirPieza());
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final infoTextColor = isDark ? Colors.amber[200] : Colors.brown[700];
    final labelColor = isDark ? Colors.grey[400] : Colors.grey[600];

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
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                            color: surfaceDark,
                            borderRadius: BorderRadius.circular(8)),
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
                                    borderRadius: BorderRadius.circular(4)),
                                child: Text("CM",
                                    style: TextStyle(
                                        color: !_airUseInches
                                            ? Colors.black
                                            : Colors.grey,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600)),
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
                                    borderRadius: BorderRadius.circular(4)),
                                child: Text("IN",
                                    style: TextStyle(
                                        color: _airUseInches
                                            ? Colors.black
                                            : Colors.grey,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
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
                  ..._airPiezasList.asMap().entries.map((entry) {
                    return _buildAirPiezaItem(
                        entry.key, entry.value, surfaceDark, Colors.amber);
                  }),
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
                                          color: labelColor, fontSize: 10)),
                                  Text("${_totalAirCbm.toStringAsFixed(3)} m³",
                                      style: const TextStyle(
                                          color: Colors.amber,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14)),
                                ]),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text("Peso Real",
                                      style: TextStyle(
                                          color: labelColor, fontSize: 10)),
                                  Text(
                                      "${_totalAirWeight.toStringAsFixed(0)} Kg",
                                      style: const TextStyle(
                                          color: Colors.amber,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14)),
                                ]),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text("Peso Vol.",
                                      style: TextStyle(
                                          color: labelColor, fontSize: 10)),
                                  Text(
                                      "${_airVolumetricWeight.toStringAsFixed(1)} Kg",
                                      style: const TextStyle(
                                          color: Colors.amber,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14)),
                                ]),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                            "Se cobra el mayor: peso real vs volumétrico (L×A×H/${_airUseInches ? '366' : '6000'})",
                            style:
                                TextStyle(color: infoTextColor, fontSize: 10)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 12),
                  _buildLabel("¿La carga es APILABLE?"),
                  _buildDropdown(_airIsStackable,
                      (v) => setState(() => _airIsStackable = v), surfaceDark, [
                    const DropdownMenuItem(
                        value: 'Si', child: Text('Sí, es apilable')),
                    const DropdownMenuItem(
                        value: 'No', child: Text('No, no es apilable')),
                  ]),
                  const SizedBox(height: 12),
                  _buildLabel("¿Es carga PELIGROSA/DG CARGO/IMO?"),
                  _buildDropdown(_airIsDangerous,
                      (v) => setState(() => _airIsDangerous = v), surfaceDark, [
                    const DropdownMenuItem(value: 'No', child: Text('No')),
                    const DropdownMenuItem(
                        value: 'Si', child: Text('Sí, es carga peligrosa')),
                  ]),
                  const SizedBox(height: 12),
                  _buildLabel("Comentarios Adicionales (Opcional)"),
                  TextField(
                    controller: _airCommentsController,
                    maxLines: 2,
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color),
                    decoration: InputDecoration(
                      hintText: "Ingrese cualquier comentario adicional...",
                      hintStyle:
                          const TextStyle(color: Colors.grey, fontSize: 12),
                      filled: true,
                      fillColor: surfaceDark,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none),
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

  Widget _buildAirPiezaItem(int index, Map<String, dynamic> pieza,
      Color surfaceDark, Color accentColor) {
    String unitLabel = _airUseInches ? 'in' : 'cm';
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: surfaceDark,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Pieza ${index + 1}",
                  style:
                      TextStyle(color: textColor, fontWeight: FontWeight.bold)),
              if (_airPiezasList.length > 1)
                IconButton(
                  icon: const Icon(Icons.remove_circle,
                      color: Colors.red, size: 20),
                  onPressed: () => _removeAirPieza(index),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 12),
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
          Row(
            children: [
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
                            color: surfaceDark,
                            borderRadius: BorderRadius.circular(6)),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () => setState(() => pieza['cantidad'] =
                                    ((pieza['cantidad'] as int) - 1)
                                        .clamp(1, 999)),
                                child: const Padding(
                                    padding: EdgeInsets.all(6),
                                    child: Icon(Icons.remove,
                                        color: Colors.grey, size: 16)),
                              ),
                              Text('${pieza['cantidad']}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                              InkWell(
                                onTap: () => setState(() => pieza['cantidad'] =
                                    ((pieza['cantidad'] as int) + 1)
                                        .clamp(1, 999)),
                                child: Padding(
                                    padding: const EdgeInsets.all(6),
                                    child: Icon(Icons.add,
                                        color: accentColor, size: 16)),
                              ),
                            ]),
                      ),
                    ]),
              ),
              const SizedBox(width: 12),
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
                            color: surfaceDark,
                            borderRadius: BorderRadius.circular(6)),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: pieza['embalaje'] as String,
                            isExpanded: true,
                            dropdownColor: surfaceDark,
                            style: TextStyle(color: textColor, fontSize: 13),
                            items: _embalajeTypes
                                .map((type) => DropdownMenuItem(
                                    value: type, child: Text(type)))
                                .toList(),
                            onChanged: (value) =>
                                setState(() => pieza['embalaje'] = value),
                          ),
                        ),
                      ),
                    ]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============ SHARED FIELDS ============
  Widget _buildSharedFields(Color surfaceDark, Color primaryColor) {
    final isAirMode = _tabController.index == 2;
    // NUEVO: Usar países reales desde MasterDataService
    final countriesList = _masterData.countries;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    return Column(
      children: [
        NeonCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCardTitle(isAirMode ? Icons.flight : Icons.route,
                  isAirMode ? "Ruta Aérea" : "Ruta Marítima", primaryColor),
              const SizedBox(height: 16),
              // Origin POL (CONECTADO A PUERTOS REALES)
              PortAutocompleteField(
                label: isAirMode ? "Aeropuerto Origen" : "Puerto Origen (POL)",
                hint: isAirMode
                    ? "Ej: Miami, Shanghai..."
                    : "Ej: Shanghai, Ningbo...",
                controller: _originController,
                isAirport: isAirMode,
                isDestination: false,
                accentColor: primaryColor,
                backgroundColor: surfaceDark,
              ),
              const SizedBox(height: 12),
              // Destination POD (CONECTADO A CIUDADES/PUERTOS REALES)
              PortAutocompleteField(
                label: isAirMode
                    ? "Aeropuerto Destino (Ecuador)"
                    : "Puerto Destino (POD - Ecuador)",
                hint: isAirMode
                    ? "Quito (UIO), Guayaquil (GYE)..."
                    : "Guayaquil (GYE), Manta...",
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
              // Country Dropdown (CONECTADO A PAÍSES REALES)
              _buildLabel("País de Origen/Fabricación"),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                    color: surfaceDark, borderRadius: BorderRadius.circular(8)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedOriginCountry,
                    isExpanded: true,
                    dropdownColor: surfaceDark,
                    hint: const Text("Seleccione país de origen...",
                        style: TextStyle(color: Colors.grey)),
                    style: TextStyle(color: textColor),
                    // AQUÍ ESTÁ LA MAGIA:
                    items: countriesList.isEmpty
                        ? [] // Si carga, vacío o loader
                        : countriesList.map((country) {
                            return DropdownMenuItem(
                                value: country.nombre,
                                child: Text(country.nombre));
                          }).toList(),
                    onChanged: (value) =>
                        setState(() => _selectedOriginCountry = value),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildInputField("Código HS (Opcional)", _hsCodeController,
                  surfaceDark, primaryColor,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 8),
              const Text(
                  "Si conoce el código arancelario, ingréselo aquí. De lo contrario, nuestra IA lo clasificará.",
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                      fontStyle: FontStyle.italic)),
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
              _buildCurrencyInput(
                  "Valor FOB (USD)", _fobController, surfaceDark, primaryColor),
              const SizedBox(height: 12),
              // Incoterms (CONECTADO A MASTERDATA)
              _buildIncotermDropdown(surfaceDark, primaryColor),
              const SizedBox(height: 12),
              _buildInsuranceToggle(primaryColor),
            ],
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  // ============ HELPER WIDGETS ============
  Widget _buildCardTitle(IconData icon, String text, Color color) {
    return Row(children: [
      Icon(icon, color: color, size: 20),
      const SizedBox(width: 8),
      Text(text, style: Theme.of(context).textTheme.titleSmall)
    ]);
  }

  Widget _buildLabel(String text) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(color: Colors.grey, fontSize: 12)));
  }

  Widget _buildInputField(
      String label, TextEditingController controller, Color bg, Color accent,
      {TextInputType? keyboardType, String? suffix}) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildLabel(label),
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
            filled: true,
            fillColor: bg,
            hintStyle: const TextStyle(color: Colors.grey),
            suffixText: suffix,
            suffixStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: accent))),
      ),
    ]);
  }

  Widget _buildCurrencyInput(
      String label, TextEditingController controller, Color bg, Color accent) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildLabel(label),
      TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
            prefixText: "\$ ",
            prefixStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: bg,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: accent))),
      ),
    ]);
  }

  Widget _buildDropdown(String? value, ValueChanged<String?> onChanged,
      Color bg, List<DropdownMenuItem<String>> items) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: bg,
          style: TextStyle(color: textColor),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildIncotermDropdown(Color bg, Color accent) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    // Usar datos reales de MasterDataService si existen, sino fallback
    final incotermList = _masterData.incoterms.isNotEmpty
        ? _masterData.incoterms.map((i) => i.code).toList()
        : ["FOB", "CIF", "EXW", "DDP", "CFR"];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("Incoterm"),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration:
              BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _incoterm,
              isExpanded: true,
              dropdownColor: bg,
              icon: Icon(Icons.expand_more, color: accent),
              style: TextStyle(color: textColor),
              items: incotermList
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
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
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
              color: _includeInsurance
                  ? accent
                  : Colors.grey.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(
                _includeInsurance
                    ? Icons.check_box
                    : Icons.check_box_outline_blank,
                color: _includeInsurance ? accent : Colors.grey),
            const SizedBox(width: 12),
            Expanded(
                child: Text("Incluir Seguro Internacional (0.35% del CFR)",
                    style: TextStyle(color: textColor, fontSize: 14))),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallInput(
      String hint, TextEditingController controller, Color bg) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: TextStyle(color: textColor, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
        filled: true,
        fillColor: bg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildSubmitButton(Color primaryColor, Color bgDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: bgDark.withValues(alpha: 0.95),
          border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.05)))),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: _isSubmitting ? null : _submitQuote,
          style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16))),
          icon: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.black))
              : const Icon(Icons.send),
          label: Text(_isSubmitting ? "Enviando..." : "Solicitar Cotización",
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
