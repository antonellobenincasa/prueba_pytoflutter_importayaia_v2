import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../core/services/firebase_service.dart';
import '../widgets/admin_sidebar_drawer.dart';

/// Enhanced Master Admin Dashboard with full management capabilities
class AdminDashboardScreen extends StatefulWidget {
  final int initialTab;
  const AdminDashboardScreen({super.key, this.initialTab = 0});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseService _firebaseService = FirebaseService();
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Current module from sidebar
  String _currentModule = 'dashboard';

  // Data
  List<Map<String, dynamic>> _pendingRucs = [];
  List<Map<String, dynamic>> _quotes = [];
  List<Map<String, dynamic>> _shipments = [];

  bool _isLoading = true;

  // Extended KPI Stats (matching Python dashboard)
  int _totalLeads = 0;
  int _totalQuotes = 0;
  final int _activeRos = 0;
  int _activeShipments = 0;
  final double _totalQuotedValue = 0.0;
  final double _totalTaxesCollected = 0.0;
  final int _approvedRucs = 0;
  final int _rejectedRucs = 0;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 4, vsync: this, initialIndex: widget.initialTab);
    _loadDashboardData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load pending RUCs
      try {
        final rucsResponse =
            await _firebaseService.get('accounts/admin/ruc-approvals/');
        if (rucsResponse is List) {
          _pendingRucs = List<Map<String, dynamic>>.from(rucsResponse);
        } else if (rucsResponse['pending_rucs'] != null) {
          _pendingRucs =
              List<Map<String, dynamic>>.from(rucsResponse['pending_rucs']);
        } else if (rucsResponse['results'] != null) {
          _pendingRucs =
              List<Map<String, dynamic>>.from(rucsResponse['results']);
        }
      } catch (e) {
        // Silently handle error - could not load RUCs
        _pendingRucs = [];
      }

      // Load quotes
      try {
        final quotesResponse = await _firebaseService.get('sales/submissions/');
        if (quotesResponse is List) {
          _quotes = List<Map<String, dynamic>>.from(quotesResponse);
        } else if (quotesResponse['results'] != null) {
          _quotes = List<Map<String, dynamic>>.from(quotesResponse['results']);
        }
        _totalQuotes = _quotes.length;
      } catch (e) {
        // Silently handle error - could not load quotes
        _quotes = [];
      }

      // Load shipments
      try {
        final shipmentsResponse =
            await _firebaseService.get('sales/shipments/');
        if (shipmentsResponse is List) {
          _shipments = List<Map<String, dynamic>>.from(shipmentsResponse);
        } else if (shipmentsResponse['results'] != null) {
          _shipments =
              List<Map<String, dynamic>>.from(shipmentsResponse['results']);
        }
        _activeShipments = _shipments
            .where((s) =>
                s['status'] == 'en_transito' || s['status'] == 'pendiente')
            .length;
      } catch (e) {
        // Silently handle error - could not load shipments
        _shipments = [];
      }

      _totalLeads = _pendingRucs.length + 10; // Mock total

      setState(() => _isLoading = false);
    } catch (e) {
      // Error loading dashboard - show error state
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _approveRuc(int userId, String userName) async {
    final confirm = await _showConfirmDialog(
      title: 'Aprobar RUC',
      content: '¿Aprobar el RUC de $userName?',
      confirmText: 'Aprobar',
      confirmColor: AppColors.neonGreen,
    );

    if (confirm == true) {
      try {
        await _firebaseService.post(
            'accounts/admin/ruc-approvals/$userId/', {'action': 'approve'});
        _showSnackBar('✅ RUC aprobado', AppColors.neonGreen);
        _loadDashboardData();
      } catch (e) {
        _showSnackBar('Error: $e', Colors.red);
      }
    }
  }

  Future<void> _rejectRuc(int userId, String userName) async {
    final confirm = await _showConfirmDialog(
      title: 'Rechazar RUC',
      content: '¿Rechazar el RUC de $userName?',
      confirmText: 'Rechazar',
      confirmColor: Colors.red,
    );

    if (confirm == true) {
      try {
        await _firebaseService.post(
            'accounts/admin/ruc-approvals/$userId/', {'action': 'reject'});
        _showSnackBar('RUC rechazado', Colors.orange);
        _loadDashboardData();
      } catch (e) {
        _showSnackBar('Error: $e', Colors.red);
      }
    }
  }

  Future<void> _processQuote(int quoteId, String action) async {
    try {
      await _firebaseService
          .post('sales/submissions/$quoteId/process/', {'action': action});
      _showSnackBar('Cotización procesada', AppColors.neonGreen);
      _loadDashboardData();
    } catch (e) {
      _showSnackBar('Error: $e', Colors.red);
    }
  }

  Future<void> _updateShipmentStatus(int shipmentId, String newStatus) async {
    try {
      await _firebaseService
          .post('sales/shipments/$shipmentId/', {'status': newStatus});
      _showSnackBar('Estado actualizado', AppColors.neonGreen);
      _loadDashboardData();
    } catch (e) {
      _showSnackBar('Error: $e', Colors.red);
    }
  }

  Future<bool?> _showConfirmDialog({
    required String title,
    required String content,
    required String confirmText,
    required Color confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0A101D),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(content, style: const TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: confirmColor),
            child: Text(confirmText,
                style: TextStyle(
                    color: confirmColor == AppColors.neonGreen
                        ? Colors.black
                        : Colors.white)),
          ),
        ],
      ),
    );
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

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: bgDark,
      drawer: AdminSidebarDrawer(
        currentRoute: _currentModule,
        onNavigate: (route) {
          Navigator.pop(context); // Close drawer
          setState(() => _currentModule = route);
          // Navigate to specific module screens
          switch (route) {
            case 'dashboard':
              _tabController.animateTo(0);
              break;
            case 'ruc_approvals':
              _tabController.animateTo(0);
              break;
            case 'cotizaciones':
              _tabController.animateTo(1);
              break;
            case 'usuarios':
              Navigator.pushNamed(context, '/admin_usuarios');
              break;
            case 'arancel':
              Navigator.pushNamed(context, '/admin_arancel');
              break;
            case 'tarifas_base':
              Navigator.pushNamed(context, '/admin_tarifas_base');
              break;
            case 'proveedores':
              Navigator.pushNamed(context, '/admin_proveedores');
              break;
            case 'config_hitos':
              Navigator.pushNamed(context, '/admin_config_hitos');
              break;
            case 'tracking_ff':
              Navigator.pushNamed(context, '/admin_tracking_ff');
              break;
            case 'portal_ff':
              Navigator.pushNamed(context, '/admin_portal_ff');
              break;
            case 'cotizaciones_ff':
              Navigator.pushNamed(context, '/admin_cotizaciones_ff');
              break;
            case 'config_ff':
              Navigator.pushNamed(context, '/admin_config_ff');
              break;
            case 'puertos':
              Navigator.pushNamed(context, '/admin_puertos');
              break;
            case 'aeropuertos':
              Navigator.pushNamed(context, '/admin_aeropuertos');
              break;
            case 'profit_review':
              Navigator.pushNamed(context, '/admin_profit_review');
              break;
            case 'logs':
              Navigator.pushNamed(context, '/admin_logs');
              break;
            default:
              break; // Stay current
          }
        },
      ),
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.admin_panel_settings, color: primaryColor),
            SizedBox(width: 8),
            Text("Admin Dashboard"),
          ],
        ),
        backgroundColor: bgDark,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: primaryColor,
          tabs: const [
            Tab(icon: Icon(Icons.badge), text: 'RUCs'),
            Tab(icon: Icon(Icons.request_quote), text: 'Cotizaciones'),
            Tab(icon: Icon(Icons.local_shipping), text: 'Embarques'),
            Tab(icon: Icon(Icons.people), text: 'Usuarios'),
          ],
        ),
      ),
      body: Column(
        children: [
          // KPIs Grid (matching Python dashboard)
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('KPIs del Sistema',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                // First row - 4 KPIs
                Row(
                  children: [
                    _buildKpiCard('Total LEADs', '$_totalLeads', Colors.white),
                    const SizedBox(width: 8),
                    _buildKpiCard(
                        'Cotizaciones Totales', '$_totalQuotes', Colors.white),
                    const SizedBox(width: 8),
                    _buildKpiCard('ROs Activos', '$_activeRos', primaryColor),
                    const SizedBox(width: 8),
                    _buildKpiCard(
                        'Embarques Activos', '$_activeShipments', primaryColor),
                  ],
                ),
                const SizedBox(height: 8),
                // Second row - 2 value KPIs
                Row(
                  children: [
                    Expanded(
                      child: _buildValueCard(
                          'Valor Total Cotizado',
                          '\$${_totalQuotedValue.toStringAsFixed(2)}',
                          Colors.blue),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildValueCard(
                          'Tributos Totales Recaudados',
                          '\$${_totalTaxesCollected.toStringAsFixed(2)}',
                          Colors.green),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Third row - RUC status cards
                Row(
                  children: [
                    _buildStatusCard(
                        'Aprobados', '$_approvedRucs', primaryColor),
                    const SizedBox(width: 8),
                    _buildStatusCard(
                        'Pendientes', '${_pendingRucs.length}', Colors.amber),
                    const SizedBox(width: 8),
                    _buildStatusCard(
                        'Rechazados', '$_rejectedRucs', Colors.red),
                  ],
                ),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildRucTab(surfaceDark, primaryColor),
                      _buildQuotesTab(surfaceDark, primaryColor),
                      _buildShipmentsTab(surfaceDark, primaryColor),
                      _buildUsersTab(surfaceDark, primaryColor),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // KPI Card widget
  Widget _buildKpiCard(String label, String value, Color valueColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF0A101D),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(color: Colors.grey[500], fontSize: 10)),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    color: valueColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // Value Card widget
  Widget _buildValueCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  TextStyle(color: color.withValues(alpha: 0.7), fontSize: 10)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Status Card widget
  Widget _buildStatusCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    color: color, fontSize: 10, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    color: color, fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // RUC Tab
  Widget _buildRucTab(Color surfaceDark, Color primaryColor) {
    if (_pendingRucs.isEmpty) {
      return _buildEmptyState('No hay RUCs pendientes', Icons.check_circle);
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _pendingRucs.length,
      itemBuilder: (context, index) =>
          _buildRucCard(_pendingRucs[index], surfaceDark, primaryColor),
    );
  }

  Widget _buildRucCard(
      Map<String, dynamic> item, Color surfaceDark, Color primaryColor) {
    final userId = item['id'] ?? item['user_id'] ?? 0;
    final userName =
        '${item['first_name'] ?? ''} ${item['last_name'] ?? ''}'.trim();
    final companyName = item['company_name'] ?? 'Sin empresa';
    final ruc = item['ruc'] ?? 'Sin RUC';
    final email = item['email'] ?? '';

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
          Row(
            children: [
              CircleAvatar(
                backgroundColor: primaryColor.withValues(alpha: 0.2),
                child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                    style: TextStyle(
                        color: primaryColor, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userName.isNotEmpty ? userName : 'Sin nombre',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    Text(email,
                        style:
                            TextStyle(color: Colors.grey[500], fontSize: 12)),
                  ],
                ),
              ),
              _buildStatusBadge('PENDIENTE', Colors.orange),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoChip('Empresa', companyName, Icons.business),
              const SizedBox(width: 12),
              _buildInfoChip('RUC', ruc, Icons.badge, color: primaryColor),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _rejectRuc(userId, userName),
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Rechazar'),
                  style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _approveRuc(userId, userName),
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Aprobar'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.black),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Quotes Tab
  Widget _buildQuotesTab(Color surfaceDark, Color primaryColor) {
    if (_quotes.isEmpty) {
      return _buildEmptyState('No hay cotizaciones', Icons.request_quote);
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _quotes.length,
      itemBuilder: (context, index) =>
          _buildQuoteCard(_quotes[index], surfaceDark, primaryColor),
    );
  }

  Widget _buildQuoteCard(
      Map<String, dynamic> quote, Color surfaceDark, Color primaryColor) {
    final id = quote['id'] ?? 0;
    final submissionNumber = quote['submission_number'] ?? 'QT-$id';
    final status = quote['status'] ?? 'recibida';
    final origin = quote['origin'] ?? 'N/A';
    final destination = quote['destination'] ?? 'N/A';
    final transportType = quote['transport_type'] ?? 'FCL';
    final companyName = quote['company_name'] ?? 'N/A';

    Color statusColor = status == 'recibida'
        ? Colors.blue
        : status == 'cotizacion_generada'
            ? primaryColor
            : Colors.orange;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(submissionNumber,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              _buildStatusBadge(
                  status.toUpperCase().replaceAll('_', ' '), statusColor),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(_getTransportIcon(transportType),
                  color: primaryColor, size: 20),
              const SizedBox(width: 8),
              Text('$origin → $destination',
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Text('Cliente: $companyName',
              style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          if (status == 'recibida' || status == 'validacion_pendiente')
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _processQuote(id, 'generate_quote'),
                      icon: const Icon(Icons.calculate, size: 18),
                      label: const Text('Generar Cotización'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          if (status == 'cotizacion_generada')
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _processQuote(id, 'generate_ro'),
                      icon: const Icon(Icons.assignment, size: 18),
                      label: const Text('Generar RO'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Shipments Tab
  Widget _buildShipmentsTab(Color surfaceDark, Color primaryColor) {
    if (_shipments.isEmpty) {
      return _buildEmptyState('No hay embarques', Icons.local_shipping);
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _shipments.length,
      itemBuilder: (context, index) =>
          _buildShipmentCard(_shipments[index], surfaceDark, primaryColor),
    );
  }

  Widget _buildShipmentCard(
      Map<String, dynamic> shipment, Color surfaceDark, Color primaryColor) {
    final id = shipment['id'] ?? 0;
    final roNumber = shipment['ro_number'] ?? 'RO-$id';
    final status = shipment['status'] ?? 'pendiente';
    final eta = shipment['eta'] ?? 'N/A';

    final statusColors = {
      'pendiente': Colors.orange,
      'en_transito': Colors.blue,
      'en_puerto': Colors.cyan,
      'en_aduana': Colors.purple,
      'liberado': primaryColor,
      'entregado': Colors.green,
    };

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(roNumber,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              _buildStatusBadge(status.toUpperCase().replaceAll('_', ' '),
                  statusColors[status] ?? Colors.grey),
            ],
          ),
          const SizedBox(height: 12),
          Text('ETA: $eta',
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              _buildActionChip('En Tránsito',
                  () => _updateShipmentStatus(id, 'en_transito')),
              _buildActionChip(
                  'En Puerto', () => _updateShipmentStatus(id, 'en_puerto')),
              _buildActionChip(
                  'Liberado', () => _updateShipmentStatus(id, 'liberado')),
              _buildActionChip(
                  'Entregado', () => _updateShipmentStatus(id, 'entregado')),
            ],
          ),
        ],
      ),
    );
  }

  // Users Tab
  Widget _buildUsersTab(Color surfaceDark, Color primaryColor) {
    return _buildEmptyState('Gestión de usuarios próximamente', Icons.people);
  }

  // Helpers
  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.grey, size: 64),
          const SizedBox(height: 16),
          Text(message,
              style: const TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildInfoChip(String label, String value, IconData icon,
      {Color? color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 12, color: Colors.grey),
                const SizedBox(width: 4),
                Text(label,
                    style: const TextStyle(color: Colors.grey, fontSize: 10)),
              ],
            ),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    color: color ?? Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionChip(String label, VoidCallback onTap) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 10)),
      onPressed: onTap,
      backgroundColor: Colors.white10,
      labelStyle: const TextStyle(color: Colors.white),
    );
  }

  IconData _getTransportIcon(String type) {
    switch (type.toLowerCase()) {
      case 'fcl':
      case 'lcl':
        return Icons.directions_boat;
      case 'air':
      case 'aereo':
        return Icons.flight;
      default:
        return Icons.local_shipping;
    }
  }
}
