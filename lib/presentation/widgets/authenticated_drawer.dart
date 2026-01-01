import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../core/services/auth_service.dart';

class AuthenticatedDrawer extends StatelessWidget {
  const AuthenticatedDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final userName = authService.userName ?? 'Usuario';
    final userEmail = authService.userEmail ?? '';
    final isRucApproved = authService.isRucApproved;
    final hasCompletedImport = authService.hasCompletedImport;

    return Drawer(
      backgroundColor: AppColors.darkBlueBackground,
      child: Column(
        children: [
          // Header con info del usuario
          _buildUserHeader(context, userName, userEmail),

          // Navigation Links
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                _buildMenuItem(
                  context,
                  icon: Icons.dashboard,
                  title: "Dashboard",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                  isActive: true,
                ),
                const SizedBox(height: 8),

                _buildSectionTitle("Cotizaciones"),
                _buildMenuItem(
                  context,
                  icon: Icons.add_circle_outline,
                  title: "Nueva Cotización",
                  onTap: () =>
                      _navigateWithCheck(context, '/quote_form', isRucApproved),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.history,
                  title: "Mis Cotizaciones",
                  onTap: () => _navigateWithCheck(
                      context, '/quote_history', isRucApproved),
                ),
                const SizedBox(height: 16),

                _buildSectionTitle("Embarques"),
                _buildMenuItem(
                  context,
                  icon: Icons.local_shipping,
                  title: "Tracking",
                  onTap: () =>
                      _navigateWithCheck(context, '/tracking', isRucApproved),
                ),
                const SizedBox(height: 16),

                _buildSectionTitle("Herramientas"),
                _buildMenuItem(
                  context,
                  icon: Icons.calculate,
                  title: "Calculadora de Impuestos",
                  onTap: () => _navigateWithCheck(
                      context, '/tax_calculator', isRucApproved),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.smart_toy,
                  title: "AduanaExpertoIA",
                  isLocked: !hasCompletedImport,
                  onTap: () {
                    Navigator.pop(context);
                    if (hasCompletedImport) {
                      Navigator.pushNamed(context, '/aduana_experto');
                    } else {
                      _showPremiumDialog(context);
                    }
                  },
                ),
                const SizedBox(height: 16),

                _buildSectionTitle("Mi Cuenta"),
                _buildMenuItem(
                  context,
                  icon: Icons.person,
                  title: "Mi Perfil",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/profile');
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.notifications,
                  title: "Notificaciones",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/notifications');
                  },
                ),

                const SizedBox(height: 24),
                // Divider
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white.withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Links secundarios
                _buildMenuItem(
                  context,
                  icon: Icons.info_outline,
                  title: "Nosotros",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/nosotros');
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.mail_outline,
                  title: "Contacto",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/contacto');
                  },
                ),
              ],
            ),
          ),

          // Footer con logout
          _buildFooter(context, authService),
        ],
      ),
    );
  }

  Widget _buildUserHeader(
      BuildContext context, String userName, String userEmail) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
      decoration: BoxDecoration(
        color: const Color(0xFF070E1A),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.neonGreen.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.neonGreen.withOpacity(0.3)),
            ),
            child: Center(
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                style: const TextStyle(
                  color: AppColors.neonGreen,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  userEmail,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isActive = false,
    bool isLocked = false,
  }) {
    return Material(
      color: isActive ? Colors.white.withOpacity(0.05) : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                icon,
                color: isLocked
                    ? Colors.grey[600]
                    : isActive
                        ? AppColors.neonGreen
                        : Colors.grey[400],
                size: 22,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isLocked ? Colors.grey[600] : Colors.white,
                    fontSize: 14,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              if (isLocked) Icon(Icons.lock, color: Colors.grey[600], size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, AuthService authService) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF070E1A),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                await authService.logout();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/');
                }
              },
              icon: const Icon(Icons.logout, size: 18),
              label: const Text("Cerrar Sesión"),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red[400],
                side: BorderSide(color: Colors.red.withOpacity(0.3)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "v2.4.0",
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 10,
                  fontFamily: 'monospace',
                ),
              ),
              Text(
                "© 2024 ImportaYA.ia",
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateWithCheck(
      BuildContext context, String route, bool isRucApproved) {
    Navigator.pop(context);
    if (isRucApproved) {
      Navigator.pushNamed(context, route);
    } else {
      _showProfileRequiredDialog(context);
    }
  }

  void _showProfileRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0A101D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.amber),
            SizedBox(width: 12),
            Text("Perfil incompleto", style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Text(
          "Completa tu perfil y espera la aprobación de tu RUC para acceder a esta función.",
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/profile');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonGreen,
              foregroundColor: Colors.black,
            ),
            child: const Text("Ir a Mi Perfil"),
          ),
        ],
      ),
    );
  }

  void _showPremiumDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0A101D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.lock, color: Colors.grey),
            SizedBox(width: 12),
            Text("Función Premium", style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Text(
          "AduanaExpertoIA se desbloquea después de completar tu primera importación con ImportaYA.ia.",
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonGreen,
              foregroundColor: Colors.black,
            ),
            child: const Text("Entendido"),
          ),
        ],
      ),
    );
  }
}
