import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../config/theme.dart';
import '../widgets/main_drawer.dart';

/// Contact Screen - Full implementation matching Python design
class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const bgDark = Color(0xFF050A14);
    const surfaceDark = Color(0xFF0A101D);
    const primaryColor = AppColors.neonGreen;

    return Scaffold(
      backgroundColor: bgDark,
      drawer: const MainDrawer(),
      appBar: AppBar(
        backgroundColor: bgDark,
        elevation: 0,
        title: GestureDetector(
          onTap: () =>
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('IA',
                    style: TextStyle(
                        color: AppColors.neonGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
              ),
              const SizedBox(width: 8),
              const Text('ImportaYAia',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              Text('.com',
                  style: TextStyle(
                      color: primaryColor, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            FadeInDown(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: primaryColor.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.email, color: primaryColor, size: 16),
                          const SizedBox(width: 8),
                          const Text('Contacto',
                              style: TextStyle(color: AppColors.neonGreen)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Contáctanos',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Estamos listos para ayudarte con tu próxima importación.\nNuestro equipo de expertos te atenderá de manera personalizada.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[400], fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

            // Contact Cards Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 700;
                  return isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                child: _buildContactInfoCard(
                                    surfaceDark, primaryColor)),
                            const SizedBox(width: 24),
                            Expanded(
                                child: _buildAppPromoCard(
                                    surfaceDark, primaryColor)),
                          ],
                        )
                      : Column(
                          children: [
                            _buildContactInfoCard(surfaceDark, primaryColor),
                            const SizedBox(height: 24),
                            _buildAppPromoCard(surfaceDark, primaryColor),
                          ],
                        );
                },
              ),
            ),

            const SizedBox(height: 48),

            // Footer
            Container(
              padding: const EdgeInsets.all(24),
              color: surfaceDark,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('IA',
                            style: TextStyle(
                                color: AppColors.neonGreen,
                                fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 8),
                      const Text('ImportaYAia',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      Text('.com', style: TextStyle(color: primaryColor)),
                    ],
                  ),
                  Text(
                    '© 2024 ImportaYAia.com - La logística de carga integral, ahora es Inteligente!',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfoCard(Color surfaceDark, Color primaryColor) {
    return FadeInLeft(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: surfaceDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información de Contacto',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            _buildContactItem(
              Icons.phone,
              'Teléfono / WhatsApp',
              '+593 99 123 4567',
              'Lunes a Viernes: 8:00 - 18:00',
              primaryColor,
            ),
            const SizedBox(height: 24),
            _buildContactItem(
              Icons.email,
              'Correo Electrónico',
              'info@importayaia.com',
              'Respondemos en menos de 24 horas',
              primaryColor,
            ),
            const SizedBox(height: 24),
            _buildContactItem(
              Icons.location_on,
              'Oficina Principal',
              'Guayaquil, Ecuador',
              'Zona Portuaria',
              primaryColor,
            ),
            const SizedBox(height: 24),
            _buildContactItem(
              Icons.access_time,
              'Horario de Atención',
              'Lunes a Viernes: 8:00 AM - 6:00 PM',
              'Sábados: 9:00 AM - 1:00 PM',
              primaryColor,
            ),
            const SizedBox(height: 32),
            const Text(
              'Síguenos en Redes Sociales',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildSocialButton(Icons.facebook, primaryColor),
                const SizedBox(width: 12),
                _buildSocialButton(Icons.camera_alt, primaryColor),
                const SizedBox(width: 12),
                _buildSocialButton(Icons.music_note, primaryColor),
                const SizedBox(width: 12),
                _buildSocialButton(Icons.work, primaryColor),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String title, String value,
      String subtitle, Color primaryColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: primaryColor, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(value, style: TextStyle(color: Colors.grey[400])),
              Text(subtitle,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton(IconData icon, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  Widget _buildAppPromoCard(Color surfaceDark, Color primaryColor) {
    return FadeInRight(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: surfaceDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('IA',
                  style: TextStyle(
                      color: AppColors.neonGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 20)),
            ),
            const SizedBox(height: 24),
            const Text(
              'Logística Inteligente',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Gestiona tus importaciones desde cualquier lugar. Cotiza, rastrea y comunícate con nosotros directamente desde tu dispositivo.',
              style: TextStyle(color: Colors.grey[400]),
            ),
            const SizedBox(height: 24),
            _buildFeatureCheck(
                'Cotizaciones inteligentes en tiempo real', primaryColor),
            const SizedBox(height: 12),
            _buildFeatureCheck('Tracking de tus envíos', primaryColor),
            const SizedBox(height: 12),
            _buildFeatureCheck('Notificaciones instantáneas', primaryColor),
            const SizedBox(height: 12),
            _buildFeatureCheck('Soporte directo por chat', primaryColor),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.bolt, color: Colors.black),
                label: const Text('Cotiza Ahora - Es Gratis',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'La logística de carga integral, ahora es Inteligente!',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCheck(String text, Color primaryColor) {
    return Row(
      children: [
        Icon(Icons.check, color: primaryColor, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: TextStyle(color: Colors.grey[300]))),
      ],
    );
  }
}
