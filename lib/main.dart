import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart'; // Importar configuración de temas

// --- NUEVOS IMPORTS DE FIREBASE ---
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Asegúrate de que este archivo exista (si no, te dará error hasta generarlo)

// 1. Importamos la configuración del Tema y Providers
import 'core/services/theme_provider.dart';
import 'core/services/navigation_sound_service.dart';
import 'core/services/auth_service.dart';
import 'core/services/master_data_service.dart';

// 2. Importamos TODAS tus pantallas existentes según tu estructura de carpetas
import 'presentation/screens/landing_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/register_screen.dart';
import 'presentation/screens/home_screen.dart'; // Tu Dashboard
import 'presentation/screens/contact_screen.dart'; // Pantalla Contacto
import 'presentation/screens/forgot_password_screen.dart'; // Recuperar contraseña
import 'presentation/screens/quote_request_screen.dart'; // Formulario de cotización
import 'presentation/screens/onboarding_screen.dart';
import 'presentation/screens/profile_screen.dart'; // Perfil de usuario
import 'presentation/screens/notifications_screen.dart'; // Notificaciones
import 'presentation/screens/tracking_screen.dart'; // Tracking de embarques
import 'presentation/screens/quote_history_screen.dart'; // Historial de cotizaciones
import 'presentation/screens/tax_calculator_screen.dart'; // Calculadora de Impuestos
import 'presentation/screens/admin_dashboard_screen.dart'; // Master Admin
import 'presentation/screens/admin_usuarios_screen.dart'; // Admin Users
import 'presentation/screens/admin_arancel_screen.dart'; // Admin Arancel
import 'presentation/screens/admin_tarifas_base_screen.dart'; // Admin Tarifas Base
import 'presentation/screens/admin_proveedores_screen.dart'; // Admin Proveedores
import 'presentation/screens/admin_puertos_screen.dart';
import 'presentation/screens/admin_aeropuertos_screen.dart';
import 'presentation/screens/admin_profit_review_screen.dart';
import 'presentation/screens/admin_logs_screen.dart';
import 'presentation/screens/admin_tracking_ff_screen.dart';
import 'presentation/screens/admin_portal_ff_screen.dart';
import 'presentation/screens/admin_placeholder_screen.dart'; // Placeholder for new admin modules
import 'presentation/widgets/admin_protected_route.dart'; // Protected Route Wrapper

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- INICIALIZACIÓN DE FIREBASE ---
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // --- INICIALIZAR MASTER DATA (CACHE) ---
  await MasterDataService().init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => NavigationSoundService()),
        ChangeNotifierProvider(create: (_) => AuthService()),
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
          theme: appLightTheme(),
          darkTheme: appTheme(),
          themeMode: themeProvider.themeMode,

          // --- DEFINICIÓN DE RUTAS Y NAVEGACIÓN ---
          initialRoute: '/',

          // Mapa de rutas
          routes: {
            '/': (context) => const LandingScreen(),
            '/login': (context) => const LoginScreen(),
            '/forgot_password': (context) => const ForgotPasswordScreen(),
            '/register': (context) => const RegisterScreen(),
            '/onboarding': (context) => const OnboardingScreen(),
            '/dashboard': (context) => const HomeScreen(),
            '/profile': (context) => const ProfileScreen(),
            '/notifications': (context) => const NotificationsScreen(),
            '/quote_request': (context) => const QuoteRequestScreen(),
            '/tracking': (context) => const TrackingScreen(),
            '/history': (context) => const QuoteHistoryScreen(),
            '/support': (context) => const ContactScreen(),
            '/tax_calculator': (context) => const TaxCalculatorScreen(),
            '/home': (context) => const HomeScreen(), // Alias for /dashboard
            // Admin Routes
            '/admin_dashboard': (context) => const AdminProtectedRoute(
                  child: AdminDashboardScreen(),
                ),
            '/admin_cotizaciones': (context) => const AdminProtectedRoute(
                  child: AdminDashboardScreen(initialTab: 1),
                ),
            '/admin_usuarios': (context) => const AdminProtectedRoute(
                  child: AdminUsuariosScreen(),
                ),
            '/admin_arancel': (context) => const AdminProtectedRoute(
                  child: AdminArancelScreen(),
                ),
            '/admin_tarifas_base': (context) => const AdminProtectedRoute(
                  child: AdminTarifasBaseScreen(),
                ),
            '/admin_proveedores': (context) => const AdminProtectedRoute(
                  child: AdminProveedoresScreen(),
                ),
            // Nuevos Módulos de Admin Implementados
            '/admin_puertos': (context) => const AdminProtectedRoute(
                  child: AdminPuertosScreen(),
                ),
            '/admin_aeropuertos': (context) => const AdminProtectedRoute(
                  child: AdminAeropuertosScreen(),
                ),
            '/admin_profit_review': (context) => const AdminProtectedRoute(
                  child: AdminProfitReviewScreen(),
                ),
            '/admin_logs': (context) => const AdminProtectedRoute(
                  child: AdminLogsScreen(),
                ),
            '/admin_tracking_ff': (context) => const AdminProtectedRoute(
                  child: AdminTrackingFFScreen(),
                ),
            '/admin_portal_ff': (context) => const AdminProtectedRoute(
                  child: AdminPortalFFScreen(),
                ),
            // Módulos pendientes (Placeholders)
            '/admin_config_hitos': (context) => AdminProtectedRoute(
                  child: AdminPlaceholderScreen(
                    title: 'Configuración de Hitos',
                    currentRoute: 'config_hitos',
                  ),
                ),
            '/admin_cotizaciones_ff': (context) => AdminProtectedRoute(
                  child: AdminPlaceholderScreen(
                    title: 'Cotizaciones FF',
                    currentRoute: 'cotizaciones_ff',
                  ),
                ),
            '/admin_config_ff': (context) => AdminProtectedRoute(
                  child: AdminPlaceholderScreen(
                    title: 'Configuración FF',
                    currentRoute: 'config_ff',
                  ),
                ),
          },
        );
      },
    );
  }
}
