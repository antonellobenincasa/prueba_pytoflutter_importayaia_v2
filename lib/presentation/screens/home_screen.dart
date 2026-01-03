import 'package:flutter/material.dart';
import '../widgets/authenticated_drawer.dart';
import '../widgets/hover_card.dart';
import '../../config/theme.dart';
import '../../core/services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    // Verificar que el usuario esté logueado
    if (!_authService.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
    } else {
      // Fetch user profile from backend
      _fetchUserProfile();
    }
  }

  Future<void> _fetchUserProfile() async {
    await _authService.fetchUserProfile();
    if (mounted) {
      setState(() => _isLoadingProfile = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgDark = Color(0xFF050A14);
    const surfaceDark = Color(0xFF0A101D);
    const primaryColor = AppColors.neonGreen;

    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        title:
            Text("Mi Dashboard", style: Theme.of(context).textTheme.titleLarge),
        backgroundColor: bgDark,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
        ],
      ),
      drawer: const AuthenticatedDrawer(),
      body: _isLoadingProfile
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.neonGreen),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Verification Pending Banner
                  if (!_authService.isRucApproved) _buildVerificationBanner(),

                  // Welcome Header
                  _buildWelcomeHeader(primaryColor),
                  const SizedBox(height: 24),

                  // Status Card (RUC Status)
                  _buildStatusCard(surfaceDark, primaryColor),
                  const SizedBox(height: 24),

                  // Quick Actions Grid
                  Text(
                    "Acciones Rápidas",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  _buildQuickActionsGrid(context, surfaceDark, primaryColor),
                  const SizedBox(height: 24),

                  // Main Features
                  Text(
                    "Mis Herramientas",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureCards(context, surfaceDark, primaryColor),
                ],
              ),
            ),
    );
  }

  Widget _buildVerificationBanner() {
    final isPending = _authService.rucStatus == 'pending';
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withValues(alpha: 0.2),
            Colors.orange.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            isPending ? Icons.hourglass_top : Icons.warning_amber,
            color: Colors.orange,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPending ? "Verificación Pendiente" : "Completa tu Perfil",
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isPending
                      ? "Tu RUC está siendo verificado. Te notificaremos pronto."
                      : "Agrega tu RUC para acceder a todas las funciones.",
                  style: TextStyle(
                    color: Colors.orange.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (!isPending)
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/profile'),
              child: const Text("Completar"),
            ),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader(Color primaryColor) {
    final userName = _authService.userName ?? 'Usuario';
    final email = _authService.userEmail ?? '';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor.withValues(alpha: 0.1),
            primaryColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                style: TextStyle(
                  color: primaryColor,
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
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (email.isNotEmpty)
                  Text(
                    email,
                    style: TextStyle(
                      color: Colors.grey[500],
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

  Widget _buildStatusCard(Color surfaceDark, Color primaryColor) {
    final rucStatus = _authService.rucStatus;
    final isRucApproved = _authService.isRucApproved;

    String statusText;
    Color statusColor;
    IconData statusIcon;

    if (isRucApproved) {
      statusText = "RUC Aprobado";
      statusColor = primaryColor;
      statusIcon = Icons.check_circle;
    } else if (rucStatus == 'pending') {
      statusText = "RUC Pendiente de Aprobación";
      statusColor = Colors.orange;
      statusIcon = Icons.hourglass_top;
    } else {
      statusText = "Completa tu perfil para continuar";
      statusColor = Colors.amber;
      statusIcon = Icons.warning_amber;
    }

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/profile'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: statusColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(statusIcon, color: statusColor, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Estado de tu cuenta",
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[600], size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsGrid(
      BuildContext context, Color surfaceDark, Color primaryColor) {
    final isRucApproved = _authService.isRucApproved;

    return Row(
      children: [
        Expanded(
          child: _buildQuickActionCard(
            icon: Icons.add_circle_outline,
            title: "Nueva\nCotización",
            color: primaryColor,
            isLocked: !isRucApproved,
            onTap: () => _handleFeatureAccess(context, '/quote_form'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionCard(
            icon: Icons.history,
            title: "Mis\nCotizaciones",
            color: Colors.blue,
            isLocked: !isRucApproved,
            onTap: () => _handleFeatureAccess(context, '/quote_history'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionCard(
            icon: Icons.local_shipping,
            title: "Tracking\nEmbarques",
            color: Colors.purple,
            isLocked: !isRucApproved,
            onTap: () => _handleFeatureAccess(context, '/tracking'),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
    bool isLocked = false,
  }) {
    return HoverCard(
      glowColor: color,
      onTap: onTap,
      isLocked: isLocked,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, color: isLocked ? Colors.grey : color, size: 32),
              if (isLocked)
                Positioned(
                  right: -8,
                  bottom: -8,
                  child: Icon(Icons.lock, color: Colors.grey[600], size: 14),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isLocked ? Colors.grey : Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCards(
      BuildContext context, Color surfaceDark, Color primaryColor) {
    final hasCompletedImport = _authService.hasCompletedImport;

    return Column(
      children: [
        _buildFeatureCard(
          icon: Icons.calculate,
          title: "Calculadora de Impuestos",
          subtitle: "Calcula aranceles y tributos de importación",
          color: Colors.teal,
          onTap: () => _handleFeatureAccess(context, '/tax_calculator'),
        ),
        const SizedBox(height: 12),
        _buildFeatureCard(
          icon: Icons.person,
          title: "Mi Perfil",
          subtitle: "Gestiona tus datos, RUC y empresa",
          color: Colors.indigo,
          onTap: () => Navigator.pushNamed(context, '/profile'),
        ),
        const SizedBox(height: 12),
        // Premium AI Feature Card
        _buildFeatureCard(
          icon: Icons.smart_toy,
          title: "AduanaExpertoIA",
          subtitle: hasCompletedImport
              ? "Tu asistente experto en aduanas"
              : "🔒 Completa tu primera importación para desbloquear",
          color: hasCompletedImport ? primaryColor : Colors.grey,
          isLocked: !hasCompletedImport,
          onTap: () {
            if (hasCompletedImport) {
              Navigator.pushNamed(context, '/aduana_experto');
            } else {
              _showLockedFeatureDialog(context);
            }
          },
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool isLocked = false,
  }) {
    return HoverListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color.withValues(alpha: isLocked ? 0.1 : 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, color: color.withValues(alpha: isLocked ? 0.5 : 1), size: 24),
            if (isLocked)
              Positioned(
                right: 2,
                bottom: 2,
                child: Icon(Icons.lock, color: Colors.grey[600], size: 14),
              ),
          ],
        ),
      ),
      title: title,
      subtitle: subtitle,
      color: color,
      isLocked: isLocked,
      onTap: onTap,
    );
  }

  void _handleFeatureAccess(BuildContext context, String route) {
    final isRucApproved = _authService.isRucApproved;
    final rucStatus = _authService.rucStatus;

    if (!isRucApproved) {
      if (rucStatus == 'pending') {
        _showPendingApprovalDialog(context);
      } else {
        _showCompleteProfileDialog(context);
      }
      return;
    }

    Navigator.pushNamed(context, route);
  }

  void _showCompleteProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0A101D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.amber),
            SizedBox(width: 12),
            Text("Completa tu perfil", style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Text(
          "Para acceder a esta función, primero debes completar tu perfil con el RUC de tu empresa.",
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

  void _showPendingApprovalDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0A101D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.hourglass_top, color: Colors.orange),
            SizedBox(width: 12),
            Text("RUC en revisión", style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Text(
          "Tu RUC está siendo revisado por nuestro equipo. Te notificaremos cuando sea aprobado para que puedas usar todas las funciones.",
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

  void _showLockedFeatureDialog(BuildContext context) {
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
          "AduanaExpertoIA es una función premium que se desbloquea después de completar tu primera importación con ImportaYA.ia.\n\n"
          "Completa el ciclo: Cotización → Aprobación → Instrucciones de Embarque → RO → Arribo → Facturación",
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cerrar"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/quote_form');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonGreen,
              foregroundColor: Colors.black,
            ),
            child: const Text("Crear Cotización"),
          ),
        ],
      ),
    );
  }
}
