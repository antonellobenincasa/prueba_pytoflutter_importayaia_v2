import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../core/api/client.dart';
import '../widgets/admin_sidebar_drawer.dart';

class AdminPortalFFScreen extends StatefulWidget {
  const AdminPortalFFScreen({super.key});

  @override
  State<AdminPortalFFScreen> createState() => _AdminPortalFFScreenState();
}

class _AdminPortalFFScreenState extends State<AdminPortalFFScreen> {
  final ApiClient _apiClient = ApiClient();

  List<Map<String, dynamic>> _invitations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInvitations();
  }

  Future<void> _loadInvitations() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiClient.get('admin/ff-invitations/');
      if (response != null && response is Map<String, dynamic>) {
        setState(() {
          _invitations =
              List<Map<String, dynamic>>.from(response['invitations'] ?? []);
        });
      }
    } catch (e) {
      _showSnackBar('Error cargando invitaciones: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showInviteDialog() {
    final emailController = TextEditingController();
    final companyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0A101D),
        title: const Text('Invitar Freight Forwarder',
            style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: companyController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Nombre de la Empresa',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Email del FF',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (emailController.text.isEmpty ||
                  companyController.text.isEmpty) {
                _showSnackBar(
                    'Todos los campos son obligatorios', Colors.orange);
                return;
              }

              Navigator.pop(context);
              _sendInvitation(emailController.text, companyController.text);
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.neonGreen),
            child: const Text('Enviar Invitación',
                style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Future<void> _sendInvitation(String email, String company) async {
    try {
      final data = {
        'email': email,
        'company_name': company,
        'days_valid': 7,
        'send_email': true
      };

      await _apiClient.post('admin/ff-invitations/', data);
      _showSnackBar('Invitación enviada correctamente', AppColors.neonGreen);
      _loadInvitations();
    } catch (e) {
      _showSnackBar('Error enviando invitación: $e', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  void _handleNavigation(String route) {
    Navigator.pop(context);
    if (route == 'portal_ff') return;
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
        currentRoute: 'portal_ff',
        onNavigate: _handleNavigation,
      ),
      appBar: AppBar(
        title: const Text('Portal Freight Forwarders'),
        backgroundColor: bgDark,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInvitations,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showInviteDialog,
        backgroundColor: primaryColor,
        child: const Icon(Icons.person_add, color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _invitations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline,
                          size: 60, color: Colors.grey[800]),
                      const SizedBox(height: 16),
                      const Text('No hay invitaciones enviadas',
                          style: TextStyle(color: Colors.grey, fontSize: 16)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _invitations.length,
                  itemBuilder: (context, index) {
                    final inv = _invitations[index];
                    final isExpired = inv['is_expired'] == true;
                    final status = inv['status'] ?? 'pending';

                    Color statusColor = Colors.orange;
                    if (status == 'accepted') statusColor = Colors.green;
                    if (isExpired) statusColor = Colors.red;

                    return Card(
                      color: surfaceDark,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.white10,
                          child:
                              const Icon(Icons.business, color: Colors.white),
                        ),
                        title: Text(inv['company_name'] ?? 'Sin nombre',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(inv['email'] ?? '',
                                style: const TextStyle(color: Colors.grey)),
                            Text(
                                'Expira: ${inv['expires_at']?.toString().split('T')[0]}',
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 11)),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isExpired ? 'EXPIRADA' : status.toUpperCase(),
                            style: TextStyle(
                                color: statusColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
