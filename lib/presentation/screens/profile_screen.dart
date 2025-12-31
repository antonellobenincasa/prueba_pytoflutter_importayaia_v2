import 'package:flutter/material.dart';
import '../../config/theme.dart';
import 'package:animate_do/animate_do.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Personal Info
  final TextEditingController _nameController = TextEditingController(text: "Juan Pérez");
  final TextEditingController _emailController = TextEditingController(text: "juan.perez@importaya.com");
  final TextEditingController _phoneController = TextEditingController(text: "+51 987 654 321");
  
  // Company Info
  final TextEditingController _companyController = TextEditingController(text: "Importaciones Globales SAC");
  final TextEditingController _rucController = TextEditingController(text: "20123456789");

  bool _pushEnabled = true;

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFA2F40B);
    const bgDark = Color(0xFF1C2210);
    const surfaceDark = Color(0xFF262E16); // Slightly lighter
    const textGrey = Color(0xFF9CA3AF);

    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCircleBtn(Icons.arrow_back, () => Navigator.pop(context)),
                  const Text("Mi Perfil", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Avatar Section
                    FadeInDown(
                      duration: const Duration(milliseconds: 600),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: 112, height: 112,
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: primaryColor.withOpacity(0.5), width: 2),
                                  boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 15)]
                                ),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      image: NetworkImage("https://lh3.googleusercontent.com/aida-public/AB6AXuB-FVKIbdN8G5nhSl5ixBpRN7XFe6J1O20-tZ3qO6nIk9tqhuTO5JrLDigb0nyDqJJtfZ1Rnq3lUgEG1FCBXxonsx3Q5mB_pgTcMrv6r1QJjMUWWY6PHk6UYeOjE-QpkVwn9swRBJVyUqvne5D91W1Ngj9YM9YYHoDjwbQKgq5hC6VUf5bpNxsuaSSCINq2vjOlYjLRUoOpPzjAHdz8K1HmbG0vBm1KquuuyC6DmaJAOrUDS_GcHCg9mYyN3W97WEtEgaubC7o2LlA"),
                                      fit: BoxFit.cover
                                    )
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0, right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle, border: Border.all(color: bgDark, width: 2)),
                                  child: const Icon(Icons.edit, size: 14, color: Colors.black),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text("Juan Pérez", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: primaryColor.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                                child: const Text("VERIFICADO", style: TextStyle(color: primaryColor, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 8),
                              const Text("Gerente de Logística", style: TextStyle(color: textGrey, fontSize: 14)),
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Personal Info
                    _buildSectionTitle("Información Personal", primaryColor),
                    const SizedBox(height: 16),
                    _buildTextField("Nombre Completo", Icons.person, _nameController, surfaceDark, primaryColor),
                    const SizedBox(height: 16),
                    _buildTextField("Correo Electrónico", Icons.verified, _emailController, surfaceDark, primaryColor, readOnly: true, iconColor: primaryColor),
                    Padding(padding: const EdgeInsets.only(left: 4, top: 4), child: Align(alignment: Alignment.centerLeft, child: Text("Contacte a soporte para cambiar su email.", style: TextStyle(color: textGrey, fontSize: 12)))),
                    const SizedBox(height: 16),
                    _buildTextField("Teléfono Móvil", Icons.smartphone, _phoneController, surfaceDark, primaryColor),
                    const SizedBox(height: 32),

                    // Company Info
                    _buildSectionTitle("Datos de la Empresa", primaryColor),
                    const SizedBox(height: 16),
                    _buildTextField("Razón Social", Icons.domain, _companyController, surfaceDark, primaryColor),
                    const SizedBox(height: 16),
                    _buildTextField("RUC", Icons.badge, _rucController, surfaceDark, primaryColor),
                    const SizedBox(height: 32),

                    // Settings
                    _buildSectionTitle("Seguridad y Alertas", primaryColor),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: surfaceDark, borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.notifications_active, color: primaryColor)),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text("Notificaciones Push", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                              Text("Alertas de estado de envíos", style: TextStyle(color: textGrey, fontSize: 12)),
                            ]),
                          ),
                          Switch(
                            value: _pushEnabled, 
                            onChanged: (val) => setState(() => _pushEnabled = val),
                            activeColor: primaryColor,
                            activeTrackColor: primaryColor.withOpacity(0.5),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: surfaceDark, borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.lock_reset, color: primaryColor)),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text("Cambiar Contraseña", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                              Text("Último cambio hace 3 meses", style: TextStyle(color: textGrey, fontSize: 12)),
                            ]),
                          ),
                          const Icon(Icons.chevron_right, color: textGrey)
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Logout
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.red.shade900.withOpacity(0.5)),
                          foregroundColor: Colors.red.shade400,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                        ),
                        child: const Text("Cerrar Sesión", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text("ImportaYA.ia v2.4.1", style: TextStyle(color: textGrey, fontSize: 12)),
                    const SizedBox(height: 100), // Space for Sticky Footer
                  ],
                ),
              ),
            )
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgDark.withOpacity(0.9),
          border: const Border(top: BorderSide(color: Colors.white10)),
        ),
        child: SizedBox(
           width: double.infinity,
           height: 56,
           child: ElevatedButton.icon(
             onPressed: (){},
             style: ElevatedButton.styleFrom(
               backgroundColor: primaryColor,
               foregroundColor: Colors.black,
               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
               elevation: 4
             ),
             icon: const Icon(Icons.save),
             label: const Text("Guardar Cambios", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
           ),
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
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.1)),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Row(
      children: [
        Container(width: 4, height: 24, color: color),
        const SizedBox(width: 12),
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController ctrl, Color bg, Color primary, {bool readOnly = false, Color? iconColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.only(left: 4, bottom: 6), child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500))),
        Stack(
          alignment: Alignment.centerRight,
          children: [
            TextField(
              controller: ctrl,
              readOnly: readOnly,
              style: TextStyle(color: readOnly ? Colors.grey : Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: bg,
                contentPadding: const EdgeInsets.only(left: 16, right: 48, top: 16, bottom: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.transparent)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white10)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primary)),
              ),
            ),
            Positioned(right: 16, child: Icon(icon, color: iconColor ?? Colors.grey[600]))
          ],
        )
      ],
    );
  }
}
