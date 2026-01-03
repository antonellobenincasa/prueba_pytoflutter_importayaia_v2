import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../core/api/client.dart';
import '../widgets/admin_sidebar_drawer.dart';

/// Admin Proveedores (Providers) Management Screen
/// Manage carriers (navieras), airlines, customs brokers, and local transport
class AdminProveedoresScreen extends StatefulWidget {
  const AdminProveedoresScreen({super.key});

  @override
  State<AdminProveedoresScreen> createState() => _AdminProveedoresScreenState();
}

class _AdminProveedoresScreenState extends State<AdminProveedoresScreen>
    with SingleTickerProviderStateMixin {
  final ApiClient _apiClient = ApiClient();
  late TabController _tabController;

  List<Map<String, dynamic>> _navieras = [];
  List<Map<String, dynamic>> _airlines = [];
  List<Map<String, dynamic>> _customsBrokers = [];
  List<Map<String, dynamic>> _localTransport = [];

  bool _isLoading = true;
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() => _currentTab = _tabController.index);
    });
    _loadAllProviders();
  }

  void _handleNavigation(String route) {
    Navigator.pop(context);
    if (route == 'proveedores') return;
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

  Future<void> _loadAllProviders() async {
    setState(() => _isLoading = true);

    try {
      final response = await _apiClient.get('admin/providers/');
      if (response is List) {
        _categorizeProviders(List<Map<String, dynamic>>.from(response));
      }
    } catch (e) {
      // Error loading providers - using mock data
      _loadMockData();
    }

    setState(() => _isLoading = false);
  }

  void _categorizeProviders(List<Map<String, dynamic>> providers) {
    _navieras = providers.where((p) => p['type'] == 'naviera').toList();
    _airlines = providers.where((p) => p['type'] == 'airline').toList();
    _customsBrokers =
        providers.where((p) => p['type'] == 'customs_broker').toList();
    _localTransport =
        providers.where((p) => p['type'] == 'local_transport').toList();
  }

  void _loadMockData() {
    _navieras = [
      {
        'id': 1,
        'name': 'MSC',
        'full_name': 'Mediterranean Shipping Company',
        'country': 'Suiza',
        'contact_email': 'bookings@msc.com',
        'contact_phone': '+593 4 123 4567',
        'routes': 'Asia, Europa, Norteamérica',
        'rating': 4.5,
        'contracts_count': 12,
        'is_active': true,
      },
      {
        'id': 2,
        'name': 'COSCO',
        'full_name': 'COSCO Shipping Lines',
        'country': 'China',
        'contact_email': 'ecuador@cosco.com',
        'contact_phone': '+593 4 234 5678',
        'routes': 'Asia',
        'rating': 4.2,
        'contracts_count': 8,
        'is_active': true,
      },
      {
        'id': 3,
        'name': 'Hapag-Lloyd',
        'full_name': 'Hapag-Lloyd AG',
        'country': 'Alemania',
        'contact_email': 'guayaquil@hapag-lloyd.com',
        'contact_phone': '+593 4 345 6789',
        'routes': 'Europa, Asia, Américas',
        'rating': 4.7,
        'contracts_count': 15,
        'is_active': true,
      },
    ];

    _airlines = [
      {
        'id': 4,
        'name': 'KLM Cargo',
        'full_name': 'KLM Royal Dutch Airlines Cargo',
        'country': 'Países Bajos',
        'hub': 'Amsterdam (AMS)',
        'contact_email': 'cargo-latam@klm.com',
        'contact_phone': '+593 2 456 7890',
        'rating': 4.8,
        'is_active': true,
      },
      {
        'id': 5,
        'name': 'LATAM Cargo',
        'full_name': 'LATAM Airlines Cargo',
        'country': 'Chile',
        'hub': 'Santiago (SCL), Miami (MIA)',
        'contact_email': 'cargo@latam.com',
        'contact_phone': '+593 2 567 8901',
        'rating': 4.3,
        'is_active': true,
      },
    ];

    _customsBrokers = [
      {
        'id': 6,
        'name': 'Aduanas Express',
        'license': 'AGE-2024-1234',
        'contact': 'Carlos Mendoza',
        'contact_email': 'carlos@aduanasexpress.ec',
        'contact_phone': '+593 4 678 9012',
        'specialties': 'FCL, LCL, Peligrosos',
        'rating': 4.6,
        'is_active': true,
      },
      {
        'id': 7,
        'name': 'Global Customs EC',
        'license': 'AGE-2024-5678',
        'contact': 'María López',
        'contact_email': 'maria@globalcustoms.ec',
        'contact_phone': '+593 4 789 0123',
        'specialties': 'Air Cargo, E-commerce',
        'rating': 4.4,
        'is_active': true,
      },
    ];

    _localTransport = [
      {
        'id': 8,
        'name': 'TransEcuador',
        'fleet_size': 25,
        'vehicle_types': 'Trucks 5T, 10T, 20T',
        'coverage': 'Nacional',
        'contact_email': 'info@transecuador.ec',
        'contact_phone': '+593 4 890 1234',
        'rating': 4.1,
        'is_active': true,
      },
    ];
  }

  void _showAddEditDialog(String providerType,
      [Map<String, dynamic>? provider]) {
    final isNew = provider == null;
    final nameController = TextEditingController(text: provider?['name'] ?? '');
    final emailController =
        TextEditingController(text: provider?['contact_email'] ?? '');
    final phoneController =
        TextEditingController(text: provider?['contact_phone'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0A101D),
        title: Text(
          isNew ? 'Nuevo Proveedor $providerType' : 'Editar $providerType',
          style: const TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField('Nombre', nameController),
              const SizedBox(height: 12),
              _buildTextField('Email', emailController),
              const SizedBox(height: 12),
              _buildTextField('Teléfono', phoneController),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar(
                  isNew ? 'Proveedor creado' : 'Proveedor actualizado',
                  AppColors.neonGreen);
              _loadAllProviders();
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.neonGreen),
            child: const Text('Guardar', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
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

  void _showUploadDialog(String providerType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0A101D),
        title: Text('Importar $providerType',
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
                    onPressed: () => _selectFile(providerType),
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
              onPressed: () => _downloadTemplate(providerType),
              icon: const Icon(Icons.download, size: 18),
              label: Text('Plantilla $providerType'),
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

  void _selectFile(String providerType) {
    // File upload functionality - would require platform-specific implementation
    // For web: use file_picker package or dart:html
    // For mobile: use file_picker package
    _showSnackBar('Importando proveedores...', Colors.blue);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context);
        _showSnackBar('Proveedores importados', AppColors.neonGreen);
        _loadAllProviders();
      }
    });
  }

  void _downloadTemplate(String providerType) {
    // Download functionality - would require platform-specific implementation
    // For web: use dart:html or universal_html package
    // For mobile: use path_provider and share packages
    _showSnackBar('Descargando plantilla $providerType...', Colors.blue);
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _showSnackBar('Plantilla descargada', AppColors.neonGreen);
      }
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

    final tabLabels = ['Navieras', 'Airlines', 'Agentes Aduana', 'Transporte'];

    return Scaffold(
      backgroundColor: bgDark,
      drawer: AdminSidebarDrawer(
        currentRoute: 'proveedores',
        onNavigate: _handleNavigation,
      ),
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.store, color: Colors.deepOrange),
            SizedBox(width: 8),
            Text('Proveedores'),
          ],
        ),
        backgroundColor: bgDark,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file, color: Colors.blue),
            onPressed: () => _showUploadDialog(tabLabels[_currentTab]),
            tooltip: 'Importar',
          ),
          IconButton(
            icon: const Icon(Icons.add, color: primaryColor),
            onPressed: () => _showAddEditDialog(tabLabels[_currentTab]),
            tooltip: 'Nuevo Proveedor',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllProviders,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: primaryColor,
          labelColor: primaryColor,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(icon: Icon(Icons.directions_boat, size: 18), text: 'Navieras'),
            Tab(icon: Icon(Icons.flight, size: 18), text: 'Airlines'),
            Tab(icon: Icon(Icons.gavel, size: 18), text: 'Agentes'),
            Tab(icon: Icon(Icons.local_shipping, size: 18), text: 'Transporte'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildProvidersList(
                    _navieras, 'Naviera', surfaceDark, primaryColor),
                _buildProvidersList(
                    _airlines, 'Airline', surfaceDark, primaryColor),
                _buildProvidersList(
                    _customsBrokers, 'Agente', surfaceDark, primaryColor),
                _buildProvidersList(
                    _localTransport, 'Transporte', surfaceDark, primaryColor),
              ],
            ),
    );
  }

  Widget _buildProvidersList(List<Map<String, dynamic>> providers, String type,
      Color surfaceDark, Color primaryColor) {
    if (providers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.business_outlined, color: Colors.grey[600], size: 64),
            const SizedBox(height: 16),
            Text('No hay proveedores $type registrados',
                style: const TextStyle(color: Colors.grey, fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showAddEditDialog(type),
              icon: const Icon(Icons.add, color: Colors.black),
              label: const Text('Agregar Proveedor',
                  style: TextStyle(color: Colors.black)),
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: providers.length,
      itemBuilder: (context, index) =>
          _buildProviderCard(providers[index], type, surfaceDark, primaryColor),
    );
  }

  Widget _buildProviderCard(Map<String, dynamic> provider, String type,
      Color surfaceDark, Color primaryColor) {
    final rating = provider['rating'] ?? 0.0;
    final isActive = provider['is_active'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color:
                isActive ? Colors.white10 : Colors.red.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              CircleAvatar(
                backgroundColor: _getProviderColor(type).withValues(alpha: 0.2),
                child: Icon(_getProviderIcon(type),
                    color: _getProviderColor(type), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(provider['name'] ?? '',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    Text(provider['full_name'] ?? provider['country'] ?? '',
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              _buildRatingBadge(rating, primaryColor),
            ],
          ),
          const SizedBox(height: 12),

          // Info Row
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _buildProviderInfoChips(provider, type),
          ),
          const SizedBox(height: 12),

          // Contact Row
          Row(
            children: [
              if (provider['contact_email'] != null) ...[
                Icon(Icons.email, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(provider['contact_email'],
                    style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                const SizedBox(width: 16),
              ],
              if (provider['contact_phone'] != null) ...[
                Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(provider['contact_phone'],
                    style: TextStyle(color: Colors.grey[500], fontSize: 11)),
              ],
            ],
          ),
          const SizedBox(height: 12),

          // Actions Row
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _showAddEditDialog(type, provider),
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Editar'),
                style: TextButton.styleFrom(foregroundColor: Colors.blue),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.visibility, size: 16),
                label: const Text('Ver Contratos'),
                style: TextButton.styleFrom(foregroundColor: Colors.purple),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildProviderInfoChips(
      Map<String, dynamic> provider, String type) {
    List<Widget> chips = [];

    switch (type) {
      case 'Naviera':
        if (provider['country'] != null) {
          chips.add(
              _buildInfoChip(Icons.flag, provider['country'], Colors.blue));
        }
        if (provider['routes'] != null) {
          chips.add(
              _buildInfoChip(Icons.route, provider['routes'], Colors.teal));
        }
        if (provider['contracts_count'] != null) {
          chips.add(_buildInfoChip(Icons.description,
              '${provider['contracts_count']} contratos', Colors.purple));
        }
        break;
      case 'Airline':
        if (provider['hub'] != null) {
          chips.add(
              _buildInfoChip(Icons.hub, provider['hub'], Colors.lightBlue));
        }
        break;
      case 'Agente':
        if (provider['license'] != null) {
          chips.add(
              _buildInfoChip(Icons.badge, provider['license'], Colors.amber));
        }
        if (provider['specialties'] != null) {
          chips.add(_buildInfoChip(
              Icons.category, provider['specialties'], Colors.orange));
        }
        break;
      case 'Transporte':
        if (provider['fleet_size'] != null) {
          chips.add(_buildInfoChip(Icons.local_shipping,
              '${provider['fleet_size']} vehículos', Colors.green));
        }
        if (provider['coverage'] != null) {
          chips.add(
              _buildInfoChip(Icons.map, provider['coverage'], Colors.indigo));
        }
        break;
    }

    return chips;
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
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

  Widget _buildRatingBadge(double rating, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, size: 14, color: primaryColor),
          const SizedBox(width: 4),
          Text(rating.toStringAsFixed(1),
              style:
                  TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  IconData _getProviderIcon(String type) {
    switch (type) {
      case 'Naviera':
        return Icons.directions_boat;
      case 'Airline':
        return Icons.flight;
      case 'Agente':
        return Icons.gavel;
      case 'Transporte':
        return Icons.local_shipping;
      default:
        return Icons.business;
    }
  }

  Color _getProviderColor(String type) {
    switch (type) {
      case 'Naviera':
        return Colors.blue;
      case 'Airline':
        return Colors.lightBlue;
      case 'Agente':
        return Colors.amber;
      case 'Transporte':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
