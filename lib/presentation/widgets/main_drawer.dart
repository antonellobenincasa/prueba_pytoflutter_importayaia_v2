// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import '../screens/notifications_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/contact_screen.dart';
import '../screens/about_us_screen.dart';
import '../../config/theme.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // HTML uses 'bg-background-dark' for the drawer content.
    return Drawer(
      backgroundColor: AppColors.darkBlueBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(0), bottomRight: Radius.circular(0)),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(context),

          // Navigation Links
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              children: [
                _buildMenuItem(
                  context,
                  icon: Icons.home, // material-symbols-filled home
                  title: "Inicio",
                  onTap: () => Navigator.pushReplacementNamed(context, '/'),
                  isArrowVisible: true,
                  isActive: true, // Simulated for 'Inicio', could be dynamic
                ),
                const SizedBox(height: 8),
                _buildMenuItem(
                  context,
                  icon: Icons.groups, // groups
                  title: "Nosotros",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutUsScreen()));
                  },
                ),
                const SizedBox(height: 8),
                _buildMenuItem(
                  context,
                  icon: Icons.mail, // mail
                  title: "Contacto",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactScreen()));
                  },
                ),

                const SizedBox(height: 24),
                // Divider Gradient
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white.withOpacity(0.1),
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
                     duration: const Duration(milliseconds: 2500), // Slower pulse
                     child: Container(
                       decoration: BoxDecoration(
                         borderRadius: BorderRadius.circular(16),
                         boxShadow: [
                           BoxShadow(
                             color: AppColors.neonGreen.withOpacity(0.4),
                             blurRadius: 10, // Base glow
                             offset: const Offset(0, 4),
                           )
                         ]
                       ),
                       child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/quote_form');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.neonGreen,
                          foregroundColor: const Color(0xFF111C2E), // cta-text
                          padding: const EdgeInsets.symmetric(vertical: 20), // py-6 -> approx 24
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0, // Handled by container shadow for the glow effect
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
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 32), // pt-safe area adjusted
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Close button logic handled by Drawer overlay usually, but HTML has an absolute close button.
          // Flutter's drawer gesture handles close. We can add a close button if explicitly needed, but
          // standard drawer usage implies tapping outside or back.
          // Let's stick to the visual content.

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
               Container(
                width: 64,
                height: 64, // size-16
                decoration: BoxDecoration(
                  color: const Color(0xFF0A101D), // bg-surface-dark
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                   boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2), // shadow-inner approx
                    )
                   ]
                ),
                child: InkWell(
                  onTap: () {
                     Navigator.pop(context);
                     Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Center(
                    child: Icon(Icons.local_shipping, size: 40, color: AppColors.neonGreen),
                  ),
                ),
              ),
              const SizedBox(width: 16), // gap-3 (12px) - adjusted
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "ImportaYA.ia",
                     style: TextStyle(
                      color: Colors.white,
                      fontSize: 24, // text-2xl
                      fontWeight: FontWeight.bold,
                      height: 1.0, 
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Logística Inteligente",
                    style: TextStyle(
                      color: Colors.grey[400], // text-gray-400
                      fontSize: 14,
                      fontWeight: FontWeight.w300, 
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                onPressed: () {
                   Navigator.pop(context);
                   Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
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
      bool isArrowVisible = false,
      bool isActive = false}) {
    
    // HTML styles: p-4 rounded-xl hover:bg-white/5 transition-all
    // Active style: bg-white/5 border border-white/5
    
    return Material(
      color: isActive ? Colors.white.withOpacity(0.05) : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      shape: isActive 
        ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.white.withOpacity(0.05)))
        : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        hoverColor: Colors.white.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, 
                color: isActive ? Colors.white : Colors.grey[400], // group-hover:text-primary handled by click state in flutter usually or simplistic logic
                size: 24
              ), 
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isActive ? Colors.white : Colors.grey[300],
                    fontSize: 16,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
              if (isArrowVisible)
                Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[500]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      color: const Color(0xFF070E1A), // bg-[#070E1A]
      decoration: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
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
                    color: const Color(0xFF0A101D), // bg-surface-dark
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: const Center(
                    child: Icon(Icons.login, size: 20, color: AppColors.neonGreen),
                  ),
                ),
                 const SizedBox(width: 16),
                 const Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text(
                       "Iniciar Sesión",
                       style: TextStyle(
                         color: Colors.white,
                         fontWeight: FontWeight.w600,
                       ),
                     ),
                     Text(
                       "Accede a tu cuenta",
                       style: TextStyle(
                         color: Color(0xFF6B7280), // text-gray-500
                         fontSize: 12,
                       ),
                     ),
                   ],
                 )
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "v2.4.0",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 10, 
                  fontFamily: 'monospace',
                  letterSpacing: 2.0,
                )
              ),
               Text(
                "IMPORTAYA © 2024",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 10, 
                  fontFamily: 'monospace',
                  letterSpacing: 2.0,
                )
              ),
            ],
          )
        ],
      ),
    );
  }
}