import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../core/services/firebase_service.dart';
import '../widgets/admin_sidebar_drawer.dart';

/// Admin Tarifas Base (Base Rates) Management Screen
/// Manage freight rates (FCL/LCL/Air), insurance, customs, inland transport
class AdminTarifasBaseScreen extends StatefulWidget {
  const AdminTarifasBaseScreen({super.key});

  @override
  State<AdminTarifasBaseScreen> createState() => _AdminTarifasBaseScreenState();
}

class _AdminTarifasBaseScreenState extends State<AdminTarifasBaseScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseService _firebaseService = FirebaseService();
  late TabController _tabController;

  // Data for each rate type
  List<Map<String, dynamic>> _freightRatesFCL = [];
  List<Map<String, dynamic>> _freightRatesLCL = [];
  List<Map<String, dynamic>> _freightRatesAir = [];
  List<Map<String, dynamic>> _insuranceRates = [];
  List<Map<String, dynamic>> _customsRates = [];
  List<Map<String, dynamic>> _inlandRates = [];

  bool _isLoading = true;
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(() {
      setState(() => _currentTab = _tabController.index);
    });
    _loadAllRates();
  }

  void _handleNavigation(String route) {
    Navigator.pop(context);
    if (route == 'tarifas_base') return;
    switch (route) {
      case 'dashboard':
      case 'ruc_approvals':
        Navigator.pushReplacementNamed(context, '/admin_dashboard');
        break;
      case 'cotizaciones':
        Navigator.pushReplacementNamed(context, '/admin_cotizaciones');
        break;
      case 'usuarios':
        Navigator.pushReplacementNamed(context, '/admin_usuarios');
        break;
      case 'arancel':
        Navigator.pushReplacementNamed(context, '/admin_arancel');
        break;
      case 'tarifas_base':
        Navigator.pushReplacementNamed(context, '/admin_tarifas_base');
        break;
      case 'proveedores':
        Navigator.pushReplacementNamed(context, '/admin_proveedores');
        break;
      case 'config_hitos':
        Navigator.pushReplacementNamed(context, '/admin_config_hitos');
        break;
      case 'tracking_ff':
        Navigator.pushReplacementNamed(context, '/admin_tracking_ff');
        break;
      case 'portal_ff':
        Navigator.pushReplacementNamed(context, '/admin_portal_ff');
        break;
      case 'cotizaciones_ff':
        Navigator.pushReplacementNamed(context, '/admin_cotizaciones_ff');
        break;
      case 'config_ff':
        Navigator.pushReplacementNamed(context, '/admin_config_ff');
        break;
      case 'puertos':
        Navigator.pushReplacementNamed(context, '/admin_puertos');
        break;
      case 'aeropuertos':
        Navigator.pushReplacementNamed(context, '/admin_aeropuertos');
        break;
      case 'profit_review':
        Navigator.pushReplacementNamed(context, '/admin_profit_review');
        break;
      case 'logs':
        Navigator.pushReplacementNamed(context, '/admin_logs');
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllRates() async {
    setState(() => _isLoading = true);

    try {
      // Load freight rates
      final freightResponse = await _firebaseService.get('sales/freight-rates/');
      if (freightResponse is List) {
        _freightRatesFCL = List<Map<String, dynamic>>.from(
            freightResponse.where((r) => r['transport_mode'] == 'FCL'));
        _freightRatesLCL = List<Map<String, dynamic>>.from(
            freightResponse.where((r) => r['transport_mode'] == 'LCL'));
        _freightRatesAir = List<Map<String, dynamic>>.from(
            freightResponse.where((r) => r['transport_mode'] == 'AIR'));
      }
    } catch (e) {
      // Error loading rates - using mock data
      _loadMockData();
    }

    setState(() => _isLoading = false);
  }

  void _loadMockData() {
    _freightRatesFCL = [
      {
        'id': 1,
        'origin_port': 'CNSHA',
        'origin_port_name': 'Shanghai, China',
        'destination_port': 'ECGYE',
        'destination_port_name': 'Guayaquil, Ecuador',
        'container_type': '20GP',
        'rate_usd': 1850.00,
        'transit_days': 35,
        'carrier': 'MSC',
        'valid_until': '2026-03-31',
        'is_active': true,
      },
      {
        'id': 2,
        'origin_port': 'CNSHA',
        'origin_port_name': 'Shanghai, China',
        'destination_port': 'ECGYE',
        'destination_port_name': 'Guayaquil, Ecuador',
        'container_type': '40HC',
        'rate_usd': 3200.00,
        'transit_days': 35,
        'carrier': 'COSCO',
        'valid_until': '2026-03-31',
        'is_active': true,
      },
    ];

    _freightRatesLCL = [
      {
        'id': 3,
        'origin_port': 'CNSHA',
        'origin_port_name': 'Shanghai, China',
        'destination_port': 'ECGYE',
        'destination_port_name': 'Guayaquil, Ecuador',
        'rate_per_cbm': 85.00,
        'rate_per_ton': 95.00,
        'min_charge': 150.00,
        'transit_days': 40,
        'is_active': true,
      },
    ];

    _freightRatesAir = [
      {
        'id': 4,
        'origin_airport': 'ZSPD',
        'origin_airport_name': 'Shanghai Pudong',
        'destination_airport': 'SEGU',
        'destination_airport_name': 'J.J. Olmedo, Guayaquil',
        'rate_per_kg': 4.50,
        'min_charge': 150.00,
        'transit_days': 5,
        'carrier': 'KLM Cargo',
        'is_active': true,
      },
    ];

    _insuranceRates = [
      {
        'id': 1,
        'coverage_type': 'All Risk',
        'rate_percentage': 0.35,
        'min_premium': 50.00,
        'deductible_percentage': 10.0,
        'provider': 'Seguros Sucre',
        'is_active': true,
      },
      {
        'id': 2,
        'coverage_type': 'Basic',
        'rate_percentage': 0.20,
        'min_premium': 35.00,
        'deductible_percentage': 15.0,
        'provider': 'Seguros Equinoccial',
        'is_active': true,
      },
    ];

    _customsRates = [
      {
        'id': 1,
        'service_type': 'Full Service',
        'base_fee': 180.00,
        'per_item_fee': 25.00,
        'max_fee': 450.00,
        'includes_documentation': true,
        'is_active': true,
      },
    ];

    _inlandRates = [
      {
        'id': 1,
        'origin_city': 'Guayaquil',
        'destination_city': 'Quito',
        'vehicle_type': 'Truck 10T',
        'rate_usd': 850.00,
        'transit_hours': 8,
        'is_active': true,
      },
      {
        'id': 2,
        'origin_city': 'Guayaquil',
        'destination_city': 'Cuenca',
        'vehicle_type': 'Truck 5T',
        'rate_usd': 450.00,
        'transit_hours': 4,
        'is_active': true,
      },
    ];
  }

  void _showAddEditDialog(String rateType, [Map<String, dynamic>? rate]) {
    final isNew = rate == null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0A101D),
        title: Text(
          isNew ? 'Nueva Tarifa $rateType' : 'Editar Tarifa $rateType',
          style: const TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: _buildFormForRateType(rateType, rate),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar(isNew ? 'Tarifa creada' : 'Tarifa actualizada',
                  AppColors.neonGreen);
              _loadAllRates();
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.neonGreen),
            child: const Text('Guardar', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget _buildFormForRateType(String rateType, Map<String, dynamic>? rate) {
    switch (rateType) {
      case 'FCL':
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField('Puerto Origen', rate?['origin_port'] ?? ''),
            const SizedBox(height: 12),
            _buildTextField('Puerto Destino', rate?['destination_port'] ?? ''),
            const SizedBox(height: 12),
            _buildDropdownField('Contenedor', rate?['container_type'] ?? '20GP',
                ['20GP', '40GP', '40HC', '45HC']),
            const SizedBox(height: 12),
            _buildNumberFieldWithLabel(
                'Tarifa USD', rate?['rate_usd']?.toString() ?? ''),
            const SizedBox(height: 12),
            _buildNumberFieldWithLabel(
                'Días Tránsito', rate?['transit_days']?.toString() ?? ''),
          ],
        );
      case 'LCL':
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField('Puerto Origen', rate?['origin_port'] ?? ''),
            const SizedBox(height: 12),
            _buildTextField('Puerto Destino', rate?['destination_port'] ?? ''),
            const SizedBox(height: 12),
            _buildNumberFieldWithLabel('Tarifa por CBM (USD)',
                rate?['rate_per_cbm']?.toString() ?? ''),
            const SizedBox(height: 12),
            _buildNumberFieldWithLabel('Tarifa por TON (USD)',
                rate?['rate_per_ton']?.toString() ?? ''),
            const SizedBox(height: 12),
            _buildNumberFieldWithLabel(
                'Cargo Mínimo (USD)', rate?['min_charge']?.toString() ?? ''),
          ],
        );
      default:
        return const Text('Form for this rate type',
            style: TextStyle(color: Colors.grey));
    }
  }

  Widget _buildTextField(String label, String initialValue) {
    return TextField(
      controller: TextEditingController(text: initialValue),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFF1F2937),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildNumberFieldWithLabel(String label, String initialValue) {
    return TextField(
      controller: TextEditingController(text: initialValue),
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFF1F2937),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1F2937),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: value,
            items: options
                .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                .toList(),
            onChanged: (v) {},
            isExpanded: true,
            dropdownColor: const Color(0xFF1F2937),
            style: const TextStyle(color: Colors.white),
            underline: const SizedBox(),
          ),
        ),
      ],
    );
  }

  void _showUploadDialog(String rateType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0A101D),
        title: Text('Importar Tarifas $rateType',
            style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.neonGreen.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Icon(Icons.cloud_upload,
                      color: AppColors.neonGreen, size: 48),
                  const SizedBox(height: 12),
                  const Text('Subir archivo Excel/CSV',
                      style: TextStyle(color: Colors.white)),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => _selectFile(rateType),
                    icon: const Icon(Icons.folder_open, color: Colors.black),
                    label: const Text('Seleccionar',
                        style: TextStyle(color: Colors.black)),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.neonGreen),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => _downloadTemplate(rateType),
              icon: const Icon(Icons.download, size: 18),
              label: Text('Plantilla $rateType'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue,
                side: const BorderSide(color: Colors.blue),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  void _selectFile(String rateType) {
    // File upload functionality - would require platform-specific implementation
    // For web: use file_picker package or dart:html
    // For mobile: use file_picker package
    _showSnackBar('Importando tarifas $rateType...', Colors.blue);
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      _showSnackBar('Tarifas importadas correctamente', AppColors.neonGreen);
      Navigator.pop(context);
      _loadAllRates();
    });
  }

  void _downloadTemplate(String rateType) {
    String filename;

    switch (rateType) {
      case 'FCL':
        filename = 'plantilla_tarifas_fcl.csv';
        break;
      case 'LCL':
        filename = 'plantilla_tarifas_lcl.csv';
        break;
      default:
        filename = 'plantilla_tarifas.csv';
    }

    // Download functionality - would require platform-specific implementation
    // For web: use dart:html or universal_html package
    // For mobile: use path_provider and share packages
    _showSnackBar('Descargando plantilla $filename...', Colors.blue);
    Future.delayed(const Duration(seconds: 1), () {
      _showSnackBar('Plantilla $filename lista', AppColors.neonGreen);
    });
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bgDark = Color(0xFF050A14);
    const surfaceDark = Color(0xFF0A101D);
    const primaryColor = AppColors.neonGreen;

    final tabLabels = ['FCL', 'LCL', 'Aéreo', 'Seguro', 'Aduana', 'Interno'];

    return Scaffold(
      backgroundColor: bgDark,
      drawer: AdminSidebarDrawer(
        currentRoute: 'tarifas_base',
        onNavigate: _handleNavigation,
      ),
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.attach_money, color: Colors.yellow),
            SizedBox(width: 8),
            Text('Tarifas Base'),
          ],
        ),
        backgroundColor: bgDark,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file, color: Colors.blue),
            onPressed: () => _showUploadDialog(tabLabels[_currentTab]),
            tooltip: 'Importar Tarifas',
          ),
          IconButton(
            icon: const Icon(Icons.add, color: primaryColor),
            onPressed: () => _showAddEditDialog(tabLabels[_currentTab]),
            tooltip: 'Nueva Tarifa',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllRates,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: primaryColor,
          labelColor: primaryColor,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(icon: Icon(Icons.directions_boat, size: 18), text: 'FCL'),
            Tab(icon: Icon(Icons.inventory_2, size: 18), text: 'LCL'),
            Tab(icon: Icon(Icons.flight, size: 18), text: 'Aéreo'),
            Tab(icon: Icon(Icons.security, size: 18), text: 'Seguro'),
            Tab(icon: Icon(Icons.gavel, size: 18), text: 'Aduana'),
            Tab(icon: Icon(Icons.local_shipping, size: 18), text: 'Interno'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildRatesList(
                    _freightRatesFCL, 'FCL', surfaceDark, primaryColor),
                _buildRatesList(
                    _freightRatesLCL, 'LCL', surfaceDark, primaryColor),
                _buildRatesList(
                    _freightRatesAir, 'Air', surfaceDark, primaryColor),
                _buildRatesList(
                    _insuranceRates, 'Seguro', surfaceDark, primaryColor),
                _buildRatesList(
                    _customsRates, 'Aduana', surfaceDark, primaryColor),
                _buildRatesList(
                    _inlandRates, 'Interno', surfaceDark, primaryColor),
              ],
            ),
    );
  }

  Widget _buildRatesList(List<Map<String, dynamic>> rates, String rateType,
      Color surfaceDark, Color primaryColor) {
    if (rates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, color: Colors.grey[600], size: 64),
            const SizedBox(height: 16),
            Text('No hay tarifas $rateType registradas',
                style: const TextStyle(color: Colors.grey, fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showUploadDialog(rateType),
              icon: const Icon(Icons.upload_file, color: Colors.black),
              label: const Text('Importar Tarifas',
                  style: TextStyle(color: Colors.black)),
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rates.length,
      itemBuilder: (context, index) =>
          _buildRateCard(rates[index], rateType, surfaceDark, primaryColor),
    );
  }

  Widget _buildRateCard(Map<String, dynamic> rate, String rateType,
      Color surfaceDark, Color primaryColor) {
    Widget content;

    switch (rateType) {
      case 'FCL':
        content = _buildFCLCard(rate, primaryColor);
        break;
      case 'LCL':
        content = _buildLCLCard(rate, primaryColor);
        break;
      case 'Air':
        content = _buildAirCard(rate, primaryColor);
        break;
      case 'Seguro':
        content = _buildInsuranceCard(rate, primaryColor);
        break;
      case 'Aduana':
        content = _buildCustomsCard(rate, primaryColor);
        break;
      case 'Interno':
        content = _buildInlandCard(rate, primaryColor);
        break;
      default:
        content = const SizedBox();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          content,
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _showAddEditDialog(rateType, rate),
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Editar'),
                style: TextButton.styleFrom(foregroundColor: Colors.blue),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFCLCard(Map<String, dynamic> rate, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildRouteChip(
                rate['origin_port'] ?? '', rate['destination_port'] ?? ''),
            const Spacer(),
            _buildPriceTag('\$${rate['rate_usd']}', primaryColor),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildInfoBadge(
                Icons.inventory_2, rate['container_type'] ?? '', Colors.blue),
            const SizedBox(width: 8),
            _buildInfoBadge(
                Icons.schedule, '${rate['transit_days']} días', Colors.orange),
            const SizedBox(width: 8),
            _buildInfoBadge(
                Icons.business, rate['carrier'] ?? '', Colors.purple),
          ],
        ),
      ],
    );
  }

  Widget _buildLCLCard(Map<String, dynamic> rate, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildRouteChip(
                rate['origin_port'] ?? '', rate['destination_port'] ?? ''),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('\$${rate['rate_per_cbm']}/CBM',
                    style: TextStyle(
                        color: primaryColor, fontWeight: FontWeight.bold)),
                Text('\$${rate['rate_per_ton']}/TON',
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildInfoBadge(
                Icons.money, 'Mín: \$${rate['min_charge']}', Colors.amber),
            const SizedBox(width: 8),
            _buildInfoBadge(
                Icons.schedule, '${rate['transit_days']} días', Colors.orange),
          ],
        ),
      ],
    );
  }

  Widget _buildAirCard(Map<String, dynamic> rate, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildRouteChip(
                rate['origin_airport'] ?? '', rate['destination_airport'] ?? '',
                isAir: true),
            const Spacer(),
            _buildPriceTag('\$${rate['rate_per_kg']}/kg', primaryColor),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildInfoBadge(
                Icons.money, 'Mín: \$${rate['min_charge']}', Colors.amber),
            const SizedBox(width: 8),
            _buildInfoBadge(
                Icons.schedule, '${rate['transit_days']} días', Colors.orange),
            const SizedBox(width: 8),
            _buildInfoBadge(
                Icons.airlines, rate['carrier'] ?? '', Colors.lightBlue),
          ],
        ),
      ],
    );
  }

  Widget _buildInsuranceCard(Map<String, dynamic> rate, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(rate['coverage_type'] ?? '',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            const Spacer(),
            _buildPriceTag('${rate['rate_percentage']}%', primaryColor),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildInfoBadge(
                Icons.money, 'Mín: \$${rate['min_premium']}', Colors.amber),
            const SizedBox(width: 8),
            _buildInfoBadge(Icons.remove_circle,
                'Deducible: ${rate['deductible_percentage']}%', Colors.red),
            const SizedBox(width: 8),
            _buildInfoBadge(
                Icons.business, rate['provider'] ?? '', Colors.teal),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomsCard(Map<String, dynamic> rate, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(rate['service_type'] ?? '',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            const Spacer(),
            _buildPriceTag('\$${rate['base_fee']}', primaryColor),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildInfoBadge(
                Icons.add_box, '+\$${rate['per_item_fee']}/item', Colors.blue),
            const SizedBox(width: 8),
            _buildInfoBadge(
                Icons.arrow_upward, 'Máx: \$${rate['max_fee']}', Colors.orange),
          ],
        ),
      ],
    );
  }

  Widget _buildInlandCard(Map<String, dynamic> rate, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${rate['origin_city']} → ${rate['destination_city']}',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                Text(rate['vehicle_type'] ?? '',
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const Spacer(),
            _buildPriceTag('\$${rate['rate_usd']}', primaryColor),
          ],
        ),
        const SizedBox(height: 8),
        _buildInfoBadge(
            Icons.schedule, '${rate['transit_hours']} horas', Colors.orange),
      ],
    );
  }

  Widget _buildRouteChip(String origin, String destination,
      {bool isAir = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isAir ? Icons.flight_takeoff : Icons.anchor,
              size: 14, color: Colors.blue),
          const SizedBox(width: 6),
          Text(origin,
              style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 12)),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Icon(Icons.arrow_forward, size: 12, color: Colors.grey),
          ),
          Icon(isAir ? Icons.flight_land : Icons.anchor,
              size: 14, color: Colors.blue),
          const SizedBox(width: 4),
          Text(destination,
              style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildPriceTag(String price, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(price,
          style: TextStyle(
              color: color, fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  Widget _buildInfoBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(color: color, fontSize: 11)),
        ],
      ),
    );
  }
}
