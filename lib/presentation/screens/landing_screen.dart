import 'package:animate_do/animate_do.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../core/services/auth_service.dart';
import '../widgets/main_drawer.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlueBackground,
      endDrawer:
          const MainDrawer(), // Drawer on the right as per HTML menu position implying typical right-side menu or just hamburger
      // Actually standard Scaffold drawer is left, endDrawer is right.
      // HTML has menu on right. Let's use endDrawer for the menu button action.
      // But MainDrawer might be designed for left. Let's check MainDrawer later or just assume standard drawer.
      // If I use 'drawer', it opens from left. HTML Header has button on right.
      // I can open the 'drawer' (left) from a button on the right, that's fine.
      drawer: const MainDrawer(),
      body: Stack(
        children: [
          // Background Blobs
          // Top Right
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.neonGreen.withValues(alpha: 0.05),
              ),
              child: ClipOval(
                child: Container(
                  color: AppColors.neonGreen.withValues(alpha: 0.05),
                )
                    .animate(onPlay: (controller) => controller.repeat())
                    .blur(begin: const Offset(120, 120)),
              ),
            ),
          ),

          Positioned(
            top: -250,
            right: -150,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.neonGreen
                      .withValues(alpha: 0.05), // bg-primary/5
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonGreen.withValues(alpha: 0.1),
                      blurRadius: 120,
                      spreadRadius: 50,
                    )
                  ]),
            ),
          ),
          // Bottom Left
          Positioned(
            bottom: -150,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.withValues(alpha: 0.05), // bg-blue-500/5
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withValues(alpha: 0.1),
                      blurRadius: 100,
                      spreadRadius: 20,
                    )
                  ]),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Builder(
                    builder: (scaffoldContext) =>
                        _buildHeader(scaffoldContext)),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeroImage(),
                          _buildMainContent(context),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.neonGreen.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppColors.neonGreen.withValues(alpha: 0.3)),
                ),
                child: const Icon(Icons.inventory_2_outlined,
                    color: AppColors.neonGreen, size: 20),
              ),
              const SizedBox(width: 8),
              const Text(
                "ImportaYA.ia",
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Scaffold.of(context).openDrawer();
              },
              borderRadius: BorderRadius.circular(50),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.menu, color: AppColors.textWhite, size: 30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImage() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 16.0, vertical: 8.0), // mb-6 px-4 -> approx
      child: SizedBox(
        height: 256, // h-64 -> 16rem -> 256px
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Dark Overlay Gradient
            Container(
              decoration: const BoxDecoration(
                borderRadius:
                    BorderRadius.all(Radius.circular(24)), // rounded-3xl
              ),
              clipBehavior: Clip.hardEdge,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuDSwKKWGkvJs71r2d9tbvJAUFuj6tfbNYRfm3MSrkpcdKk3Cq5TbTz2WyPRNWE_yFGJ4L9QFZxqzAHd1QehcuF6ZqPer_v5n3ro0A0QQxYVvLE4XUCH4WyebuSzUqA7fi_iTet_r0-CErZdozgNqzYTKdk2YbXGftO2UIQvVAmFFzyPIqsF_rOdem9-O3pQBgQ63gPF43gTjeLuwKOL1rb85wL7ZuQsjoEUQlbnMeAZewGVDFS0xah6HTBwOmjeUwJvZdDQCRVq9sc',
                    fit: BoxFit.cover,
                  ),
                  // Primary Overlay mix-blend-overlay (approx with alpha)
                  Container(
                    color: AppColors.neonGreen.withValues(alpha: 0.1),
                  ),
                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                        colors: [
                          AppColors.darkBlueBackground.withValues(alpha: 0.8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  // Top Gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.darkBlueBackground
                              .withValues(alpha: 0.3), // via
                          AppColors.darkBlueBackground
                              .withValues(alpha: 0.9), // to
                        ],
                        stops: const [0.0, 0.7, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Border
            Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(24)),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge
          FadeInDown(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Pulse(
                    infinite: true,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.neonGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "LOGÍSTICA 4.0",
                    style: TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // H1 Title
          FadeInUp(
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontFamily:
                      'Space Grotesk', // Assuming system fallback or will work if setup
                  fontSize: 36, // 4xl
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                  color: AppColors.textWhite,
                ),
                children: [
                  TextSpan(text: "Importa fácil, \n"),
                  TextSpan(
                    text: "sin complicaciones!",
                    style: TextStyle(
                      color: AppColors
                          .neonGreen, // Gradient effect simplistic fallback
                      // For true gradient text we need ShaderMask, which is complex.
                      // Using neonGreen is a good faithful fallback for "primary" gradient
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Description
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: const Text(
              "Logística inteligente potenciada por IA para tu negocio. Trae tus productos del mundo a tu bodega con un solo clic.",
              style: TextStyle(
                color: AppColors.textGrey,
                fontSize: 18,
                height: 1.6,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Buttons
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: Column(
              children: [
                // COTIZA Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Verificar si hay sesión almacenada antes de decidir
                      final authService = AuthService();
                      await authService.checkStoredSession();

                      if (!context.mounted) return;

                      if (authService.isLoggedIn) {
                        // Usuario autenticado - ir al formulario de cotización
                        Navigator.pushNamed(context, '/quote_form');
                      } else {
                        // Redirigir a login - pasando parámetro para volver al quote form
                        Navigator.pushNamed(
                          context,
                          '/login',
                          arguments: {'redirectTo': '/quote_form'},
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.neonGreen,
                      foregroundColor: AppColors.darkBlueBackground,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      // shadowColor: AppColors.neonGreen.withValues(alpha: 0.3), // Manual shadow via container usually
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "COTIZA AHORA",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 24),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                          context, '/login'); // "Ya tengo Cuenta" -> Login
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.surface,
                      foregroundColor: AppColors.textWhite,
                      side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.1)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Ya tengo Cuenta",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.chevron_right,
                            size: 20, color: AppColors.textGrey),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
          Divider(color: Colors.white.withValues(alpha: 0.05)),
          const SizedBox(height: 24),

          // Footer / App Stores
          FadeInUp(
            delay: const Duration(milliseconds: 600),
            child: Column(
              children: [
                const Text(
                  "Descarga la App",
                  style: TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStoreButton(
                      icon: Icons.phone_iphone, // iOS
                      topText: "Consíguelo en el",
                      bottomText: "App Store",
                    ),
                    const SizedBox(width: 16),
                    _buildStoreButton(
                      icon: Icons.android, // Google Play
                      topText: "Disponible en",
                      bottomText: "Google Play",
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreButton(
      {required IconData icon,
      required String topText,
      required String bottomText}) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // px-4 py-2
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textWhite, size: 28),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(topText,
                  style: const TextStyle(
                      color: AppColors.textGrey, fontSize: 10, height: 1.0)),
              Text(bottomText,
                  style: const TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }
}
