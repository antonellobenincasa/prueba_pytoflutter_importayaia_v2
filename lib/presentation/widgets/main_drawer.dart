// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/notifications_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/contact_screen.dart';
import '../screens/about_us_screen.dart';
import '../../config/theme.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/theme_provider.dart';
import '../../core/services/navigation_sound_service.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // Theme logic
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Use the scaffold background color from the theme
    final bgColor = theme.scaffoldBackgroundColor;

    return Drawer(
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(0), bottomRight: Radius.circular(0)),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(context, isDark),

          // Navigation Links
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              children: [
                _buildMenuItem(context,
                    icon: Icons.home, // material-symbols-filled home
                    title: "Inicio",
                    onTap: () => Navigator.pushReplacementNamed(context, '/'),
                    isArrowVisible: true,
                    isActive: true, // Simulated for 'Inicio', could be dynamic
                    isDark: isDark),
                const SizedBox(height: 8),
                _buildMenuItem(context,
                    icon: Icons.groups, // groups
                    title: "Nosotros", onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const AboutUsScreen()));
                }, isDark: isDark),
                const SizedBox(height: 8),
                _buildMenuItem(context,
                    icon: Icons.mail, // mail
                    title: "Contacto", onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ContactScreen()));
                }, isDark: isDark),

                // --- ADMIN PANEL ACCESS (Solo visible para admin/superuser) ---
                Consumer<AuthService>(
                  builder: (context, authService, _) {
                    final isAdmin = authService.userRole == 'admin' ||
                        authService.userRole == 'superuser';
                    if (!isAdmin) return const SizedBox.shrink();
                    return Column(
                      children: [
                        const SizedBox(height: 8),
                        _buildMenuItem(context,
                            icon: Icons.admin_panel_settings,
                            title: "Panel Admin", onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/admin_dashboard');
                        },
                            isActive: false,
                            isArrowVisible: true,
                            isDark: isDark),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 24),
                // Divider Gradient
                Container(
                  height: 1,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        isDark
                            ? Colors.white.withAlpha(25)
                            : Colors.black.withAlpha(25),
                        Colors.transparent
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Cotiza Ahora Button with glow/pulse
                // Using Pulse animation from animate_do
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Pulse(
                    infinite: true,
                    duration:
                        const Duration(milliseconds: 2500), // Slower pulse
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.neonGreen.withAlpha(102), // ~0.4
                              blurRadius: 10, // Base glow
                              offset: const Offset(0, 4),
                            )
                          ]),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // Verificar si el usuario está autenticado usando Provider
                          final authService =
                              Provider.of<AuthService>(context, listen: false);
                          if (authService.isLoggedIn) {
                            Navigator.pushNamed(context, '/quote_request');
                          } else {
                            // Redirigir a login si no está autenticado
                            Navigator.pushNamed(context, '/login');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.neonGreen,
                          foregroundColor: const Color(0xFF111C2E), // cta-text
                          padding: const EdgeInsets.symmetric(
                              vertical: 20), // py-6 -> approx 24
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation:
                              0, // Handled by container shadow for the glow effect
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "COTIZA AHORA",
                              style: TextStyle(
                                fontSize: 18, // text-xl
                                fontWeight: FontWeight.w900, // font-black
                                letterSpacing: 2.0, // tracking-widest
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.bolt, size: 28), // bolt symbol
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Footer
          _buildFooter(context, isDark),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final iconBoxColor = isDark ? const Color(0xFF0A101D) : Colors.white;
    final iconBoxBorder =
        isDark ? Colors.white.withAlpha(13) : Colors.black.withAlpha(13);

    return Container(
      padding:
          const EdgeInsets.fromLTRB(24, 60, 24, 32), // pt-safe area adjusted
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                    color: iconBoxColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: iconBoxBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(51), // ~0.2
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ]),
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ProfileScreen()));
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: const Center(
                    child: Icon(Icons.local_shipping,
                        size: 28, color: AppColors.neonGreen),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    final authService =
                        Provider.of<AuthService>(context, listen: false);
                    if (authService.isLoggedIn) {
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/dashboard', (route) => false);
                    } else {
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/', (route) => false);
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "ImportaYAia",
                            style: TextStyle(
                              color: textColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              height: 1.0,
                            ),
                          ),
                          const Text(
                            ".com",
                            style: TextStyle(
                              color: AppColors.neonGreen,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Logística Inteligente",
                        style: TextStyle(
                          color: subTextColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.notifications_outlined, color: textColor),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const NotificationsScreen()));
                },
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context,
      {required IconData icon,
      required String title,
      required VoidCallback onTap,
      required bool isDark,
      bool isArrowVisible = false,
      bool isActive = false}) {
    final activeBg =
        isDark ? Colors.white.withAlpha(13) : Colors.black.withAlpha(13);
    final activeText = isDark ? Colors.white : Colors.black;
    final inactiveText = isDark ? Colors.grey[300] : Colors.grey[700];
    final arrowColor = isDark ? Colors.grey[500] : Colors.grey[400];
    final hoverColor =
        isDark ? Colors.white.withAlpha(13) : Colors.black.withAlpha(13);

    final borderColor = isActive
        ? (isDark ? Colors.white.withAlpha(13) : Colors.black.withAlpha(13))
        : Colors.transparent;

    return Material(
      color: isActive ? activeBg : Colors.transparent,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: borderColor)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        hoverColor: hoverColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon,
                  color: isActive ? activeText : Colors.grey[400], size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isActive ? activeText : inactiveText,
                    fontSize: 16,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
              if (isArrowVisible)
                Icon(Icons.arrow_forward_ios, size: 14, color: arrowColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, bool isDark) {
    final footerBg = isDark ? const Color(0xFF070E1A) : Colors.grey[100]!;
    final borderTop = isDark ? Colors.white.withAlpha(13) : Colors.grey[300]!;
    final buttonBg = isDark ? const Color(0xFF0A101D) : Colors.white;
    final buttonBorder =
        isDark ? Colors.white.withAlpha(25) : Colors.grey[300]!;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? const Color(0xFF6B7280) : Colors.grey[600];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: footerBg,
        border: Border(top: BorderSide(color: borderTop)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/login');
            },
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40, // size-10
                  decoration: BoxDecoration(
                      color: buttonBg,
                      shape: BoxShape.circle,
                      border: Border.all(color: buttonBorder),
                      boxShadow: [
                        if (!isDark)
                          BoxShadow(
                              color: Colors.black.withAlpha(13), blurRadius: 4)
                      ]),
                  child: const Center(
                    child:
                        Icon(Icons.login, size: 20, color: AppColors.neonGreen),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Iniciar Sesión",
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "Accede a tu cuenta",
                      style: TextStyle(
                        color: subTextColor, // text-gray-500
                        fontSize: 12,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Theme and Sound Toggles
          Row(
            children: [
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, _) {
                  return InkWell(
                    onTap: () => themeProvider.toggleTheme(),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                          color: buttonBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: buttonBorder),
                          boxShadow: [
                            if (!isDark)
                              BoxShadow(
                                  color: Colors.black.withAlpha(13),
                                  blurRadius: 4)
                          ]),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            themeProvider.isDarkMode
                                ? Icons.light_mode
                                : Icons.dark_mode,
                            size: 16,
                            color: AppColors.neonGreen,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            themeProvider.isDarkMode ? 'Claro' : 'Oscuro',
                            style: TextStyle(
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[800],
                                fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              Consumer<NavigationSoundService>(
                builder: (context, soundService, _) {
                  return InkWell(
                    onTap: () => soundService.toggleSound(),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                          color: buttonBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: buttonBorder),
                          boxShadow: [
                            if (!isDark)
                              BoxShadow(
                                  color: Colors.black.withAlpha(13),
                                  blurRadius: 4)
                          ]),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            soundService.isEnabled
                                ? Icons.volume_up
                                : Icons.volume_off,
                            size: 16,
                            color: soundService.isEnabled
                                ? AppColors.neonGreen
                                : Colors.grey,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Sonido',
                            style: TextStyle(
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[800],
                                fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("v2.4.0",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 10,
                    fontFamily: 'monospace',
                    letterSpacing: 2.0,
                  )),
              Text("IMPORTAYA © 2024",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 10,
                    fontFamily: 'monospace',
                    letterSpacing: 2.0,
                  )),
            ],
          )
        ],
      ),
    );
  }
}
