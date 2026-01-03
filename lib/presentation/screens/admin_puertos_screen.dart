import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../core/api/client.dart';
import '../widgets/admin_sidebar_drawer.dart';

class AdminPuertosScreen extends StatefulWidget {
  const AdminPuertosScreen({super.key});

  @override
  State<AdminPuertosScreen> createState() => _AdminPuertosScreenState();
}

class _AdminPuertosScreenState extends State<AdminPuertosScreen> {
  final ApiClient _apiClient = ApiClient();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _ports = [];
  bool _isLoading = true;
  String? _selectedRegion;
  int _page = 1;
  int _totalRecords = 0;
  List<Map<String, dynamic>> _regions = [];

  @override
  void initState() {
    super.initState();
    _loadPorts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPorts() async {
    setState(() => _isLoading = true);

    try {
      final queryParams = <String, String>{
        'page': _page.toString(),
        if (_searchController.text.isNotEmpty) 'search': _searchController.text,
        if (_selectedRegion != null) 'region': _selectedRegion!,
      };

      final response =
          await _apiClient.get('admin/ports/', queryParameters: queryParams);

      if (response != null && response is Map<String, dynamic>) {
        setState(() {
          _ports = List<Map<String, dynamic>>.from(response['ports'] ?? []);
          _totalRecords = response['total'] ?? 0;
          if (response['regions_summary'] != null) {
            _regions =
                List<Map<String, dynamic>>.from(response['regions_summary']);
          }
        });
      }
    } catch (e) {
      _showSnackBar('Error cargando puertos: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deletePort(int id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0A101D),
        title: const Text('Confirmar Eliminación',
            style: TextStyle(color: Colors.white)),
        content: Text('¿Está seguro de eliminar el puerto $name?',
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child:
                const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _apiClient
            .delete('admin/ports/', queryParameters: {'id': id.toString()});
        _showSnackBar('Puerto eliminado correctamente', AppColors.neonGreen);
        _loadPorts();
      } catch (e) {
        _showSnackBar('Error eliminando puerto: $e', Colors.red);
      }
    }
  }

  void _showAddEditDialog([Map<String, dynamic>? port]) {
    final isNew = port == null;
    final unLocodeController =
        TextEditingController(text: port?['un_locode'] ?? '');
    final nameController = TextEditingController(text: port?['name'] ?? '');
    final countryController =
        TextEditingController(text: port?['country'] ?? '');
    final regionController = TextEditingController(text: port?['region'] ?? '');
    bool isActive = port?['is_active'] ?? true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF0A101D),
          title: Text(
            isNew ? 'Nuevo Puerto' : 'Editar Puerto',
            style: const TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField('UN/LOCODE', unLocodeController),
                const SizedBox(height: 12),
                _buildTextField('Nombre', nameController),
                const SizedBox(height: 12),
                _buildTextField('País', countryController),
                const SizedBox(height: 12),
                _buildTextField('Región', regionController),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Activo',
                      style: TextStyle(color: Colors.white)),
                  value: isActive,
                  onChanged: (val) => setDialogState(() => isActive = val),
                  activeColor: AppColors.neonGreen,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final data = {
                    'un_locode': unLocodeController.text,
                    'name': nameController.text,
                    'country': countryController.text,
                    'region': regionController.text,
                    'is_active': isActive,
                  };

                  if (isNew) {
                    await _apiClient.post('admin/ports/', data);
                  } else {
                    data['id'] = port['id'];
                    await _apiClient.put('admin/ports/', data);
                  }

                  if (mounted) {
                    Navigator.pop(context);
                    _showSnackBar(
                        isNew ? 'Puerto creado' : 'Puerto actualizado',
                        AppColors.neonGreen);
                    _loadPorts();
                  }
                } catch (e) {
                  _showSnackBar('Error guardando puerto: $e', Colors.red);
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonGreen),
              child:
                  const Text('Guardar', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
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

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  void _handleNavigation(String route) {
    Navigator.pop(context);
    if (route == 'puertos') return;
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
    const primaryColor = AppColors.neonGreen;

    return Scaffold(
      backgroundColor: bgDark,
      drawer: AdminSidebarDrawer(
        currentRoute: 'puertos',
        onNavigate: _handleNavigation,
      ),
      appBar: AppBar(
        title: const Text('Gestión de Puertos'),
        backgroundColor: bgDark,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPorts,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Filters
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Buscar por nombre, código o país...',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: surfaceDark,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _loadPorts(),
                  ),
                ),
                const SizedBox(width: 12),
                if (_regions.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: surfaceDark,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedRegion,
                        hint: const Text('Región',
                            style: TextStyle(color: Colors.grey)),
                        dropdownColor: surfaceDark,
                        icon:
                            const Icon(Icons.filter_list, color: primaryColor),
                        style: const TextStyle(color: Colors.white),
                        items: [
                          const DropdownMenuItem(
                              value: null, child: Text('Todas')),
                          ..._regions.map((r) => DropdownMenuItem(
                                value: r['region'].toString(),
                                child: Text('${r['region']} (${r['count']})'),
                              )),
                        ],
                        onChanged: (val) {
                          setState(() => _selectedRegion = val);
                          _loadPorts();
                        },
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _ports.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.anchor_outlined,
                                  size: 60, color: Colors.grey[800]),
                              const SizedBox(height: 16),
                              const Text('No se encontraron puertos',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 16)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _ports.length,
                          itemBuilder: (context, index) {
                            final port = _ports[index];
                            return Card(
                              color: surfaceDark,
                              margin: const EdgeInsets.only(bottom: 8),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      primaryColor.withValues(alpha: 0.1),
                                  child: const Icon(Icons.anchor,
                                      color: primaryColor, size: 20),
                                ),
                                title: Text(port['name'] ?? 'Sin nombre',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        '${port['un_locode']} • ${port['country']}',
                                        style: const TextStyle(
                                            color: Colors.grey)),
                                    if (port['region'] != null)
                                      Text(port['region'],
                                          style: TextStyle(
                                              color: primaryColor.withValues(
                                                  alpha: 0.7),
                                              fontSize: 11)),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (port['is_active'] != true)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color:
                                              Colors.red.withValues(alpha: 0.2),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: const Text('Inactivo',
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 10)),
                                      ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.blue),
                                      onPressed: () => _showAddEditDialog(port),
                                      tooltip: 'Editar',
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () =>
                                          _deletePort(port['id'], port['name']),
                                      tooltip: 'Eliminar',
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
            // Pagination info could go here
            if (_totalRecords > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text('Total: $_totalRecords puertos',
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ),
          ],
        ),
      ),
    );
  }
}
