import 'package:animate_do/animate_do.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../core/services/auth_service.dart';
import '../widgets/main_drawer.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  late VideoPlayerController _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() {
    _videoController = VideoPlayerController.asset(
      'assets/videos/video_importaYAia.com_web.mp4',
    )..initialize().then((_) {
        if (mounted) {
          setState(() => _isVideoInitialized = true);
          _videoController.setLooping(true);
          _videoController.setVolume(0); // Muted autoplay
          _videoController.play();
        }
      });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Theme Awareness
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = theme.scaffoldBackgroundColor;

    // Blob colors need to be subtle in light mode
    final blobColor = isDark
        ? AppColors.neonGreen.withAlpha(13) // ~0.05
        : Colors.purple.withAlpha(25); // Purple blobs for light mode contrast

    final blobShadowColor = isDark
        ? AppColors.neonGreen.withAlpha(25) // ~0.1
        : Colors.purple.withAlpha(38); // ~0.15

    return Scaffold(
      backgroundColor: bgColor,
      drawer: const MainDrawer(),
      body: Stack(
        children: [
          // Background Blobs
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: blobColor,
              ),
              child: ClipOval(
                child: Container(
                  color: blobColor,
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
                color: blobColor,
                boxShadow: [
                  BoxShadow(
                    color: blobShadowColor,
                    blurRadius: 120,
                    spreadRadius: 50,
                  )
                ],
              ),
            ),
          ),

          // Bottom Left Blob
          Positioned(
            bottom: -150,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? Colors.blue.withAlpha(13)
                    : Colors.blue.withAlpha(25),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.blue.withAlpha(25)
                        : Colors.blue.withAlpha(38),
                    blurRadius: 100,
                    spreadRadius: 20,
                  )
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Builder(
                  builder: (scaffoldContext) =>
                      _buildHeader(scaffoldContext, isDark),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeroVideo(isDark, bgColor),
                          _buildMainContent(context, isDark),
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

  Widget _buildHeader(BuildContext context, bool isDark) {
    // Text color logic
    final textColor = isDark ? AppColors.textWhite : Colors.black87;
    final iconColor = isDark ? AppColors.textWhite : Colors.black87;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              // Auth-aware logo navigation
              final authService =
                  Provider.of<AuthService>(context, listen: false);
              if (authService.isLoggedIn) {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/dashboard', (route) => false);
              } else {
                // Refresh landing page
                Navigator.pushNamedAndRemoveUntil(
                    context, '/', (route) => false);
              }
            },
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.neonGreen.withAlpha(51), // ~0.2
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppColors.neonGreen.withAlpha(76)), // ~0.3
                  ),
                  child: const Icon(Icons.inventory_2_outlined,
                      color: AppColors.neonGreen, size: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  "ImportaYAia",
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const Text(
                  ".com",
                  style: TextStyle(
                    color: AppColors.neonGreen,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Scaffold.of(context).openDrawer();
              },
              borderRadius: BorderRadius.circular(50),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.menu, color: iconColor, size: 30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroVideo(bool isDark, Color bgColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SizedBox(
        height: 256,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(24)),
              ),
              clipBehavior: Clip.hardEdge,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Video Player
                  _isVideoInitialized
                      ? FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: _videoController.value.size.width,
                            height: _videoController.value.size.height,
                            child: VideoPlayer(_videoController),
                          ),
                        )
                      : Container(
                          color: isDark
                              ? AppColors.darkBlueBackground
                              : Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.neonGreen,
                            ),
                          ),
                        ),
                  // Primary Overlay
                  Container(
                    color: AppColors.neonGreen.withAlpha(25), // ~0.1
                  ),
                  // Gradient Overlay - To blend video into background
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                        colors: [
                          bgColor.withAlpha(204), // 0.8 opacity matching bg
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
                          bgColor.withAlpha(76), // 0.3
                          bgColor.withAlpha(230), // 0.9
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
                border: Border.all(
                    color: isDark
                        ? Colors.white.withAlpha(13)
                        : Colors.black.withAlpha(13)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, bool isDark) {
    // Text colors
    final titleColor = isDark ? AppColors.textWhite : Colors.black87;
    final bodyColor =
        isDark ? AppColors.textGrey : const Color(0xFF4B5563); // Gray 600

    // Badge colors
    final badgeBg = isDark ? AppColors.surface : Colors.white;
    final badgeBorder =
        isDark ? Colors.white.withAlpha(25) : Colors.black.withAlpha(13);

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
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: badgeBorder),
                  boxShadow: isDark
                      ? []
                      : [
                          BoxShadow(
                              color: Colors.black.withAlpha(13),
                              blurRadius: 4,
                              offset: const Offset(0, 2))
                        ]),
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
                      color: AppColors.textGrey, // Keep grey for neutral look
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
              text: TextSpan(
                style: TextStyle(
                  fontFamily: 'Space Grotesk',
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                  color: titleColor,
                ),
                children: const [
                  TextSpan(text: "Importa fácil, \n"),
                  TextSpan(
                    text: "sin complicaciones!",
                    style: TextStyle(color: AppColors.neonGreen),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Description
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: Text(
              "Logística inteligente potenciada por IA para tu negocio. Trae tus productos del mundo a tu bodega con un solo clic.",
              style: TextStyle(
                color: bodyColor,
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
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/login',
                        arguments: {'redirectTo': '/home'},
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.neonGreen,
                      foregroundColor:
                          AppColors.darkBlueBackground, // Contrast text color
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
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
                      Navigator.pushNamed(context, '/login');
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor:
                          isDark ? AppColors.surface : Colors.white,
                      foregroundColor:
                          titleColor, // Dark text on light, White on dark
                      side: BorderSide(
                          color: isDark
                              ? Colors.white.withAlpha(25)
                              : Colors.grey.withAlpha(76)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: isDark ? 0 : 1,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Ya tengo Cuenta",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.chevron_right,
                            size: 20,
                            color:
                                isDark ? AppColors.textGrey : Colors.black54),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
          Divider(
              color: isDark
                  ? Colors.white.withAlpha(13)
                  : Colors.black.withAlpha(13)),
          const SizedBox(height: 24),

          // Footer / App Stores
          FadeInUp(
            delay: const Duration(milliseconds: 600),
            child: Column(
              children: [
                Text(
                  "Descarga la App",
                  style: TextStyle(
                    color: bodyColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStoreButton(
                        icon: Icons.phone_iphone,
                        topText: "Consíguelo en el",
                        bottomText: "App Store",
                        isDark: isDark),
                    const SizedBox(width: 16),
                    _buildStoreButton(
                        icon: Icons.android,
                        topText: "Disponible en",
                        bottomText: "Google Play",
                        isDark: isDark),
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
      required String bottomText,
      required bool isDark}) {
    final bg = isDark ? AppColors.surface : Colors.white;
    final border =
        isDark ? Colors.white.withAlpha(25) : Colors.grey.withAlpha(76);
    final primaryText = isDark ? AppColors.textWhite : Colors.black87;
    final secondaryText = isDark ? AppColors.textGrey : const Color(0xFF4B5563);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                      color: Colors.black.withAlpha(13),
                      blurRadius: 4,
                      offset: const Offset(0, 2))
                ]),
      child: Row(
        children: [
          Icon(icon, color: primaryText, size: 28),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(topText,
                  style: TextStyle(
                      color: secondaryText, fontSize: 10, height: 1.0)),
              Text(bottomText,
                  style: TextStyle(
                      color: primaryText,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }
}
