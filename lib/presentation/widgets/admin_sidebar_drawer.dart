import 'package:flutter/material.dart';
import '../../config/theme.dart';

/// Admin Sidebar Drawer with all 14+ menu options
/// Mirrors the Python backend Master Admin dashboard sidebar
class AdminSidebarDrawer extends StatelessWidget {
  final String currentRoute;
  final Function(String) onNavigate;

  const AdminSidebarDrawer({
    super.key,
    required this.currentRoute,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    const bgDark = Color(0xFF0A101D);
    const primaryColor = AppColors.neonGreen;

    return Drawer(
      backgroundColor: bgDark,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              border: Border(
                bottom: BorderSide(color: primaryColor.withValues(alpha: 0.3)),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text('MA',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('DASHBOARD MASTER ADMIN',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                      Text('Panel de Control Total - ImportaYA.ia',
                          style: TextStyle(color: Colors.grey, fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildMenuItem(
                  icon: Icons.dashboard,
                  label: 'Dashboard',
                  route: 'dashboard',
                  color: primaryColor,
                ),
                _buildMenuItem(
                  icon: Icons.settings,
                  label: 'Config Hitos',
                  route: 'config_hitos',
                  color: Colors.blue,
                ),
                _buildMenuItem(
                  icon: Icons.track_changes,
                  label: 'Tracking FF',
                  route: 'tracking_ff',
                  color: Colors.cyan,
                ),
                _buildMenuItem(
                  icon: Icons.business,
                  label: 'Portal FF',
                  route: 'portal_ff',
                  color: Colors.purple,
                ),
                _buildMenuItem(
                  icon: Icons.request_quote,
                  label: 'Cotizaciones FF',
                  route: 'cotizaciones_ff',
                  color: Colors.orange,
                ),
                _buildMenuItem(
                  icon: Icons.tune,
                  label: 'Config FF',
                  route: 'config_ff',
                  color: Colors.teal,
                ),
                _buildMenuItem(
                  icon: Icons.policy,
                  label: 'Arancel',
                  route: 'arancel',
                  color: Colors.amber,
                ),
                _buildMenuItem(
                  icon: Icons.verified_user,
                  label: 'Aprobaciones RUC',
                  route: 'ruc_approvals',
                  color: primaryColor,
                ),
                _buildMenuItem(
                  icon: Icons.people,
                  label: 'Usuarios',
                  route: 'usuarios',
                  color: Colors.blue,
                ),
                _buildMenuItem(
                  icon: Icons.description,
                  label: 'Cotizaciones',
                  route: 'cotizaciones',
                  color: Colors.green,
                ),
                _buildMenuItem(
                  icon: Icons.anchor,
                  label: 'Puertos',
                  route: 'puertos',
                  color: Colors.indigo,
                ),
                _buildMenuItem(
                  icon: Icons.flight,
                  label: 'Aeropuertos',
                  route: 'aeropuertos',
                  color: Colors.lightBlue,
                ),
                _buildMenuItem(
                  icon: Icons.store,
                  label: 'Proveedores',
                  route: 'proveedores',
                  color: Colors.deepOrange,
                ),
                _buildMenuItem(
                  icon: Icons.attach_money,
                  label: 'Tarifas Base',
                  route: 'tarifas_base',
                  color: Colors.yellow,
                ),
                _buildMenuItem(
                  icon: Icons.analytics,
                  label: 'Profit Review',
                  route: 'profit_review',
                  color: Colors.pink,
                ),
                const Divider(color: Colors.white10, height: 24),
                _buildMenuItem(
                  icon: Icons.history,
                  label: 'Logs',
                  route: 'logs',
                  color: Colors.grey,
                ),
              ],
            ),
          ),

          // Logout Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.white10)),
            ),
            child: InkWell(
              onTap: () => Navigator.pushReplacementNamed(context, '/'),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, color: Colors.red, size: 18),
                    SizedBox(width: 8),
                    Text('Cerrar Sesión',
                        style: TextStyle(color: Colors.red, fontSize: 14)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required String route,
    required Color color,
  }) {
    final isSelected = currentRoute == route;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isSelected ? Border.all(color: color.withValues(alpha: 0.5)) : null,
      ),
      child: ListTile(
        dense: true,
        leading: Icon(icon, color: isSelected ? color : Colors.grey, size: 20),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[400],
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        onTap: () => onNavigate(route),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
