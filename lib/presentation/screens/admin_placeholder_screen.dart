import 'package:flutter/material.dart';
import '../widgets/admin_sidebar_drawer.dart';
import '../../config/theme.dart';

/// Placeholder screen for Admin modules that are under construction
/// Implements full navigation sidebar for consistency
class AdminPlaceholderScreen extends StatefulWidget {
  final String title;
  final String currentRoute;
  final IconData icon;

  const AdminPlaceholderScreen({
    super.key,
    required this.title,
    required this.currentRoute,
    this.icon = Icons.construction,
  });

  @override
  State<AdminPlaceholderScreen> createState() => _AdminPlaceholderScreenState();
}

class _AdminPlaceholderScreenState extends State<AdminPlaceholderScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _handleNavigation(String route) {
    // Close drawer first
    Navigator.pop(context);

    if (route == widget.currentRoute) return;

    // Map routes to navigation
    switch (route) {
      case 'dashboard':
      case 'ruc_approvals':
        Navigator.pushNamed(context, '/admin_dashboard'); // Tab 0 default
        break;
      case 'cotizaciones':
        // We can't pass args easily to pushNamed without arguments object,
        // but dashboard defaults to 0.
        // Ideally we would push Replacement.
        Navigator.pushNamed(context, '/admin_dashboard');
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
    const primaryColor = AppColors.neonGreen;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: bgDark,
      drawer: AdminSidebarDrawer(
        currentRoute: widget.currentRoute,
        onNavigate: _handleNavigation,
      ),
      appBar: AppBar(
        title: Row(
          children: [
            Icon(widget.icon, color: primaryColor),
            const SizedBox(width: 8),
            Text(widget.title),
          ],
        ),
        backgroundColor: bgDark,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.icon, size: 80, color: Colors.grey[800]),
            const SizedBox(height: 24),
            Text(
              'Modulo: ${widget.title}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: const Text(
                'Próximamente',
                style:
                    TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Este módulo está en construcción.',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}
