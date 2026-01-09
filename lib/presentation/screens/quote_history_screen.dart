import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../core/api/auth_repository.dart';
import 'home_screen.dart';
import 'quote_request_screen.dart';
import 'quote_detail_screen.dart';
import 'tracking_screen.dart';
import 'profile_screen.dart';

class QuoteHistoryScreen extends StatefulWidget {
  const QuoteHistoryScreen({super.key});

  @override
  State<QuoteHistoryScreen> createState() => _QuoteHistoryScreenState();
}

class _QuoteHistoryScreenState extends State<QuoteHistoryScreen> {
  final AuthRepository _authRepo = AuthRepository();
  String _userName = "Prueba"; // Mock fallback

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  void _loadUserName() async {
    final userData = await _authRepo.getUserData();
    if (mounted && userData['name'] != null && userData['name']!.isNotEmpty) {
      setState(() {
        _userName = userData['name']!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Theme Awareness
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgBackgroundColor = theme.scaffoldBackgroundColor;
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final secondaryText = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    // Explicit colors for status/icons that need to be visible on both
    final primaryColor = AppColors.neonGreen;

    return Scaffold(
      backgroundColor: bgBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF111827) : Colors.white,
        elevation: 0,
        iconTheme:
            IconThemeData(color: textColor), // Ensures back button is visible
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                  color: primaryColor, borderRadius: BorderRadius.circular(8)),
              child: const Center(
                  child: Text("IA",
                      style: TextStyle(
                          color: Color(0xFF111827),
                          fontWeight: FontWeight.bold,
                          fontSize: 12))),
            ),
            const SizedBox(width: 8),
            Text("ImportaYA.ia",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: textColor)),
          ],
        ),
        actions: [
          Center(
              child: Text("Hola, $_userName",
                  style: TextStyle(
                      color: secondaryText,
                      fontSize: 14,
                      fontWeight: FontWeight.w500))),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header & CTA
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Administrador de Cotizaciones",
                            style: TextStyle(
                                color: textColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(
                            "Gestiona tus solicitudes y cotizaciones recibidas",
                            style:
                                TextStyle(color: secondaryText, fontSize: 12)),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const QuoteRequestScreen())),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: const Color(0xFF111827),
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10)),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text("Nueva Solicitud",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  )
                ],
              ),
              const SizedBox(height: 24),

              // Summary Cards (Horizontal Scroll)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildSummaryCard(
                        title: "Total",
                        count: "2",
                        icon: Icons.analytics,
                        color: Colors.blue,
                        cardColor: cardColor,
                        textColor: textColor),
                    const SizedBox(width: 12),
                    _buildSummaryCard(
                        title: "En Espera",
                        count: "0",
                        icon: Icons.hourglass_empty,
                        color: Colors.yellow,
                        cardColor: cardColor,
                        textColor: textColor),
                    const SizedBox(width: 12),
                    _buildSummaryCard(
                        title: "Cotizadas",
                        count: "0",
                        icon: Icons.assignment,
                        color: Colors.blue.shade300,
                        cardColor: cardColor,
                        textColor: textColor),
                    const SizedBox(width: 12),
                    _buildSummaryCard(
                        title: "Aprobadas sin RO",
                        count: "0",
                        icon: Icons.check_circle,
                        color: Colors.green,
                        cardColor: cardColor,
                        textColor: textColor),
                    const SizedBox(width: 12),
                    _buildSummaryCard(
                        title: "Con SI y RO",
                        count: "2",
                        icon: Icons.inventory_2,
                        color: Colors.purple,
                        cardColor: cardColor,
                        textColor: textColor),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Filters
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: isDark
                            ? Colors.white10
                            : Colors.grey.withAlpha(50))),
                child: Column(
                  children: [
                    // Row 1: Status & Transport
                    Row(
                      children: [
                        Expanded(
                            child: _buildFilterDropdown(
                                "Estado", "Con SI y RO", isDark, textColor)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildFilterDropdown(
                                "Transp.", "Todos", isDark, textColor)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Row 2: Date Range
                    Row(
                      children: [
                        Expanded(
                            child: _buildDateInput("Desde", isDark, textColor)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildDateInput("Hasta", isDark, textColor)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                            foregroundColor: secondaryText,
                            side: BorderSide(
                                color: isDark
                                    ? Colors.white24
                                    : Colors.grey.withAlpha(50))),
                        child: const Text("Limpiar Filtros"),
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Headers Table (Desktop hidden on mobile usually, but let's keep it simple or mimic list)
              // We'll stick to the card list view as per HTML mobile responsiveness

              // Quote Card 1
              _buildQuoteCard(
                  id: "COTI-YAia-000026",
                  type: "FCL",
                  date: "23-dic",
                  route: "Qingdao → Guayaquil",
                  status: "Con S/I y RO",
                  subStatus: "RO: RO-YAIA-2025-000002",
                  total: "\$2.323,00",
                  statusColor: Colors.purple,
                  cardColor: cardColor,
                  textColor: textColor,
                  secondaryText: secondaryText,
                  isDark: isDark),
              const SizedBox(height: 16),
              // Quote Card 2
              _buildQuoteCard(
                  id: "COTI-YAia-000025",
                  type: "FCL",
                  date: "22-dic",
                  route: "Shanghái → Guayaquil",
                  status: "Con S/I y RO",
                  subStatus: "RO: RO-YAIA-2025-000001",
                  total: "\$2.072,00",
                  statusColor: Colors.purple,
                  cardColor: cardColor,
                  textColor: textColor,
                  secondaryText: secondaryText,
                  isDark: isDark),

              const SizedBox(height: 80), // Bottom space
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, "Home",
                isActive: false,
                isDark: isDark,
                onTap: () => Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()))),
            _buildNavItem(Icons.request_quote, "Cotizaciones",
                isActive: true, isDark: isDark),
            const SizedBox(width: 48), // FAB Space
            _buildNavItem(Icons.local_shipping, "Envíos",
                isDark: isDark,
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const TrackingScreen()))),
            _buildNavItem(Icons.person, "Perfil",
                isDark: isDark,
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()))),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {}, // AI Assistant
        backgroundColor: primaryColor,
        child: const Icon(Icons.smart_toy, color: Color(0xFF0F172A)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildSummaryCard(
      {required String title,
      required String count,
      required IconData icon,
      required Color color,
      required Color cardColor,
      required Color textColor}) {
    return Container(
      width: 160,
      height: 110,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withAlpha(30)),
      ),
      child: Stack(
        children: [
          Positioned(
              left: -16,
              top: -16,
              bottom: -16,
              width: 4,
              child: Container(color: color)),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(title.toUpperCase(),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              Text(count,
                  style: TextStyle(
                      color: textColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(
      String label, String value, bool isDark, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        const SizedBox(height: 4),
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
              color: isDark ? const Color(0xFF374151) : Colors.grey[200],
              borderRadius: BorderRadius.circular(8)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value, style: TextStyle(color: textColor, fontSize: 13)),
              const Icon(Icons.arrow_drop_down, color: Colors.grey),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildDateInput(String label, bool isDark, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        const SizedBox(height: 4),
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
              color: isDark ? const Color(0xFF374151) : Colors.grey[200],
              borderRadius: BorderRadius.circular(8)),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("dd/mm/aaaa",
                  style: TextStyle(color: Colors.grey, fontSize: 13)),
              Icon(Icons.calendar_today, color: Colors.grey, size: 16),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildQuoteCard(
      {required String id,
      required String type,
      required String date,
      required String route,
      required String status,
      required String subStatus,
      required String total,
      required Color statusColor,
      required Color cardColor,
      required Color textColor,
      required Color secondaryText,
      required bool isDark}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withAlpha(30)),
      ),
      child: Column(
        children: [
          // Top Row: ID, Type, Date
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon representation
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: Colors.blue.shade900,
                    borderRadius: BorderRadius.circular(6)),
                child: const Center(
                    child:
                        Icon(Icons.description, color: Colors.white, size: 20)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(id,
                            style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF374151)
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(4)),
                          child: Text(type,
                              style: TextStyle(
                                  color: secondaryText,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(date,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 12),

          // Route
          Row(
            children: [
              const SizedBox(width: 52), // indent to align with text above
              Expanded(
                  child: Text(route,
                      style: TextStyle(color: secondaryText, fontSize: 13))),
            ],
          ),
          const SizedBox(height: 12),

          // Status & Total
          Row(
            children: [
              const SizedBox(width: 52),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                          color: statusColor.withAlpha(50),
                          borderRadius: BorderRadius.circular(4)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                  color: statusColor, shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          Text(status,
                              style: TextStyle(
                                  color: statusColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                          color: AppColors.neonGreen.withAlpha(25),
                          borderRadius: BorderRadius.circular(4)),
                      child: const Text(
                          "RO: RO-YAIA-2025-000002", // Mock fix for variable usage
                          style: TextStyle(
                              color: Color(0xFF90C8ac), fontSize: 10)),
                    )
                  ],
                ),
              ),
              Text(total,
                  style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),

          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildActionBtn(Icons.visibility, "Detalle", Colors.grey,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => QuoteDetailScreen(quoteId: id)))),
              const SizedBox(width: 8),
              _buildActionBtn(Icons.picture_as_pdf, "PDF", AppColors.neonGreen),
              const SizedBox(width: 8),
              _buildActionBtn(Icons.location_on, "Tracking", Colors.purple,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => TrackingScreen(quoteId: id)))),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildActionBtn(IconData icon, String label, Color color,
      {VoidCallback? onTap}) {
    // Correct color for visibility
    // On light mode neonGreen text is hard to read? Maybe keep it dark for light mode or robust color

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withAlpha(76)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    color: color, fontSize: 11, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label,
      {bool isActive = false, VoidCallback? onTap, required bool isDark}) {
    final inactiveColor = isDark ? Colors.grey : Colors.grey[600];
    // If light mode, neonGreen on white might be low contrast.
    // Use darker green for light mode active state?
    final effectiveActiveColor =
        isDark ? AppColors.neonGreen : Colors.green[700];

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              color: isActive ? effectiveActiveColor : inactiveColor, size: 24),
          Text(label,
              style: TextStyle(
                  color: isActive ? effectiveActiveColor : inactiveColor,
                  fontSize: 10)),
        ],
      ),
    );
  }
}
