import 'package:flutter/material.dart';
import '../../config/theme.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const primaryColor = AppColors.neonGreen;
    final bgBackgroundColor = theme.scaffoldBackgroundColor;
    final surfaceColor = theme.cardColor;
    final titleColor = isDark ? Colors.white : Colors.black87;
    final bodyColor = isDark ? Colors.grey[400] : Colors.grey[700];

    return Scaffold(
      backgroundColor: bgBackgroundColor,
      appBar: AppBar(
        leading: BackButton(color: titleColor),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Header Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: titleColor,
                        height: 1.2,
                        fontFamily: 'Inter',
                      ),
                      children: const [
                        TextSpan(text: "Logística de Carga Integral, "),
                        TextSpan(
                          text: "ahora es\nInteligente!",
                          style: TextStyle(color: primaryColor),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "En ImportaYa.ia, transformamos la forma en que gestionas tu carga y\ntu negocio. Ofrecemos soluciones digitales potentes para\nimportadores.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: bodyColor,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 2. White/Surface Card Section (The main feature list)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                  border: Border.all(
                      color: isDark ? Colors.white10 : Colors.black12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "IA",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF050A14)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "Plataforma Inteligente para Importadores",
                          style: TextStyle(
                              color: primaryColor, fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Cotiza y Embarca en Segundos",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Para importadores nuevos o experimentados que buscan eficiencia, transparencia y las mejores tarifas.",
                      style: TextStyle(
                          color: bodyColor, fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Tu Importación, Automatizada. Cotiza, Reserva y Gestiona 24/7.",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Ya sea que estés dando tus primeros pasos en la importación o seas un experto en volumen, nuestra aplicación está diseñada para eliminar la fricción y la espera.",
                      style: TextStyle(color: bodyColor, height: 1.5),
                    ),
                    const SizedBox(height: 32),

                    // Check List
                    _buildCheckItem(context, "Registro Gratuito e Inmediato",
                        "Registrate y accede sin costo a nuestra plataforma inteligente."),
                    _buildCheckItem(context, "Cotizaciones Inteligentes 24/7",
                        "Olvídate de esperar horas. Solicita tu cotización en cualquier momento y recibe tarifas altamente competitivas generadas automáticamente.",
                        isDark: isDark),
                    _buildCheckItem(context, "Gestión con un Clic",
                        "Una vez que apruebes la tarifa, nuestra plataforma generará automáticamente un RO (Routing Order) único.",
                        isDark: isDark),
                    _buildCheckItem(context, "Tracking Inteligente",
                        "Sigue tu mercancía en tiempo real desde el origen hasta la entrega final en Ecuador.",
                        isDark: isDark),

                    const SizedBox(height: 32),

                    // Green Highlight Box
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: primaryColor.withValues(alpha: 0.3)),
                      ),
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(color: bodyColor, height: 1.5),
                          children: const [
                            TextSpan(
                              text: "El Valor Clave: ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                                text:
                                    "Ahorro de Tiempo y Dinero. Accede a las mejores tarifas del mercado y convierte las horas de espera en minutos de acción."),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigate to register or quote
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: const Color(0xFF050A14),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Comienza a Importar con ImportaYa.ia",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 48),

            // 3. Dark Services Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              decoration: const BoxDecoration(
                color: Color(0xFF071324), // Dark blue like in the screenshot
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                            color: Colors.blue, shape: BoxShape.circle),
                        child: const Icon(Icons.public,
                            color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Nuestros Servicios",
                        style: TextStyle(
                            color: primaryColor, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Logística Integral hacia Ecuador",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Conectamos al mundo con Ecuador a través de servicios logísticos inteligentes y personalizados.",
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 32),

                  // Grid of Services
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2, // Depending on screen width
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.3,
                    children: [
                      _buildServiceCard(
                          "Transporte Aéreo",
                          "Entrega rápida en 2-5 días desde cualquier parte del mundo.",
                          Icons.flight),
                      _buildServiceCard(
                          "Transporte Marítimo",
                          "FCL y LCL con tiempos de tránsito de 15-30 días.",
                          Icons.directions_boat),
                      _buildServiceCard(
                          "Transporte Terrestre",
                          "Distribución nacional con cobertura en todo Ecuador.",
                          Icons.local_shipping),
                      _buildServiceCard(
                          "Agenciamiento Aduanero",
                          "Gestión profesional con agentes certificados por el SENAE.",
                          Icons.description),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Bottom Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10))),
                          child: const Text("Cotizar Ahora",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                              foregroundColor: primaryColor,
                              side: const BorderSide(color: primaryColor),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10))),
                          child: const Text("Contactar",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckItem(BuildContext context, String title, String desc,
      {bool isDark = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.neonGreen.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child:
                const Icon(Icons.check, size: 16, color: AppColors.neonGreen),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(String title, String desc, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue[300], size: 28),
          const Spacer(),
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
          const SizedBox(height: 4),
          Text(desc,
              style: const TextStyle(color: Colors.white54, fontSize: 10),
              maxLines: 3,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
