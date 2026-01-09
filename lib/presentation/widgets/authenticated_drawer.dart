import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/firebase_service.dart';
import '../../core/services/theme_provider.dart';

class AuthenticatedDrawer extends StatelessWidget {
  const AuthenticatedDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userName = authService.userName ?? 'Usuario';
    final userEmail = authService.userEmail ?? '';
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Use drawerTheme or scaffoldBackgroundColor
    final bgColor = theme.scaffoldBackgroundColor;

    return Drawer(
      backgroundColor: bgColor,
      child: Column(
        children: [
          // Header con info del usuario
          _buildUserHeader(context, userName, userEmail, theme, isDark),

          // Navigation Links
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                _buildMenuItem(
                  context,
                  icon: Icons.dashboard,
                  title: "Dashboard",
                  isDark: isDark,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                  isActive: true,
                ),
                const SizedBox(height: 8),

                _buildSectionTitle("Cotizaciones", isDark),
                _buildMenuItem(
                  context,
                  icon: Icons.add_circle_outline,
                  title: "Nueva Cotización",
                  isDark: isDark,
                  onTap: () => _navigateWithCheck(context, '/quote_request'),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.history,
                  title: "Mis Cotizaciones",
                  isDark: isDark,
                  onTap: () => _navigateWithCheck(context, '/history'),
                ),
                const SizedBox(height: 16),

                _buildSectionTitle("Embarques", isDark),
                _buildMenuItem(
                  context,
                  icon: Icons.local_shipping,
                  title: "Tracking",
                  isDark: isDark,
                  onTap: () => _navigateWithCheck(context, '/tracking'),
                ),
                const SizedBox(height: 16),

                _buildSectionTitle("Herramientas", isDark),
                _buildMenuItem(
                  context,
                  icon: Icons.calculate,
                  title: "Calculadora de Impuestos",
                  isDark: isDark,
                  onTap: () => _navigateWithCheck(context, '/tax_calculator'),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.smart_toy,
                  title: "AduanaExpertoIA",
                  isDark: isDark,
                  isLocked: true, // Locked until first import
                  onTap: () {
                    Navigator.pop(context);
                    _showPremiumDialog(context);
                  },
                ),
                const SizedBox(height: 16),

                _buildSectionTitle("Mi Cuenta", isDark),
                _buildMenuItem(
                  context,
                  icon: Icons.person,
                  title: "Mi Perfil",
                  isDark: isDark,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/profile');
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.notifications,
                  title: "Notificaciones",
                  isDark: isDark,
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
                  color: isDark
                      ? Colors.white.withAlpha(25)
                      : Colors.black.withAlpha(25),
                ),
                const SizedBox(height: 16),

                // Links secundarios
                _buildMenuItem(
                  context,
                  icon: Icons.info_outline,
                  title: "Nosotros",
                  isDark: isDark,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/nosotros');
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.mail_outline,
                  title: "Contacto",
                  isDark: isDark,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/contacto');
                  },
                ),
              ],
            ),
          ),

          // Footer con logout
          _buildFooter(context, authService, theme, isDark),
        ],
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context, String userName,
      String userEmail, ThemeData theme, bool isDark) {
    final headerBg = isDark ? const Color(0xFF070E1A) : Colors.grey[200]!;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey[600];

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
      decoration: BoxDecoration(
        color: headerBg,
        border: Border(
          bottom: BorderSide(
              color: isDark
                  ? Colors.white.withAlpha(13)
                  : Colors.black.withAlpha(13)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.neonGreen.withAlpha(38), // ~0.15
              shape: BoxShape.circle,
              border:
                  Border.all(color: AppColors.neonGreen.withAlpha(76)), // ~0.3
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
                  style: TextStyle(
                    color: textColor,
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
                    color: subTextColor,
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

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: isDark ? Colors.grey[600] : Colors.grey[700],
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
    required bool isDark,
    bool isActive = false,
    bool isLocked = false,
  }) {
    final activeBg =
        isDark ? Colors.white.withAlpha(13) : Colors.black.withAlpha(13);
    final inactiveIcon = isDark ? Colors.grey[400] : Colors.grey[600];
    final activeIcon = AppColors.neonGreen; // Green works for both usually
    final textColor =
        isLocked ? Colors.grey[600] : (isDark ? Colors.white : Colors.black87);
    final fontWeight = isActive ? FontWeight.w600 : FontWeight.w400;

    return Material(
      color: isActive ? activeBg : Colors.transparent,
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
                        ? activeIcon
                        : inactiveIcon,
                size: 22,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: fontWeight,
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

  Widget _buildFooter(BuildContext context, AuthService authService,
      ThemeData theme, bool isDark) {
    final footerBg = isDark ? const Color(0xFF070E1A) : Colors.grey[200]!;
    final borderColor =
        isDark ? Colors.white.withAlpha(13) : Colors.black.withAlpha(13);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: footerBg,
        border: Border(
          top: BorderSide(color: borderColor),
        ),
      ),
      child: Column(
        children: [
          // Theme Switcher
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withAlpha(13) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: isDark
                          ? Colors.white.withAlpha(25)
                          : Colors.grey[300]!),
                ),
                child: SwitchListTile(
                  title: Text(
                    themeProvider.isDarkMode ? "Modo Oscuro" : "Modo Claro",
                    style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
                  secondary: Icon(
                    themeProvider.isDarkMode
                        ? Icons.dark_mode
                        : Icons.light_mode,
                    color: themeProvider.isDarkMode
                        ? Colors.purple[200]
                        : Colors.orange,
                  ),
                  value: themeProvider.isDarkMode,
                  activeThumbColor: AppColors.neonGreen,
                  trackColor: WidgetStateProperty.resolveWith<Color>((states) {
                    if (states.contains(WidgetState.selected)) {
                      return AppColors.neonGreen.withAlpha(100);
                    }
                    return isDark ? Colors.grey[700]! : Colors.grey[400]!;
                  }),
                  onChanged: (_) => themeProvider.toggleTheme(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
          ),

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
                side: BorderSide(color: Colors.red.withAlpha(76)), // ~0.3
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

  Future<void> _navigateWithCheck(BuildContext context, String route) async {
    // 1. Capture the navigator and its context BEFORE popping the drawer
    final navigator = Navigator.of(context);
    final navContext = navigator.context;

    // 2. Pop the drawer
    navigator.pop();

    // 3. Check RUC status directly from Firebase
    final firebaseService = FirebaseService();
    try {
      final userData = await firebaseService.getUserProfile();
      final rucStatus = userData?['ruc_status'] ?? '';

      // 4. Use the captured navigator
      if (rucStatus == 'approved') {
        navigator.pushNamed(route);
      } else {
        // Use the navigator's context to show the dialog
        if (navContext.mounted) {
          _showProfileRequiredDialog(navContext, rucStatus);
        }
      }
    } catch (e) {
      navigator.pushNamed(route);
    }
  }

  void _showProfileRequiredDialog(BuildContext context, String rucStatus) {
    String message;
    String title;

    if (rucStatus == 'pending') {
      title = 'RUC en revisión';
      message =
          'Tu RUC está siendo verificado por nuestro equipo. Te notificaremos cuando esté aprobado.';
    } else if (rucStatus == 'rejected') {
      title = 'RUC rechazado';
      message =
          'Tu RUC fue rechazado. Por favor actualiza la información en tu perfil.';
    } else {
      title = 'Perfil incompleto';
      message = 'Completa tu perfil con tu RUC para acceder a esta función.';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber,
                color: rucStatus == 'pending' ? Colors.blue : Colors.amber),
            const SizedBox(width: 12),
            Text(title), // Uses default content color (dynamic)
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.grey),
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
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.lock, color: Colors.grey),
            SizedBox(width: 12),
            Text("Función Premium"),
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
