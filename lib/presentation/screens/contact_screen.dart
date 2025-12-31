import 'package:flutter/material.dart';
import '../../config/theme.dart';
import 'package:animate_do/animate_do.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFA2F40B);
    const bgDark = Color(0xFF050A14);
    const surfaceDark = Color(0xFF111826);
    const textNeutral400 = Color(0xFF9CA3AF);
    
    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCircleBtn(Icons.arrow_back_ios_new, () => Navigator.pop(context)),
                  const Text("CONTACTO", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                  const SizedBox(width: 40) // Balance title
                ],
              ),
            ),
            
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero Section
                    const SizedBox(height: 8),
                    RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(text: "Hablemos de ", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                          TextSpan(text: "Logística", style: TextStyle(color: primaryColor, fontSize: 28, fontWeight: FontWeight.bold)),
                        ]
                      )
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Nuestro equipo de IA y expertos humanos están listos para optimizar tus importaciones.",
                      style: TextStyle(color: Colors.grey[400], fontSize: 14, height: 1.5),
                    ),
                    const SizedBox(height: 24),
                    
                    // Contact Cards Grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.8,
                      children: [
                        _buildContactCard(Icons.mail, "Correo", "contacto@", primaryColor, surfaceDark),
                        _buildContactCard(Icons.call, "WhatsApp", "+52 55...", primaryColor, surfaceDark),
                        _buildContactCard(Icons.location_on, "Oficina", "CDMX", primaryColor, surfaceDark),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Map Preview
                    Container(
                      height: 128,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: const DecorationImage(
                          image: NetworkImage("https://lh3.googleusercontent.com/aida-public/AB6AXuAoV0-jafdGU07sgCbwEjlywEYhvwamOAIdvj9652gjD2HraIpFZHKTBykDy1HUfg4q8OJhdVk_qRjdcp41qTjsED34pvYQv1cB_q7wH5xgj7F3f-GPuxyZnV6OrEtNVTTZWpj0AujFTvXycu3nH8vNzN4UTnfeaXe0K1CXVBnRwLWsLGYuDaeocbwgttUjyOG011EQf3vXM5yANiKVVmErR2G08C7Z5QA5uKmN8Fs3NPbwXkxA-ww9JoVd1__gxB-5_AuDwDslCFw"),
                          fit: BoxFit.cover,
                          opacity: 0.6
                        )
                      ),
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: const LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Color(0xCC050A14), Colors.transparent])
                            )
                          ),
                          Positioned(
                            bottom: 12, left: 16,
                            child: Row(
                              children: [
                                Pulse(infinite: true, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: primaryColor, shape: BoxShape.circle))),
                                const SizedBox(width: 8),
                                const Text("SEDE CENTRAL", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Contact Form
                    Row(
                      children: [
                        Icon(Icons.edit_note, color: primaryColor),
                        const SizedBox(width: 8),
                        const Text("Envíanos un mensaje", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInputLabel("Nombre completo"),
                    _buildTextField(Icons.person, "Ej. Juan Pérez", surfaceDark, primaryColor),
                    const SizedBox(height: 16),
                    _buildInputLabel("Correo electrónico"),
                    _buildTextField(Icons.alternate_email, "ejemplo@correo.com", surfaceDark, primaryColor),
                    const SizedBox(height: 16),
                    _buildInputLabel("Tu mensaje"),
                    _buildTextField(null, "Describe tu consulta...", surfaceDark, primaryColor, maxLines: 4),
                    const SizedBox(height: 24),
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (){}, 
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0
                        ),
                        child: const Text("ENVIAR MENSAJE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.0)),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Social Footer
                    const Divider(color: Colors.white10),
                    const SizedBox(height: 16),
                    Center(child: Text("Síguenos en nuestras redes", style: TextStyle(color: Colors.grey[600], fontSize: 12))),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSocialBtn(Icons.work, surfaceDark, primaryColor), // LinkedIn replacement
                        const SizedBox(width: 16),
                        _buildSocialBtn(Icons.camera_alt, surfaceDark, primaryColor), // Instagram replacement
                        const SizedBox(width: 16),
                        _buildSocialBtn(Icons.public, surfaceDark, primaryColor), // Web replacement
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCircleBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.05)),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildContactCard(IconData icon, String title, String subtitle, Color primary, Color bg) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg, 
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10)
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: primary.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: primary, size: 20),
          ),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(color: Colors.grey[400], fontSize: 11, fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 12, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildTextField(IconData? icon, String hint, Color bg, Color primary, {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10)
      ),
      child: TextField(
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
          prefixIcon: icon != null ? Icon(icon, color: Colors.grey[600], size: 20) : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16)
        ),
      ),
    );
  }

  Widget _buildSocialBtn(IconData icon, Color bg, Color primary) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white10)
      ),
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }
}