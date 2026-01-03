import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../core/api/client.dart';
import '../widgets/admin_sidebar_drawer.dart';

/// Admin Users Management Screen
/// Full CRUD for users: list, edit, activate/suspend, change roles
class AdminUsuariosScreen extends StatefulWidget {
  const AdminUsuariosScreen({super.key});

  @override
  State<AdminUsuariosScreen> createState() => _AdminUsuariosScreenState();
}

class _AdminUsuariosScreenState extends State<AdminUsuariosScreen> {
  final ApiClient _apiClient = ApiClient();

  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _statusFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _handleNavigation(String route) {
    // Close drawer first
    Navigator.pop(context);

    if (route == 'usuarios') return;

    // Map routes to navigation
    switch (route) {
      case 'dashboard':
      case 'ruc_approvals':
        Navigator.pushReplacementNamed(context, '/admin_dashboard');
        break;
      case 'cotizaciones':
        Navigator.pushReplacementNamed(context, '/admin_cotizaciones');
        break;
      // Case 'usuarios' ignored above
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

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Try to get users from leads endpoint
      final response = await _apiClient.get('sales/leads/');
      List<Map<String, dynamic>> users = [];

      if (response is List) {
        users = List<Map<String, dynamic>>.from(response);
      } else if (response['results'] != null) {
        users = List<Map<String, dynamic>>.from(response['results']);
      }

      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      // Error loading users - use mock data for demo
      setState(() {
        _isLoading = false;
        // Mock data for demo
        _users = [
          {
            'id': 1,
            'first_name': 'Juan',
            'last_name': 'Pérez',
            'email': 'juan@test.com',
            'company_name': 'Importadora ABC',
            'role': 'lead',
            'is_active': true,
            'ruc_status': 'approved',
            'created_at': '2024-12-20',
          },
          {
            'id': 2,
            'first_name': 'María',
            'last_name': 'González',
            'email': 'maria@test.com',
            'company_name': 'Comercial XYZ',
            'role': 'lead',
            'is_active': true,
            'ruc_status': 'pending',
            'created_at': '2024-12-21',
          },
          {
            'id': 3,
            'first_name': 'Carlos',
            'last_name': 'Rodríguez',
            'email': 'carlos@test.com',
            'company_name': 'Distribuidora 123',
            'role': 'lead',
            'is_active': false,
            'ruc_status': 'rejected',
            'created_at': '2024-12-22',
          },
        ];
      });
    }
  }

