import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../core/services/firebase_service.dart';
import '../widgets/admin_sidebar_drawer.dart';

class AdminAeropuertosScreen extends StatefulWidget {
  const AdminAeropuertosScreen({super.key});

  @override
  State<AdminAeropuertosScreen> createState() => _AdminAeropuertosScreenState();
}

class _AdminAeropuertosScreenState extends State<AdminAeropuertosScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _airports = [];
  bool _isLoading = true;
  String? _selectedRegion;
  final int _page = 1;
  int _totalRecords = 0;
  List<Map<String, dynamic>> _regions = [];

  @override
  void initState() {
    super.initState();
    _loadAirports();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAirports() async {
    setState(() => _isLoading = true);

    try {
      final queryParams = <String, String>{
        'page': _page.toString(),
        if (_searchController.text.isNotEmpty) 'search': _searchController.text,
        if (_selectedRegion != null) 'region': _selectedRegion!,
      };

      final response = await _firebaseService.get('admin/airports/',
          queryParameters: queryParams);

      // --- FIX 1: Verificar si sigue montado antes de usar setState ---
      if (!mounted) return;

      if (response != null && response is Map<String, dynamic>) {
        setState(() {
          _airports =
              List<Map<String, dynamic>>.from(response['airports'] ?? []);
          _totalRecords = response['total'] ?? 0;
          if (response['regions_summary'] != null) {
            _regions =
                List<Map<String, dynamic>>.from(response['regions_summary']);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error cargando aeropuertos: $e', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteAirport(int id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0A101D),
        title: const Text('Confirmar Eliminación',
            style: TextStyle(color: Colors.white)),
        content: Text('¿Está seguro de eliminar el aeropuerto $name?',
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
        await _firebaseService
            .delete('admin/airports/', queryParameters: {'id': id.toString()});

        // --- FIX 2: ESTA ERA LA CAUSA PRINCIPAL DEL ERROR ---
        if (!mounted) return;

        _showSnackBar(
            'Aeropuerto eliminado correctamente', AppColors.neonGreen);
        _loadAirports();
      } catch (e) {
        if (mounted) {
          _showSnackBar('Error eliminando aeropuerto: $e', Colors.red);
        }
      }
    }
  }

  void _showAddEditDialog([Map<String, dynamic>? airport]) {
    final isNew = airport == null;
    final iataController =
        TextEditingController(text: airport?['iata_code'] ?? '');
    final icaoController =
        TextEditingController(text: airport?['icao_code'] ?? '');
    final nameController = TextEditingController(text: airport?['name'] ?? '');
    final cityController =
        TextEditingController(text: airport?['ciudad_exacta'] ?? '');
    final countryController =
        TextEditingController(text: airport?['country'] ?? '');
    final regionController =
        TextEditingController(text: airport?['region_name'] ?? '');
    bool isActive = airport?['is_active'] ?? true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF0A101D),
          title: Text(
            isNew ? 'Nuevo Aeropuerto' : 'Editar Aeropuerto',
            style: const TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(child: _buildTextField('IATA', iataController)),
                    const SizedBox(width: 8),
                    Expanded(
                        child:
                            _buildTextField('ICAO (Opcional)', icaoController)),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTextField('Nombre', nameController),
                const SizedBox(height: 12),
                _buildTextField('Ciudad', cityController),
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
                  activeThumbColor: AppColors.neonGreen,
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
                    'iata_code': iataController.text,
                    'icao_code': icaoController.text,
                    'name': nameController.text,
                    'ciudad_exacta': cityController.text,
                    'country': countryController.text,
                    'region_name': regionController.text,
                    'is_active': isActive,
                  };

                  if (isNew) {
                    await _firebaseService.post('admin/airports/', data);
                  } else {
                    data['id'] = airport['id'];
                    await _firebaseService.put('admin/airports/', data);
                  }

                  // --- FIX 3: Asegurar mounted antes de cerrar y mostrar snackbar ---
                  if (!context.mounted) return;

                  Navigator.pop(context);
                  _showSnackBar(
                      isNew ? 'Aeropuerto creado' : 'Aeropuerto actualizado',
                      AppColors.neonGreen);
                  _loadAirports();
                } catch (e) {
                  if (mounted) {
                    _showSnackBar('Error guardando aeropuerto: $e', Colors.red);
                  }
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
    if (route == 'aeropuertos') return;
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
        currentRoute: 'aeropuertos',
        onNavigate: _handleNavigation,
      ),
      appBar: AppBar(
        title: const Text('Gestión de Aeropuertos'),
        backgroundColor: bgDark,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAirports,
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
                      hintText: 'Buscar IATA, nombre o ciudad...',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: surfaceDark,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _loadAirports(),
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
                                value: r['region_name'].toString(),
                                child:
                                    Text('${r['region_name']} (${r['count']})'),
                              )),
                        ],
                        onChanged: (val) {
                          setState(() => _selectedRegion = val);
                          _loadAirports();
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
                  : _airports.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.flight_outlined,
                                  size: 60, color: Colors.grey[800]),
                              const SizedBox(height: 16),
                              const Text('No se encontraron aeropuertos',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 16)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _airports.length,
                          itemBuilder: (context, index) {
                            final airport = _airports[index];
                            return Card(
                              color: surfaceDark,
                              margin: const EdgeInsets.only(bottom: 8),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      Colors.lightBlue.withValues(alpha: 0.1),
                                  child: const Icon(Icons.flight_takeoff,
                                      color: Colors.lightBlue, size: 20),
                                ),
                                title: Row(
                                  children: [
                                    Text(airport['iata_code'] ?? '???',
                                        style: const TextStyle(
                                            color: AppColors.neonGreen,
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        airport['name'] ?? 'Sin nombre',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            overflow: TextOverflow.ellipsis),
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        '${airport['ciudad_exacta']} • ${airport['country']}',
                                        style: const TextStyle(
                                            color: Colors.grey)),
                                    if (airport['region_name'] != null)
                                      Text(airport['region_name'],
                                          style: TextStyle(
                                              color: Colors.lightBlue
                                                  .withValues(alpha: 0.7),
                                              fontSize: 11)),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (airport['is_active'] != true)
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
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.blue),
                                      onPressed: () =>
                                          _showAddEditDialog(airport),
                                      tooltip: 'Editar',
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () => _deleteAirport(
                                          airport['id'], airport['name']),
                                      tooltip: 'Eliminar',
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
            // Pagination info
            if (_totalRecords > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text('Total: $_totalRecords aeropuertos',
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ),
          ],
        ),
      ),
    );
  }
}
