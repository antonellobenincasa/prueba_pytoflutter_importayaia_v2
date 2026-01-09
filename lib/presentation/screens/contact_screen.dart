import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../widgets/main_drawer.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const primaryColor = AppColors.neonGreen;
    final bgBackgroundColor = theme.scaffoldBackgroundColor;
    final surfaceColor = theme.cardColor;
    final titleColor = isDark ? Colors.white : Colors.black87;
    final bodyColor = isDark ? Colors.grey[400] : Colors.grey[600];

    return Scaffold(
      backgroundColor: bgBackgroundColor,
      drawer: const MainDrawer(),
      appBar: AppBar(
        title: const Text(""),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: titleColor),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Center(
              child: Column(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.cyan.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.mail, size: 16, color: Colors.cyan),
                        SizedBox(width: 8),
                        Text("Contacto",
                            style: TextStyle(
                                color: Colors.cyan,
                                fontWeight: FontWeight.bold,
                                fontSize: 12))
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Contáctanos",
                    style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: titleColor,
                        fontFamily: 'Inter'),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      "Estamos listos para ayudarte con tu próxima importación. Nuestro equipo de\nexpertos te atenderá de manera personalizada.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: bodyColor,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 5))
                  ],
                  border: Border.all(
                      color: isDark ? Colors.white10 : Colors.black12),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    // Layout builder to switch to row on large screens if desired, but default column for mobile
                    // Assuming mobile first based on screenshots implies mobile app, but design looks like web.
                    // We'll stick to Column for mobile responsiveness, or a responsive row if wide.
                    LayoutBuilder(builder: (context, constraints) {
                      bool isWide = constraints.maxWidth >
                          800; // Tablet/Desktop breakpoint
                      return isWide
                          ? IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(child: _buildInfoSide(context)),
                                  Expanded(child: _buildDarkSide(context)),
                                ],
                              ),
                            )
                          : Column(
                              children: [
                                _buildInfoSide(context),
                                _buildDarkSide(context),
                              ],
                            );
                    }),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Footer text
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(4)),
                    child: const Icon(Icons.api, size: 14, color: Colors.black),
                  ),
                  const SizedBox(width: 8),
                  Text("ImportaYa.ia",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: titleColor)),
                  const SizedBox(width: 8),
                  Text(
                      "© 2024 ImportaYa.ia - La logística de carga integral, ahora es Inteligente!",
                      style: TextStyle(fontSize: 10, color: bodyColor))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSide(BuildContext context) {
    final theme = Theme.of(context);
    final titleColor =
        theme.brightness == Brightness.dark ? Colors.white : Colors.black87;

    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Información de Contacto",
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: titleColor),
          ),
          const SizedBox(height: 32),
          _buildContactRow(context, Icons.phone_in_talk, "Teléfono / WhatsApp",
              "+593 99 123 4567", "Lunes a Viernes: 8:00 - 18:00"),
          const SizedBox(height: 24),
          _buildContactRow(context, Icons.email_outlined, "Correo Electrónico",
              "info@importaya.ia", "Respondemos en menos de 24 horas"),
          const SizedBox(height: 24),
          _buildContactRow(context, Icons.location_on_outlined,
              "Oficina Principal", "Guayaquil, Ecuador", "Zona Portuaria"),
          const SizedBox(height: 24),
          _buildContactRow(
              context,
              Icons.access_time,
              "Horario de Atención",
              "Lunes a Viernes: 8:00 AM - 6:00 PM",
              "Sábados: 9:00 AM - 1:00 PM"),
          const SizedBox(height: 48),
          const Divider(),
          const SizedBox(height: 24),
          Text("Síguenos en Redes Sociales",
              style: TextStyle(fontWeight: FontWeight.bold, color: titleColor)),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildSocialIcon(Icons.facebook),
              const SizedBox(width: 12),
              _buildSocialIcon(Icons.camera_alt), // Instagram
              const SizedBox(width: 12),
              _buildSocialIcon(Icons.music_note), // TikTok
              const SizedBox(width: 12),
              _buildSocialIcon(Icons.work), // LinkedIn
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDarkSide(BuildContext context) {
    return Container(
      color: const Color(0xFF0F1E35), // Dark Blue
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.neonGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              "IA",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Colors.black),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Logística Inteligente",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Gestiona tus importaciones desde cualquier lugar. Cotiza, rastrea y comunícate con nosotros directamente desde tu dispositivo.",
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),
          const SizedBox(height: 32),
          _buildDarkCheck("Cotizaciones inteligentes en tiempo real"),
          _buildDarkCheck("Tracking de tus envíos"),
          _buildDarkCheck("Notificaciones Instantáneas"),
          _buildDarkCheck("Soporte directo por chat"),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.bolt),
              label: const Text("Cotiza Ahora - Es Gratis"),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonGreen,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              "La logística de carga integral, ahora es Inteligente!",
              style: TextStyle(color: Colors.white30, fontSize: 10),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildContactRow(BuildContext context, IconData icon, String title,
      String val1, String val2) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color:
                  isDark ? Colors.cyan.withValues(alpha: 0.1) : Colors.cyan[50],
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: Colors.cyan, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(height: 4),
              Text(val1,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, color: Colors.cyan)),
              Text(val2,
                  style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600])),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1E35),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }

  Widget _buildDarkCheck(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(Icons.check, color: AppColors.neonGreen, size: 16),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(color: Colors.white))
        ],
      ),
    );
  }
}
