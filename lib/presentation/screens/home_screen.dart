import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../core/api/auth_repository.dart';
import 'quote_form_screen.dart';
import 'login_screen.dart';
import 'quote_history_screen.dart';
import 'tax_calculator_screen.dart';
import 'chat_screen.dart';
import 'tracking_screen.dart';
import 'profile_screen.dart';
import 'cost_simulator_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthRepository _authRepo = AuthRepository();
  
  String _userName = "Cargando...";
  String _companyName = "";
  String _userRuc = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final userData = await _authRepo.getUserData();
    setState(() {
      _userName = (userData['name']?.isNotEmpty ?? false) ? userData['name']! : "Usuario";
      _companyName = userData['company'] ?? "Grupo Logístico SAC"; // Fallback to HTML design default if empty logic
      _userRuc = userData['ruc'] ?? "20555123456"; // Fallback to HTML default
    });
  }

  // Not directly used in HTML but good to keep for logic if we add a logout button somewhere (e.g. profile)
  void _logout() async {
    await _authRepo.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold setup for sticky header / bottom nav simulation
    return Scaffold(
      backgroundColor: AppColors.darkBlueBackground,
      body: Stack(
        children: [
          // Scrollable Content
          SafeArea(
            bottom: false, // Handle bottom padding manually for nav bar
            child: CustomScrollView(
              slivers: [
                // Sticky Header
                SliverAppBar(
                  backgroundColor: AppColors.darkBlueBackground.withOpacity(0.9),
                  pinned: true,
                  floating: true,
                  elevation: 0,
                  automaticallyImplyLeading: false, // Custom header content
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(1.0),
                    child: Container(color: const Color(0xFF111C2E), height: 1.0),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: ClipRect(
                       // BackdropFilter is expensive in slivers sometimes but let's try or just opacity
                       // HTML says backdrop-blur-md. Flutter standard AppBar with opacity usually works well.
                    ),
                    titlePadding: EdgeInsets.zero,
                    title: Padding( // Custom title widget instead of 'title' property to allow full control
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), // px-4 py-4 approx
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                           Row(
                             children: [
                               // Avatar
                               Container(
                                 width: 40,
                                 height: 40,
                                 decoration: BoxDecoration(
                                   shape: BoxShape.circle,
                                   border: Border.all(color: AppColors.neonGreen.withOpacity(0.2), width: 2),
                                   image: const DecorationImage(
                                     image: NetworkImage("https://lh3.googleusercontent.com/aida-public/AB6AXuBxeSTtCUKPpx9rWJfXVXiSeLPXtmu2LhVUMw_GZvHDBHMrtBr_VdNFhFndVb1-gaPgKSBKRf0u26MpgdAaJ6jzlSfbzP-suVI7bFxFE27PPU8ThtVmWQrzlr4LNREi-Hb5ZpPnDysvFPgEZ9bvdseAtc0cchOb1GYyt2pmcTGDZ1bREGf1FuURAKbvOndVlqCF2YIACXLHMjc2Dxz-Pj5j6-2ewXY3OdTNYfE6GZvnhW2rk8ecjQk4QBPtNw9tvnNCkh8wOhjfS9c"),
                                     fit: BoxFit.cover,
                                   )
                                 ),
                                 child: Stack(
                                   children: [
                                     Positioned(
                                       bottom: 0,
                                       right: 0,
                                       child: Container(
                                         width: 12,
                                         height: 12,
                                         decoration: BoxDecoration(
                                           color: AppColors.neonGreen,
                                           shape: BoxShape.circle,
                                            border: Border.all(color: AppColors.darkBlueBackground, width: 2),
                                         ),
                                       ),
                                     )
                                   ],
                                 ),
                               ),
                               const SizedBox(width: 12),
                               Column(
                                 mainAxisSize: MainAxisSize.min,
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   // "Bienvenido" - scale down if scrolled? No, simple static header is fine for now
                                   const Text(
                                     "Bienvenido",
                                     style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 10, fontWeight: FontWeight.normal), // text-xs
                                   ),
                                   Text(
                                     _companyName.isNotEmpty ? _companyName : "Grupo Logístico SAC",
                                     style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold), // text-base
                                   ),
                                 ],
                               )
                             ],
                           ),
                           // Notification Icon
                           Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: Color(0xFF111C2E), // bg-surface-dark
                              shape: BoxShape.circle,
                            ),
                            child: Stack(
                              children: [
                                const Center(child: Icon(Icons.notifications_outlined, color: Colors.white, size: 24)),
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: const Color(0xFF111C2E)),
                                    ),
                                  ),
                                )
                              ],
                            ),
                           )
                        ],
                      ),
                    ),
                  ),
                ),

                // Content Slivers
                SliverList(
                  delegate: SliverChildListDelegate([
                    // RUC Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24), // py-6
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF111C2E),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF1C2A3E)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("TU IDENTIFICADOR", style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                                const SizedBox(height: 4),
                                Text(_userRuc.isNotEmpty ? "RUC $_userRuc" : "RUC 20555123456", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.neonGreen.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(color: AppColors.neonGreen.withOpacity(0.2)),
                              ),
                              child: Row(
                                children: [
                                  Pulse(
                                    infinite: true,
                                    child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.neonGreen, shape: BoxShape.circle)),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text("APROBADO", style: TextStyle(color: AppColors.neonGreen, fontSize: 12, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),

                    // Services Section
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text("Servicios Principales", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          _buildServiceCard(
                            step: "Paso 1",
                            title: "Solicitar Cotización\nde Transporte",
                            subtitle: "Genera tu cotización automática",
                            icon: Icons.inventory_2_outlined,
                            stepColor: Colors.blue,
                            imageUrl: "https://lh3.googleusercontent.com/aida-public/AB6AXuChrCu_9SLztN8-URI05eJtqEyx3n0AyyTb3s-NK1kr7AZYWYwBVMt0UbZiVFOyzPguMeZtAAIGntiBSJX2frfBrW3wky8mXYp0h65yR7XXVsNn-U9rHvypqis1yEs3xBAOyBrLArfvdrna6_mXyBtDJNh2pUYmuYcPLhu4NrWQHnbx1tTOFwojDKb97F_rfrot1AIZkL51PNGeksoMCLgikGhvR1V4-Z50HIm1E11-bGiEdnWsKgu7gAlroY8ZzY-xoQKRLw_rjJo",
                            onTap: () => Navigator.pushNamed(context, '/quote_form'),
                          ),
                          const SizedBox(height: 12),
                          _buildServiceCard(
                            step: "Paso 2",
                            title: "Administrador\nde Cotizaciones",
                            subtitle: "Visualiza y revisa tus cotizaciones",
                            icon: Icons.dashboard_outlined,
                            stepColor: Colors.purple,
                            imageUrl: "https://lh3.googleusercontent.com/aida-public/AB6AXuA48_nn0VNrziZntQKTgpkGLjwmSdXrwiHOQix81hNvCQHxZcBr7WNaUNk4TFtiLCXF2Ffe3qEiS0_gYjA2kIqIEs5nsdp1lhxiXzb0j_sDigPkXopgvyWZ2yNpBHIXPo7LPcY3cDEDlHsEGXhCB8OfMDeb0RWiFGXa-sBTRfpFoNrQu0-1Ha5E77foBzWVFcoHFu5AzRkWPdm4mobpmCadh3Qymzx7ySSeo2rRMeue6qPBOG5EddJcJ7hiNlpOMFiSS0D0wG4JVeY",
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuoteHistoryScreen())),
                          ),
                          const SizedBox(height: 12),
                          _buildServiceCard(
                            step: "Paso 3",
                            title: "Pre-Liquidación de\nImpuestos SENAE",
                            subtitle: "Calcula tributos aduaneros estimados",
                            icon: Icons.account_balance_outlined,
                            stepColor: Colors.red,
                            isIconBackground: true,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CostSimulatorScreen())),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // AI Assistant
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: const [
                          Icon(Icons.smart_toy, color: AppColors.neonGreen),
                          SizedBox(width: 8),
                          Text("Asistente Inteligente", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                       padding: const EdgeInsets.symmetric(horizontal: 16),
                       child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF111C2E),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.neonGreen.withOpacity(0.3)),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF111C2E),
                              const Color(0xFF111C2E),
                            ],
                            // Custom implementation closer to border gradient needed? 
                            // HTML uses 'ai-gradient-border' class. Simpler to just use border.
                          ),
                          boxShadow: [
                             BoxShadow(
                               color: AppColors.neonGreen.withOpacity(0.05),
                               blurRadius: 10,
                               spreadRadius: 1
                             )
                          ]
                        ),
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Row(
                               children: [
                                 Container(
                                   padding: const EdgeInsets.all(8),
                                   decoration: BoxDecoration(color: AppColors.neonGreen.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                                   child: const Icon(Icons.psychology, color: AppColors.neonGreen),
                                 ),
                                 const SizedBox(width: 12),
                                 Expanded(
                                   child: Column(
                                     crossAxisAlignment: CrossAxisAlignment.start,
                                     children: const [
                                       Text("AduanaExpertoIA", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                                       Text("Chat inteligente aduanero + simulador de costos import", style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14)),
                                     ],
                                   ),
                                 )
                               ],
                             ),
                             const SizedBox(height: 16),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF050A14).withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                                ),
                                child: const Text("\"¿Cuál es el arancel para importar laptops desde China?\"", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic, fontSize: 14)),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen())),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.neonGreen,
                                    foregroundColor: AppColors.darkBlueBackground,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("Iniciar Consulta", style: TextStyle(fontWeight: FontWeight.bold)),
                                      SizedBox(width: 8),
                                      Icon(Icons.arrow_forward, size: 20),
                                    ],
                                  ),
                                ),
                              )
                           ],
                         ),
                       ),
                    ),

                    const SizedBox(height: 24),

                    // Tracking
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: const Text("Seguimiento", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF111C2E), // bg-surface-dark
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF1C2A3E)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.map, color: AppColors.neonGreen, size: 28),
                                SizedBox(width: 12),
                                Text("Cargo Tracking", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Rastrea tus embarques con timeline animado de 14 hitos desde origen hasta destino.",
                              style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                            ),
                            const SizedBox(height: 16),
                            InkWell(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TrackingScreen())),
                              child: Row(
                                children: [
                                  const Text("Ver Mis Embarques", style: TextStyle(color: AppColors.neonGreen, fontWeight: FontWeight.bold, fontSize: 14)),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.arrow_forward, color: AppColors.neonGreen, size: 16),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Help Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: const Text("¿Necesitas ayuda?", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                           color: const Color(0xFF111C2E), // bg-surface-dark
                           borderRadius: BorderRadius.circular(16),
                           border: Border.all(color: const Color(0xFF1C2A3E)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             const Text("Nuestro equipo esta disponible 24/7 para asistirte", style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
                             const SizedBox(height: 12),
                             _buildContactButton(icon: Icons.chat, text: "WhatsApp: +593 999 999 999", color: const Color(0xFF25D366)),
                             const SizedBox(height: 8),
                             _buildContactButton(icon: Icons.mail, text: "soporte@importaya.ia", color: Colors.white, isOutline: true),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Promo Section (Teal)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF0F766E), Color(0xFF115E59)], // teal-600 to teal-800
                          ),
                          borderRadius: BorderRadius.circular(16),
                           boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
                        ),
                        child: Column(
                          children: [
                            const Text("¿Primera vez importando?", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            const Text("No te preocupes, te guiamos paso a paso con nuestra plataforma inteligente.", textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFCCFBF1), fontSize: 14)), // teal-100
                            const SizedBox(height: 20),
                             SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () => Navigator.pushNamed(context, '/quote_form'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.neonGreen,
                                    foregroundColor: AppColors.darkBlueBackground,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("Comenzar Ahora", style: TextStyle(fontWeight: FontWeight.bold)),
                                      SizedBox(width: 8),
                                      Icon(Icons.arrow_forward, size: 20),
                                    ],
                                  ),
                                ),
                              )
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 100), // Spacing for bottom nav
                  ]),
                ),
              ],
            ),
          ),
          
          // Bottom Navigation (Custom)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: const Color(0xFF050A14).withOpacity(0.95), // bg-[#050A14]/95
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom, top: 12), // pb-safe + custom
              child: Container(
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Color(0xFF111C2E))),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    items: [
                      _buildNavItem(Icons.home, "Dashboard", isActive: true),
                      _buildNavItem(Icons.request_quote, "Cotizaciones", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuoteHistoryScreen()))),
                      // FAB placeholder
                      const SizedBox(width: 56), 
                      _buildNavItem(Icons.local_shipping, "Envíos", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TrackingScreen()))),
                      _buildNavItem(Icons.person, "Perfil", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()))),
                    ],
                  ),
                ),
              ),
            ),
          ),
           // Floating Action Button Center
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 20,
            left: MediaQuery.of(context).size.width / 2 - 28,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.neonGreen,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neonGreen.withOpacity(0.4),
                    blurRadius: 15,
                    spreadRadius: 2,
                  )
                ]
              ),
              child: IconButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen())),
                icon: const Icon(Icons.smart_toy, color: AppColors.darkBlueBackground, size: 28),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildServiceCard({
    required String step, 
    required String title, 
    required String subtitle, 
    required IconData icon, 
    required Color stepColor, 
    String? imageUrl,
    bool isIconBackground = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
       borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF111C2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.transparent),
          // hover:border-primary/30 logic not easily doable in static build, but implies active state
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                       Container(
                         padding: const EdgeInsets.all(6),
                         decoration: BoxDecoration(
                           color: stepColor.withOpacity(0.2),
                           borderRadius: BorderRadius.circular(8),
                         ),
                         child: Icon(icon, color: stepColor, size: 20),
                       ),
                       const SizedBox(width: 8),
                       Container(
                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                         decoration: BoxDecoration(
                           color: stepColor.withOpacity(0.1),
                           borderRadius: BorderRadius.circular(50),
                         ),
                         child: Text(step, style: TextStyle(color: stepColor, fontSize: 10, fontWeight: FontWeight.bold)),
                       )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, height: 1.1)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
                ],
              ),
            ),
             if (imageUrl != null)
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover, opacity: 0.8),
                ),
              )
            else if (isIconBackground)
               Icon(icon, size: 64, color: const Color(0xFF1C2A3E).withOpacity(0.5)) // Faded background icon fallback
          ],
        ),
      ),
    );
  }

  Widget _buildContactButton({required IconData icon, required String text, required Color color, bool isOutline = false}) {
    final bgColor = isOutline ? const Color(0xFF1C2A3E) : color.withOpacity(0.1); // surface-light or color div 10
    final textColor = isOutline ? const Color(0xFF9CA3AF) : color;
    final borderColor = isOutline ? Colors.white.withOpacity(0.05) : color.withOpacity(0.2);

    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Abriendo ${text.split(':')[0]}...")));
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Icon(icon, color: isOutline ? Colors.grey : textColor, size: 20),
            const SizedBox(width: 12),
            Text(text, style: TextStyle(color: isOutline ? textColor : textColor, fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, {bool isActive = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? AppColors.neonGreen : const Color(0xFF9CA3AF), size: 26),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: isActive ? AppColors.neonGreen : const Color(0xFF9CA3AF), fontSize: 10, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}