import 'package:flutter/material.dart';

// 1. Importamos la configuración del Tema (Colores y Estilos)
import 'config/theme.dart';

// 2. Importamos TODAS tus pantallas existentes según tu estructura de carpetas
import 'presentation/screens/landing_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/register_screen.dart';
import 'presentation/screens/home_screen.dart'; // Tu Dashboard
import 'presentation/screens/about_us_screen.dart'; // Pantalla Nosotros
import 'presentation/screens/contact_screen.dart'; // Pantalla Contacto
import 'presentation/screens/cost_simulator_screen.dart'; // Formulario de cotización
import 'presentation/screens/onboarding_screen.dart';
import 'presentation/screens/forgot_password_screen.dart';
import 'presentation/screens/profile_screen.dart'; // Perfil de usuario
import 'presentation/screens/notifications_screen.dart'; // Notificaciones
import 'presentation/screens/tracking_screen.dart'; // Tracking de embarques
import 'presentation/screens/quote_history_screen.dart'; // Historial de cotizaciones
import 'presentation/screens/tax_calculator_screen.dart'; // Calculadora de impuestos

void main() {
  runApp(const ImportaYaApp());
}

class ImportaYaApp extends StatelessWidget {
  const ImportaYaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ImportaYa.ia',
      debugShowCheckedModeBanner: false,

      // Aplicamos el tema personalizado (Oscuro y Verde Neón)
      theme: appTheme(),

      // --- DEFINICIÓN DE RUTAS Y NAVEGACIÓN ---
      initialRoute: '/',

      // Mapa de rutas
      routes: {
        '/': (context) => const LandingScreen(),
        '/login': (context) => const LoginScreen(),
        '/registro': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/nosotros': (context) => const AboutUsScreen(),
        '/contacto': (context) => const ContactScreen(),
        '/quote_form': (context) => const CostSimulatorScreen(),
        '/cost_simulator': (context) => const CostSimulatorScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/forgot_password': (context) => const ForgotPasswordScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/tracking': (context) => const TrackingScreen(),
        '/quote_history': (context) => const QuoteHistoryScreen(),
        '/tax_calculator': (context) => const TaxCalculatorScreen(),
      },
    );
  }
}
