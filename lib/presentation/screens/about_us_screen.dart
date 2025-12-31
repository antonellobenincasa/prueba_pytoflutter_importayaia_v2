import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import '../../config/theme.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFA2F40B);
    const bgDark = Color(0xFF050A14);
    const surfaceDark = Color(0xFF0B1221);
    const textSecondary = Color(0xFF94A3B8);

    return Scaffold(
      backgroundColor: bgDark,
      body: CustomScrollView(
        slivers: [
          // Sticky App Bar
          SliverAppBar(
            pinned: true,
            backgroundColor: bgDark.withOpacity(0.8),
            elevation: 0,
            leading: IconButton(
               icon: Container(
                 padding: const EdgeInsets.all(8),
                 decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.05)),
                 child: const Icon(Icons.arrow_back, size: 20),
               ),
               onPressed: () => Navigator.pop(context),
            ),
            title: const Text("Nosotros", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            centerTitle: true,
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Section
                  Hero(
                    tag: 'about_hero',
                    child: Container(
                      height: 320,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: const DecorationImage(
                          image: NetworkImage("https://lh3.googleusercontent.com/aida-public/AB6AXuD4oPmUcNSM54Li4z43FnTbNO2j-NwhBPsgEtcmvLz2b0fg7WU0AxVF2w_F0Qi5vTaGJkKGoEhj2zi14EN3MoJG-HbWI6ajNoZSMemMH80uiunhE--i4sjke-tLCFhj2DIDDf92QBVQlRR-bRLM2eHPbVkw0tVO65kgXlpGAxKD7y--zI5yIirPtJgMVsk3VAb4dq1cfDxMJGULVEZmz8aFcvkzfKyrhu5aSwm98SeNNsR6l8SZWGjFbUu7nYxN5P8IPYCkF6qNO9E"),
                          fit: BoxFit.cover,
                        ),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                           borderRadius: BorderRadius.circular(20),
                           gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Color(0xFF050A14)])
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.2), 
                                borderRadius: BorderRadius.circular(20), 
                                border: Border.all(color: primaryColor.withOpacity(0.3))
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: primaryColor, shape: BoxShape.circle)),
                                  const SizedBox(width: 8),
                                  const Text("LOGÍSTICA INTELIGENTE", style: TextStyle(color: primaryColor, fontSize: 10, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            RichText(
                              text: const TextSpan(
                                children: [
                                  TextSpan(text: "El futuro de la importación es ", style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, height: 1.1)),
                                  TextSpan(text: "ahora", style: TextStyle(color: primaryColor, fontSize: 26, fontWeight: FontWeight.bold, height: 1.1)),
                                  TextSpan(text: ".", style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, height: 1.1)),
                                ]
                              )
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "ImportaYA.ia combina inteligencia artificial con logística global para simplificar tus operaciones.",
                              style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Stats Row
                  Row(
                     children: [
                       _buildStatCard("24/7", "Soporte AI", surfaceDark, primaryColor, textSecondary),
                       const SizedBox(width: 12),
                       _buildStatCard("+50", "Países", surfaceDark, primaryColor, textSecondary),
                       const SizedBox(width: 12),
                       _buildStatCard("100%", "Digital", surfaceDark, primaryColor, textSecondary),
                     ],
                  ),
                  const SizedBox(height: 32),

                  // Mission
                  FadeInUp(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         _buildSectionTitle(Icons.rocket_launch, "Nuestra Misión", primaryColor),
                         const SizedBox(height: 16),
                         Container(
                           padding: const EdgeInsets.all(20),
                           decoration: BoxDecoration(color: surfaceDark, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
                           child: const Text(
                             "Democratizar el comercio internacional mediante tecnología predictiva, permitiendo que cualquier empresa, sin importar su tamaño, pueda importar con la eficiencia de una multinacional.",
                             style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.6),
                           ),
                         )
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Values
                  _buildSectionTitle(Icons.diamond, "Nuestros Valores", primaryColor),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: [
                      _buildValueCard(Icons.psychology, "Innovación", "Algoritmos que aprenden y mejoran tus rutas.", surfaceDark, primaryColor, textSecondary),
                      _buildValueCard(Icons.verified_user, "Transparencia", "Rastreo en tiempo real sin letras pequeñas.", surfaceDark, primaryColor, textSecondary),
                      _buildValueCard(Icons.bolt, "Velocidad", "Procesamiento automatizado de aduanas.", surfaceDark, primaryColor, textSecondary),
                      _buildValueCard(Icons.eco, "Sostenible", "Optimización de carga para reducir huella.", surfaceDark, primaryColor, textSecondary),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Technology
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [surfaceDark, Colors.black]),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white10),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                         Expanded(
                           flex: 3,
                           child: Padding(
                             padding: const EdgeInsets.all(16),
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 Row(children: [Icon(Icons.auto_awesome, color: primaryColor, size: 14), const SizedBox(width: 6), const Text("IA CORE v2.0", style: TextStyle(color: primaryColor, fontSize: 10, fontWeight: FontWeight.bold))]),
                                 const SizedBox(height: 8),
                                 const Text("Motor Predictivo", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                 const SizedBox(height: 8),
                                 const Text("Nuestro sistema analiza millones de puntos de datos para predecir retrasos.", style: TextStyle(color: textSecondary, fontSize: 12, height: 1.4)),
                               ],
                             ),
                           ),
                         ),
                         Expanded(
                           flex: 2,
                           child: Container(
                             height: 140,
                             decoration: BoxDecoration(
                               borderRadius: BorderRadius.circular(16),
                               image: const DecorationImage(
                                 image: NetworkImage("https://lh3.googleusercontent.com/aida-public/AB6AXuBqhIa5X10W0zI6-Cx5u2092N7h3myHF_6SNwDwMDy45pPcDvUu2JW2Be-yjbajnaw9K4OMxvlVMvfL5QdCYpwDaknO-avb_2LsmVZfYL1s14DULASTLK2GRnjBd7jtM-ixBoXV2Re81ITBH4BwUPxnhSHzAp_5joqqGGGETcXeScDdFKOOc9DV0plORFqjD2AUTG_Fqp6Vc6cvtKcVoVBzGbj5lTZmfagoap-GyVtn2pzn3Ke-EsKGFWFzCmx2-OhTxgOKZboExO0"),
                                 fit: BoxFit.cover
                               )
                             ),
                           ),
                         )
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                  
                  // Timeline
                   _buildSectionTitle(Icons.history, "Nuestra Trayectoria", Colors.white),
                   const SizedBox(height: 16),
                   Stack(
                     children: [
                       Positioned(left: 7, top: 0, bottom: 0, child: Container(width: 1, color: Colors.white10)),
                       Column(
                         children: [
                           _buildTimelineItem("2024", "Expansión Global", "Apertura en Asia y Europa.", primaryColor, true),
                           _buildTimelineItem("2023", "Lanzamiento IA", "Integración de motor AI.", Colors.white24, false),
                           _buildTimelineItem("2021", "Fundación", "Digitalización logística.", Colors.white24, false),
                         ],
                       )
                     ],
                   ),

                   const SizedBox(height: 32),

                   // Team
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     crossAxisAlignment: CrossAxisAlignment.end,
                     children: [
                       Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                            const Text("Equipo Líder", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text("Mentes detrás del algoritmo", style: TextStyle(color: textSecondary.withOpacity(0.8), fontSize: 12)),
                         ],
                       ),
                       TextButton.icon(
                         onPressed: (){}, 
                         icon: const Icon(Icons.arrow_forward, size: 16, color: primaryColor),
                         label: const Text("Ver todos", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                         style: TextButton.styleFrom(padding: EdgeInsets.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                       )
                     ],
                   ),
                   const SizedBox(height: 16),
                   SizedBox(
                     height: 160,
                     child: ListView(
                       scrollDirection: Axis.horizontal,
                       children: [
                         _buildTeamMember("Elena Rodríguez", "CEO & Fundadora", "https://lh3.googleusercontent.com/aida-public/AB6AXuAUvS6bkBx5w2HFtaRU5O69fESgaMEzY6wspkHN6e0o4Yk0QL1-hr_z9hwegS91qEIDQQvoYP8yscwrGLjN7FOHGFwqoJumnkiiRXx286esMsgNZpBK3MlH44-VWDq0qUu1xQU6p1Xngil4GdqvJGy7nOzZBGUsmjzKIHZhviWjCF0A9IeYFaR90huuoqI1rtrJvrZz_4TgQdmNepnMREzOisl-0LedB1_0BX6416jGPdN_asz5X609l0oYtye9Bz_HzfCsaP0h9I0", primaryColor),
                         _buildTeamMember("David Chen", "CTO", "https://lh3.googleusercontent.com/aida-public/AB6AXuDfONO7Z4mExwtaJlLM-HlvPdVlpcdH7upn8wK-ceq8xjhRKQYXW3jTTqdHf3Iy0dRmGshoQm1pWBKz4z-44XTEKfJt5Q_4B0ylIeaRPrMwzL_yDExIVvQCMyv9MXG-ProByT90IpCIJ5BeGFDRITVGWZkD_L5iCyHr07KNFERbj7zzjAtIQRc3jZvvkpM2vawzdk5NNQZK7ekORCi8j8F3Pu0DK_9ihbVV7OiWZhbIG6I_QgKPQ0P0YDgXBmMX9V_Tj-8xbkRcxQQ", primaryColor),
                         _buildTeamMember("Sofía Martínez", "COO", "https://lh3.googleusercontent.com/aida-public/AB6AXuCEnxm1heTGMZJD7F3zC9slKLrBBKkYCqMBTZFR3BKqwa2V10bGBuTthCDXMJZCcaTgmkH2XZ1UGLtFMRTwRukqT2oKub_BHRjdyQ360zNKoyU8mb59CNRqTfTyF2zYLzs3-4lUuofd34Y0xPKkG4CnRkUcXBOjrFgP2H7R7cHaIOS-KDVrgWm0hHWU8RxJ1Qg6yQCGfa0QcpaxDP8j934yU2Tb7h5TKli5EM5FYkvSAmJOJAl7zBUTyVWKlSO_5MMH9dALarKpuM8", primaryColor),
                       ],
                     ),
                   ),

                   const SizedBox(height: 48),

                   // CTA
                   Container(
                     padding: const EdgeInsets.all(24),
                     decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(20)),
                     child: Column(
                       children: [
                         const Text("¿Listo para importar?", style: TextStyle(color: Color(0xFF050A14), fontSize: 22, fontWeight: FontWeight.bold)),
                         const SizedBox(height: 8),
                         const Text("Únete a la revolución logística hoy mismo.", style: TextStyle(color: Color(0xCC050A14), fontSize: 13, fontWeight: FontWeight.w500)),
                         const SizedBox(height: 24),
                         SizedBox(
                           width: double.infinity,
                           child: ElevatedButton.icon(
                             onPressed: (){},
                             style: ElevatedButton.styleFrom(
                               backgroundColor: bgDark,
                               foregroundColor: Colors.white,
                               padding: const EdgeInsets.symmetric(vertical: 16),
                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                             ),
                             icon: const Icon(Icons.mail),
                             label: const Text("Contáctanos", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                           ),
                         )
                       ],
                     ),
                   ),

                   const SizedBox(height: 32),
                   
                   // Footer Info
                   const Center(child: Text("ImportaYA.ia v2.4.0", style: TextStyle(color: Colors.white24, fontSize: 10))),
                   const SizedBox(height: 16),
                   Row(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       IconButton(icon: const Icon(Icons.share, size: 18, color: Colors.white38), onPressed: (){}),
                       IconButton(icon: const Icon(Icons.policy, size: 18, color: Colors.white38), onPressed: (){}),
                       IconButton(icon: const Icon(Icons.help, size: 18, color: Colors.white38), onPressed: (){}),
                     ],
                   ),
                   const SizedBox(height: 32),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatCard(String val, String label, Color bg, Color primary, Color secondary) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
        child: Column(
          children: [
            Text(val, style: TextStyle(color: primary, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: secondary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildValueCard(IconData icon, String title, String desc, Color bg, Color primary, Color secondary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: primary, size: 20),
          ),
          const Spacer(),
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Text(desc, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: secondary, fontSize: 10, height: 1.4)),
        ],
      ),
    );
  }
  
  Widget _buildTimelineItem(String year, String title, String desc, Color dotColor, bool isPrimary) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
             left: -22, top: 5, 
             child: Container(
               width: 10, height: 10, 
               decoration: BoxDecoration(
                 color: dotColor, 
                 shape: BoxShape.circle,
                 boxShadow: isPrimary ? [BoxShadow(color: dotColor.withOpacity(0.6), blurRadius: 8)] : null
               )
             )
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(year, style: TextStyle(color: isPrimary ? dotColor : Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(title, style: TextStyle(color: isPrimary ? Colors.white : Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(desc, style: const TextStyle(color: Colors.white38, fontSize: 13)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTeamMember(String name, String role, String imgUrl, Color primary) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 110,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(image: NetworkImage(imgUrl), fit: BoxFit.cover),
              border: Border.all(color: Colors.white10)
            ),
          ),
          const SizedBox(height: 8),
          Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          Text(role, style: TextStyle(color: primary, fontSize: 10)),
        ],
      ),
    );
  }
}
