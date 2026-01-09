import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/firebase_service.dart';
import '../../core/services/theme_provider.dart';
import '../widgets/authenticated_drawer.dart';
import '../widgets/hover_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AuthService _authService;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  Future<void> _loadUserData() async {
    _authService = Provider.of<AuthService>(context, listen: false);
    // Simulate or wait for user data if needed
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    // Theme logic
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgDark = theme.scaffoldBackgroundColor;
    final surfaceDark = theme.cardColor;
    final primaryColor = AppColors.neonGreen;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: bgDark,
      drawer: const AuthenticatedDrawer(),
      appBar: AppBar(
        backgroundColor: bgDark,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text(
          "MI Dashboard",
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: isDark ? Colors.white : Colors.black87,
            ),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
          IconButton(
            icon: Icon(Icons.notifications_none,
                color: isDark ? Colors.white : Colors.black87),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.neonGreen))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeHeader(
                      context, surfaceDark, primaryColor, isDark),
                  const SizedBox(height: 24),
                  _buildStatusCard(context, surfaceDark, primaryColor, isDark),
                  const SizedBox(height: 32),
                  Text(
                    "Acciones Rápidas",
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildQuickActionsGrid(
                      context, surfaceDark, primaryColor, isDark),
                  const SizedBox(height: 32),
                  Text(
                    "Mis Herramientas",
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureCards(
                      context, surfaceDark, primaryColor, isDark),
                  const SizedBox(height: 32), // Bottom spacing
                ],
              ),
            ),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context, Color surfaceDark,
      Color primaryColor, bool isDark) {
    final user = Provider.of<AuthService>(context).userData;
    final userName = user?['first_name'] ?? 'Usuario';
    final userEmail = _authService.userEmail ?? '';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.neonGreen.withAlpha(25)
            : Colors.green.withAlpha(25), // Tinted background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neonGreen.withAlpha(51)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.neonGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                style: const TextStyle(
                  color: Colors.black,
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
                  "¡Bienvenido!",
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                Text(
                  userName,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userEmail,
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, Color surfaceDark,
      Color primaryColor, bool isDark) {
    // We can pull RUC status from provider or user data
    final rucStatus = Provider.of<AuthService>(context).rucStatus;

    // Config based on status
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (rucStatus == 'approved') {
      statusColor = AppColors.neonGreen;
      statusText = "RUC Aprobado";
      statusIcon = Icons.check_circle;
    } else if (rucStatus == 'pending') {
      statusColor = Colors.orange;
      statusText = "RUC En Revisión";
      statusIcon = Icons.access_time_filled;
    } else {
      statusColor = Colors.red;
      statusText = "Perfil Incompleto";
      statusIcon = Icons.warning;
    }

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/profile'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
            color: isDark ? surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: isDark
                    ? Colors.white.withAlpha(13)
                    : Colors.grey.withAlpha(50)),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                        color: Colors.black.withAlpha(13),
                        blurRadius: 4,
                        offset: const Offset(0, 2))
                  ]),
        child: Row(
          children: [
            Icon(statusIcon, color: statusColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Estado de tu cuenta",
                    style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 10),
                  ),
                  Text(
                    statusText,
                    style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: isDark ? Colors.white : Colors.black54),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context, Color surfaceDark,
      Color primaryColor, bool isDark) {
    return SizedBox(
      height: 128, // Increased from 120 to fix overflow
      child: Row(
        children: [
          Expanded(
            child: HoverCard(
              onTap: () => _handleFeatureAccess(context, '/quote_form'),
              glowColor: AppColors.neonGreen,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.neonGreen),
                      ),
                      child: const Icon(Icons.add_circle_outline,
                          color: AppColors.neonGreen),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Nueva\nCotización",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: isDark ? Colors.grey[300] : Colors.grey[800],
                          fontSize: 11,
                          height: 1.2),
                    )
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: HoverCard(
              onTap: () => _handleFeatureAccess(context, '/history'),
              glowColor: Colors.blue,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.history, color: Colors.blue, size: 28),
                    const SizedBox(height: 12),
                    Text(
                      "Mis\nCotizaciones",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: isDark ? Colors.grey[300] : Colors.grey[800],
                          fontSize: 11,
                          height: 1.2),
                    )
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: HoverCard(
              onTap: () => _handleFeatureAccess(context, '/tracking'),
              glowColor: Colors.purple,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.local_shipping,
                        color: Colors.purple, size: 28),
                    const SizedBox(height: 12),
                    Text(
                      "Tracking\nEmbarques",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: isDark ? Colors.grey[300] : Colors.grey[800],
                          fontSize: 11,
                          height: 1.2),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCards(BuildContext context, Color surfaceDark,
      Color primaryColor, bool isDark) {
    return Column(
      children: [
        HoverListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.teal.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.calculate, color: Colors.teal),
          ),
          title: "Calculadora de Impuestos",
          subtitle: "Calcula aranceles y tributos de importación",
          color: Colors.teal,
          onTap: () => _handleFeatureAccess(context, '/tax_calculator'),
        ),
        const SizedBox(height: 12),
        HoverListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.indigo.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.person, color: Colors.indigo),
          ),
          title: "Mi Perfil",
          subtitle: "Gestiona tus datos, RUC y empresa",
          color: Colors.indigo,
          onTap: () => Navigator.pushNamed(context, '/profile'),
        ),
        const SizedBox(height: 12),
        HoverListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.smart_toy, color: Colors.amber),
          ),
          title: "AduanaExpertoIA",
          subtitle: "Completa tu primera importación para desbloquear",
          color: Colors.amber,
          isLocked: true,
          onTap: () {
            // Show premium dialog
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: isDark ? surfaceDark : Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                title: const Row(
                  children: [
                    Icon(Icons.lock, color: Colors.grey),
                    SizedBox(width: 8),
                    Text("Función Premium"),
                  ],
                ),
                content: const Text(
                    "Completa tu primera importación para desbloquear esta herramienta de IA."),
              ),
            );
          },
        ),
      ],
    );
  }

  void _handleFeatureAccess(BuildContext context, String route) async {
    // Basic RUC check before navigation
    final targetRoute = route == '/quote_form' ? '/quote_request' : route;

    if (targetRoute == '/quote_request' || targetRoute == '/quote_form') {
      final firebaseService = FirebaseService();
      // Show loading indicator or non-blocking check could be better?
      // For now, simple await
      try {
        final userData = await firebaseService.getUserProfile();
        final rucStatus = userData?['ruc_status'] ?? '';

        if (!context.mounted) return;

        if (rucStatus == 'approved') {
          Navigator.pushNamed(context, targetRoute);
        } else {
          _showProfileRequiredDialog(context, rucStatus);
        }
      } catch (e) {
        // Fallback if network fails
        if (context.mounted) Navigator.pushNamed(context, targetRoute);
      }
    } else {
      Navigator.pushNamed(context, targetRoute);
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
            Text(title),
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
}
