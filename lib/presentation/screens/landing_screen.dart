import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../widgets/main_drawer.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // CORRECCIÓN 1: El 'const' va aquí arriba, abarcando todo el Row
        title: const Row(
          children: [
            // Se quitan los 'const' individuales porque ya el padre es const
            Icon(Icons.local_shipping, color: AppColors.neonGreen),
            SizedBox(width: 10),
            Text("ImportaYAia.com"),
          ],
        ),
      ),
      drawer: const MainDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(context),
            _buildHowItWorksSection(context),
            _buildServicesSection(context),
            _buildFinalCTA(context),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS DE SECCIONES ---

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 80.0),
      color: AppColors.darkBlueBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Importa fácil, sin\ncomplicaciones!",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 42),
          ),
          const SizedBox(height: 20),
          const Text(
            "La logística de carga integral, ahora es Inteligente! Somos tu aliado para importar desde cualquier parte del mundo hacia Ecuador.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 18),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/registro'),
            child: const Text("COTIZA AHORA →"),
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
      color: const Color(0xFF0D1B2A),
      child: Column(
        children: [
          const Text("¿Cómo funciona?", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text("Importar es más fácil de lo que piensas. Te guiamos paso a paso.", style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 60),
          Wrap(
            spacing: 30,
            runSpacing: 40,
            alignment: WrapAlignment.center,
            children: [
              _buildStepItem("1", "Cotiza", "Solicita tu cotización Inteligente en 2 minutos", Icons.assignment_outlined),
              _buildStepItem("2", "Aprueba", "Revisa y aprueba tu cotización", Icons.check_circle_outline),
              _buildStepItem("3", "Embarca", "Tu mercancía viaja segura hacia Ecuador", Icons.directions_boat_outlined),
              _buildStepItem("4", "Recibe", "Entrega en tu puerta con tracking 24/7", Icons.inventory_2_outlined),
            ],
          ),
          const SizedBox(height: 50),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonGreen),
            onPressed: () {},
            child: const Text("Comenzar Ahora →"),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
      color: Colors.white,
      child: Column(
        children: [
          const Text("Nuestros Servicios", style: TextStyle(color: Color(0xFF0D1B2A), fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          const Text("Soluciones integrales de logística internacional adaptadas a tu negocio.", textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 60),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              _buildServiceCard(
                title: "Transporte Aéreo",
                subtitle: "Entrega rápida de 2-5 días",
                description: "Servicio de carga aérea para importaciones urgentes desde cualquier parte del mundo.",
                icon: Icons.flight_takeoff,
                gradient: const [Color(0xFF1E2A38), Color(0xFF2C3E50)],
                features: const ["Consolidación desde China, USA y Europa", "Tracking Inteligente en tiempo real"],
              ),
              _buildServiceCard(
                title: "Transporte Marítimo",
                subtitle: "Carga FCL y LCL en 15-30 días",
                description: "Transporte marítimo económico para grandes volúmenes de mercancía.",
                icon: Icons.directions_boat,
                gradient: const [Color(0xFF00B4D8), Color(0xFF0077B6)],
                features: const ["Contenedores FCL 20' y 40'", "Carga consolidada LCL"],
              ),
              _buildServiceCard(
                title: "Transporte Terrestre",
                subtitle: "Entrega nacional en 1-3 días",
                description: "Distribución terrestre con cobertura en todas las provincias del Ecuador.",
                icon: Icons.local_shipping,
                gradient: const [Color(0xFFA4F40B), Color(0xFF82C400)],
                textColor: Colors.black,
                features: const ["Entrega puerta a puerta en todo Ecuador", "Servicio exento de IVA"],
              ),
              _buildServiceCard(
                title: "Agenciamiento Aduanero",
                subtitle: "Despacho 100% legal y seguro",
                description: "Gestión aduanera profesional con agentes certificados por el SENAE.",
                icon: Icons.gavel,
                gradient: const [Color(0xFF005F73), Color(0xFF0A9396)],
                features: const ["Clasificación arancelaria correcta", "Trámite de permisos y certificados"],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinalCTA(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      color: const Color(0xFF00B4D8),
      child: Column(
        children: [
          const Text(
            "¿Listo para importar de forma inteligente?",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          const Text(
            "Únete a más de 500 importadores que confían en ImportaYa.ia.",
            style: TextStyle(color: Color(0xFFF0F0F0)), 
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonGreen,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            ),
            onPressed: () => Navigator.pushNamed(context, '/registro'),
            child: const Text("Cotiza Ahora - Es Gratis →", style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(String number, String title, String sub, IconData icon) {
    return SizedBox(
      width: 200,
      child: Column(
        children: [
          Icon(icon, color: AppColors.neonGreen, size: 40),
          const SizedBox(height: 15),
          CircleAvatar(
            backgroundColor: AppColors.neonGreen,
            radius: 15,
            child: Text(number, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(sub, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildServiceCard({
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required List<Color> gradient,
    required List<String> features,
    Color textColor = Colors.white,
  }) {
    return Container(
      width: 350,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            // CORRECCIÓN 2: Uso de withValues en lugar de withOpacity
            color: Colors.black.withValues(alpha: 0.1), 
            blurRadius: 10, 
            offset: const Offset(0, 5)
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CORRECCIÓN 2: Uso de withValues
          Icon(icon, color: textColor.withValues(alpha: 0.8), size: 40), 
          const SizedBox(height: 20),
          Text(title, style: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.bold)),
          // CORRECCIÓN 2: Uso de withValues
          Text(subtitle, style: TextStyle(color: textColor.withValues(alpha: 0.7), fontSize: 14)), 
          const SizedBox(height: 20),
          // CORRECCIÓN 2: Uso de withValues
          Text(description, style: TextStyle(color: textColor.withValues(alpha: 0.9), fontSize: 15)), 
          const SizedBox(height: 20),
          ...features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.check, color: textColor, size: 16),
                    const SizedBox(width: 10),
                    Expanded(child: Text(f, style: TextStyle(color: textColor, fontSize: 13))),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}