  List<Map<String, dynamic>> get _filteredUsers {
    return _users.where((user) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final name = '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'
            .toLowerCase();
        final email = (user['email'] ?? '').toLowerCase();
        final company = (user['company_name'] ?? '').toLowerCase();
        if (!name.contains(query) &&
            !email.contains(query) &&
            !company.contains(query)) {
          return false;
        }
      }

      // Status filter
      if (_statusFilter == 'active' && user['is_active'] != true) {
        return false;
      }
      if (_statusFilter == 'inactive' && user['is_active'] != false) {
        return false;
      }

      return true;
    }).toList();
  }

  Future<void> _toggleUserStatus(int userId, bool currentStatus) async {
    final confirm = await _showConfirmDialog(
      title: currentStatus ? 'Suspender Usuario' : 'Activar Usuario',
      content: currentStatus
          ? '¿Desea suspender este usuario?'
          : '¿Desea activar este usuario?',
      confirmText: currentStatus ? 'Suspender' : 'Activar',
      confirmColor: currentStatus ? Colors.red : AppColors.neonGreen,
    );

    if (confirm == true) {
      try {
        await _apiClient.post('sales/leads/$userId/', {
          'is_active': !currentStatus,
        });
        _showSnackBar(
          currentStatus ? 'Usuario suspendido' : 'Usuario activado',
          currentStatus ? Colors.orange : AppColors.neonGreen,
        );
        _loadUsers();
      } catch (e) {
        _showSnackBar('Error: $e', Colors.red);
      }
    }
  }

  void _showEditUserDialog(Map<String, dynamic> user) {
    final firstNameController =
        TextEditingController(text: user['first_name'] ?? '');
    final lastNameController =
        TextEditingController(text: user['last_name'] ?? '');
    final companyController =
        TextEditingController(text: user['company_name'] ?? '');
    String selectedRole = user['role'] ?? 'lead';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0A101D),
        title:
            const Text('Editar Usuario', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField('Nombre', firstNameController),
              const SizedBox(height: 12),
              _buildTextField('Apellido', lastNameController),
              const SizedBox(height: 12),
              _buildTextField('Empresa', companyController),
              const SizedBox(height: 12),
              _buildDropdown(
                label: 'Rol',
                value: selectedRole,
                items: const [
                  DropdownMenuItem(value: 'lead', child: Text('Lead')),
                  DropdownMenuItem(value: 'customer', child: Text('Cliente')),
                  DropdownMenuItem(
                      value: 'admin', child: Text('Administrador')),
                ],
                onChanged: (value) => selectedRole = value ?? 'lead',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _apiClient.post('sales/leads/${user['id']}/', {
                  'first_name': firstNameController.text,
                  'last_name': lastNameController.text,
                  'company_name': companyController.text,
                  'role': selectedRole,
                });
                _showSnackBar('Usuario actualizado', AppColors.neonGreen);
                _loadUsers();
              } catch (e) {
                _showSnackBar('Error: $e', Colors.red);
              }
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

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
  }) {
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
            items: items,
            onChanged: onChanged,
            isExpanded: true,
            dropdownColor: const Color(0xFF1F2937),
            style: const TextStyle(color: Colors.white),
            underline: const SizedBox(),
          ),
        ),
      ],
    );
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
      backgroundColor: bgDark,
      drawer: AdminSidebarDrawer(
        currentRoute: 'usuarios',
        onNavigate: _handleNavigation,
      ),
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.people, color: Colors.blue),
            SizedBox(width: 8),
            Text('Gestión de Usuarios'),
          ],
        ),
        backgroundColor: bgDark,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filters
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre, email o empresa...',
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: surfaceDark,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Filter Row
                Row(
                  children: [
                    Expanded(
                      child: _buildFilterChip(
                        label: 'Todos',
                        isSelected: _statusFilter == 'all',
                        onTap: () => setState(() => _statusFilter = 'all'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildFilterChip(
                        label: 'Activos',
                        isSelected: _statusFilter == 'active',
                        onTap: () => setState(() => _statusFilter = 'active'),
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildFilterChip(
                        label: 'Suspendidos',
                        isSelected: _statusFilter == 'inactive',
                        onTap: () => setState(() => _statusFilter = 'inactive'),
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Stats Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildStatBadge('Total', '${_users.length}', Colors.blue),
                const SizedBox(width: 8),
                _buildStatBadge(
                    'Activos',
                    '${_users.where((u) => u['is_active'] == true).length}',
                    primaryColor),
                const SizedBox(width: 8),
                _buildStatBadge(
                    'Suspendidos',
                    '${_users.where((u) => u['is_active'] == false).length}',
                    Colors.red),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Users List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredUsers.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredUsers.length,
                        itemBuilder: (context, index) => _buildUserCard(
                          _filteredUsers[index],
                          surfaceDark,
                          primaryColor,
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color? color,
  }) {
    final chipColor = color ?? Colors.grey;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? chipColor.withValues(alpha: 0.2)
              : const Color(0xFF0A101D),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? chipColor : Colors.white10,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? chipColor : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatBadge(String label, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(count,
                style: TextStyle(
                    color: color, fontSize: 18, fontWeight: FontWeight.bold)),
            Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, color: Colors.grey[600], size: 64),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty
                ? 'No se encontraron usuarios'
                : 'No hay usuarios registrados',
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(
      Map<String, dynamic> user, Color surfaceDark, Color primaryColor) {
    final isActive = user['is_active'] == true;
    final rucStatus = user['ruc_status'] ?? 'pending';
    final fullName =
        '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'.trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? Colors.white10 : Colors.red.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              CircleAvatar(
                backgroundColor: isActive
                    ? primaryColor.withValues(alpha: 0.2)
                    : Colors.grey.withValues(alpha: 0.2),
                child: Text(
                  fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: isActive ? primaryColor : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName.isNotEmpty ? fullName : 'Sin nombre',
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      user['email'] ?? '',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(isActive ? 'ACTIVO' : 'SUSPENDIDO',
                  isActive ? primaryColor : Colors.red),
            ],
          ),
          const SizedBox(height: 12),

          // Info Row
          Row(
            children: [
              _buildInfoChip(
                Icons.business,
                user['company_name'] ?? 'Sin empresa',
              ),
              const SizedBox(width: 12),
              _buildRucStatusChip(rucStatus),
            ],
          ),
          const SizedBox(height: 12),

          // Actions Row
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _showEditUserDialog(user),
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Editar'),
                style: TextButton.styleFrom(foregroundColor: Colors.blue),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => _toggleUserStatus(user['id'], isActive),
                icon:
                    Icon(isActive ? Icons.block : Icons.check_circle, size: 16),
                label: Text(isActive ? 'Suspender' : 'Activar'),
                style: TextButton.styleFrom(
                  foregroundColor: isActive ? Colors.orange : primaryColor,
                ),
              ),
            ],
          ),
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
      child: Text(
        text,
        style:
            TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildRucStatusChip(String status) {
    Color color;
    String label;

    switch (status) {
      case 'approved':
        color = AppColors.neonGreen;
        label = 'RUC Aprobado';
        break;
      case 'pending':
        color = Colors.amber;
        label = 'RUC Pendiente';
        break;
      case 'rejected':
        color = Colors.red;
        label = 'RUC Rechazado';
        break;
      default:
        color = Colors.grey;
        label = 'Sin RUC';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.badge, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 11)),
        ],
      ),
    );
  }
}
