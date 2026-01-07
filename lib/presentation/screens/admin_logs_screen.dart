import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../core/services/firebase_service.dart';
import '../widgets/admin_sidebar_drawer.dart';

class AdminLogsScreen extends StatefulWidget {
  const AdminLogsScreen({super.key});

  @override
  State<AdminLogsScreen> createState() => _AdminLogsScreenState();
}

class _AdminLogsScreenState extends State<AdminLogsScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  List<Map<String, dynamic>> _logs = [];
  bool _isLoading = true;
  int _page = 1;
  int _totalPages = 1;
  int _totalCount = 0;

  // Filters
  String? _selectedActionType;
  String? _selectedLevel;
  List<Map<String, dynamic>> _actionTypeChoices = [];
  List<Map<String, dynamic>> _levelChoices = [];

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadLogs() async {
    setState(() => _isLoading = true);

    try {
      final queryParams = <String, String>{
        'page': _page.toString(),
        'page_size': '20',
        if (_selectedActionType != null) 'action_type': _selectedActionType!,
        if (_selectedLevel != null) 'level': _selectedLevel!,
      };

      final response =
          await _firebaseService.get('admin/logs/', queryParameters: queryParams);

      if (response != null && response is Map<String, dynamic>) {
        setState(() {
          _logs = List<Map<String, dynamic>>.from(response['logs'] ?? []);

          if (response['pagination'] != null) {
            _totalPages = response['pagination']['total_pages'] ?? 1;
            _totalCount = response['pagination']['total_count'] ?? 0;
          }

          if (response['filters'] != null) {
            if (_actionTypeChoices.isEmpty) {
              _actionTypeChoices = List<Map<String, dynamic>>.from(
                  response['filters']['action_types'] ?? []);
            }
            if (_levelChoices.isEmpty) {
              _levelChoices = List<Map<String, dynamic>>.from(
                  response['filters']['levels'] ?? []);
            }
          }
        });

        // Scroll to top on new page load
        if (_scrollController.hasClients) {
          _scrollController.animateTo(0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut);
        }
      }
    } catch (e) {
      _showSnackBar('Error cargando logs: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  Color _getLevelColor(String level) {
    switch (level.toUpperCase()) {
      case 'ERROR':
        return Colors.red;
      case 'WARNING':
        return Colors.orange;
      case 'SUCCESS':
        return AppColors.neonGreen;
      case 'INFO':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getActionIcon(String actionType) {
    if (actionType.contains('login')) return Icons.login;
    if (actionType.contains('logout')) return Icons.logout;
    if (actionType.contains('quote') || actionType.contains('cotizacion')) {
      return Icons.request_quote;
    }
    if (actionType.contains('shipment') || actionType.contains('embarque')) {
      return Icons.directions_boat;
    }
    if (actionType.contains('user') || actionType.contains('usuario')) {
      return Icons.person;
    }
    if (actionType.contains('error')) return Icons.error_outline;
    if (actionType.contains('api')) return Icons.api;
    return Icons.history;
  }

  void _handleNavigation(String route) {
    Navigator.pop(context);
    if (route == 'logs') return;
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
  Widget build(BuildContext context) {
    const bgDark = Color(0xFF050A14);
    const surfaceDark = Color(0xFF0A101D);

    return Scaffold(
      backgroundColor: bgDark,
      drawer: AdminSidebarDrawer(
        currentRoute: 'logs',
        onNavigate: _handleNavigation,
      ),
      appBar: AppBar(
        title: const Text('Logs de Sistema'),
        backgroundColor: bgDark,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _page = 1;
              _loadLogs();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters Header
          Container(
            padding: const EdgeInsets.all(16),
            color: surfaceDark,
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedActionType,
                    decoration: InputDecoration(
                      labelText: 'Tipo de Acción',
                      labelStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: bgDark,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 0),
                    ),
                    dropdownColor: bgDark,
                    style: const TextStyle(color: Colors.white),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Todas')),
                      ..._actionTypeChoices.map((c) => DropdownMenuItem(
                            value: c['value'].toString(),
                            child: Text(c['label'].toString(),
                                overflow: TextOverflow.ellipsis),
                          )),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _selectedActionType = val;
                        _page = 1;
                      });
                      _loadLogs();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedLevel,
                    decoration: InputDecoration(
                      labelText: 'Nivel',
                      labelStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: bgDark,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 0),
                    ),
                    dropdownColor: bgDark,
                    style: const TextStyle(color: Colors.white),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Todos')),
                      ..._levelChoices.map((c) => DropdownMenuItem(
                            value: c['value'].toString(),
                            child: Text(c['label'].toString()),
                          )),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _selectedLevel = val;
                        _page = 1;
                      });
                      _loadLogs();
                    },
                  ),
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _logs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history_toggle_off,
                                size: 60, color: Colors.grey[800]),
                            const SizedBox(height: 16),
                            const Text('No hay logs registrados',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 16)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _logs.length,
                        itemBuilder: (context, index) {
                          final log = _logs[index];
                          final level = log['level'] ?? 'INFO';
                          final color = _getLevelColor(level);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: surfaceDark,
                              border: Border(
                                  left: BorderSide(color: color, width: 4)),
                              borderRadius: const BorderRadius.horizontal(
                                  right: Radius.circular(8)),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              leading: CircleAvatar(
                                backgroundColor: color.withValues(alpha: 0.1),
                                child: Icon(
                                    _getActionIcon(log['action_type'] ?? ''),
                                    color: color,
                                    size: 20),
                              ),
                              title: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(level,
                                        style: TextStyle(
                                            color: color,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                        log['action_type_display'] ??
                                            log['action_type'] ??
                                            'Acción',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14)),
                                  ),
                                  Text(
                                      log['created_at']
                                              ?.toString()
                                              .split('T')[0] ??
                                          '',
                                      style: const TextStyle(
                                          color: Colors.grey, fontSize: 11)),
                                ],
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(log['message'] ?? '',
                                        style: const TextStyle(
                                            color: Colors.white70)),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.person_outline,
                                            size: 12, color: Colors.grey[600]),
                                        const SizedBox(width: 4),
                                        Text(log['user_email'] ?? 'Sistema',
                                            style: TextStyle(
                                                color: Colors.grey[500],
                                                fontSize: 11)),
                                        if (log['ip_address'] != null) ...[
                                          const SizedBox(width: 12),
                                          Icon(Icons.monitor,
                                              size: 12,
                                              color: Colors.grey[600]),
                                          const SizedBox(width: 4),
                                          Text(log['ip_address'],
                                              style: TextStyle(
                                                  color: Colors.grey[500],
                                                  fontSize: 11)),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),

          // Pagination Footer
          if (_totalPages > 1)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              color: surfaceDark,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Página $_page de $_totalPages ($_totalCount registros)',
                      style: const TextStyle(color: Colors.grey)),
                  Row(
                    children: [
                      IconButton(
                        icon:
                            const Icon(Icons.chevron_left, color: Colors.white),
                        onPressed: _page > 1
                            ? () {
                                setState(() => _page--);
                                _loadLogs();
                              }
                            : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right,
                            color: Colors.white),
                        onPressed: _page < _totalPages
                            ? () {
                                setState(() => _page++);
                                _loadLogs();
                              }
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
