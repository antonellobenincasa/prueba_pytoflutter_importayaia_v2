import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 1. Importamos la configuración del Tema y Providers
import 'core/services/theme_provider.dart';
import 'core/services/navigation_sound_service.dart';

// 2. Importamos TODAS tus pantallas existentes según tu estructura de carpetas
import 'presentation/screens/landing_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/register_screen.dart';
import 'presentation/screens/home_screen.dart'; // Tu Dashboard
import 'presentation/screens/about_us_screen.dart'; // Pantalla Nosotros
import 'presentation/screens/contact_screen.dart'; // Pantalla Contacto
import 'presentation/screens/quote_request_screen.dart'; // Formulario de cotización
import 'presentation/screens/onboarding_screen.dart';
import 'presentation/screens/forgot_password_screen.dart';
import 'presentation/screens/profile_screen.dart'; // Perfil de usuario
import 'presentation/screens/notifications_screen.dart'; // Notificaciones
import 'presentation/screens/tracking_screen.dart'; // Tracking de embarques
import 'presentation/screens/quote_history_screen.dart'; // Historial de cotizaciones
import 'presentation/screens/tax_calculator_screen.dart'; // Calculadora de impuestos
import 'presentation/screens/aduana_experto_screen.dart'; // AduanaExpertoIA
import 'presentation/screens/admin_dashboard_screen.dart'; // Master Admin
import 'presentation/screens/admin_usuarios_screen.dart'; // Admin Users
import 'presentation/screens/admin_arancel_screen.dart'; // Admin Arancel
import 'presentation/screens/admin_tarifas_base_screen.dart'; // Admin Tarifas Base
import 'presentation/screens/admin_proveedores_screen.dart'; // Admin Proveedores

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => NavigationSoundService()),
      ],
      child: const ImportaYaApp(),
    ),
  );
}

class ImportaYaApp extends StatelessWidget {
  const ImportaYaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'ImportaYAia.com',
          debugShowCheckedModeBanner: false,

          // Aplicamos el tema basado en la preferencia del usuario
          theme: lightTheme(),
          darkTheme: darkTheme(),
          themeMode: themeProvider.themeMode,

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
            '/quote_form': (context) => const QuoteRequestScreen(),
            '/cost_simulator': (context) => const QuoteRequestScreen(),
            '/onboarding': (context) => const OnboardingScreen(),
            '/forgot_password': (context) => const ForgotPasswordScreen(),
            '/profile': (context) => const ProfileScreen(),
            '/notifications': (context) => const NotificationsScreen(),
            '/tracking': (context) => const TrackingScreen(),
            '/quote_history': (context) => const QuoteHistoryScreen(),
            '/tax_calculator': (context) => const TaxCalculatorScreen(),
            '/aduana_experto': (context) => const AduanaExpertoScreen(),
            '/admin_dashboard': (context) => const AdminDashboardScreen(),
            '/admin_usuarios': (context) => const AdminUsuariosScreen(),
            '/admin_arancel': (context) => const AdminArancelScreen(),
            '/admin_tarifas_base': (context) => const AdminTarifasBaseScreen(),
            '/admin_proveedores': (context) => const AdminProveedoresScreen(),
          },
        );
      },
    );
  }
}
