import 'package:flutter/material.dart';

// 1. Importamos la configuración del Tema (Colores y Estilos)
import 'config/theme.dart';

// 2. Importamos TODAS tus pantallas existentes según tu estructura de carpetas
import 'presentation/screens/landing_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/register_screen.dart';
import 'presentation/screens/home_screen.dart';       // Tu Dashboard
import 'presentation/screens/about_screen.dart';      // Pantalla Nosotros
import 'presentation/screens/contact_screen.dart';    // Pantalla Contacto
import 'presentation/screens/quote_form_screen.dart'; // Pantalla de Cotización
import 'presentation/screens/onboarding_screen.dart';
import 'presentation/screens/forgot_password_screen.dart';

void main() {
  runApp(const ImportaYaApp());
}

class ImportaYaApp extends StatelessWidget {
  const ImportaYaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ImportaYa.ia', // Nombre de la App en el gestor de tareas
      debugShowCheckedModeBanner: false, // Quita la etiqueta "Debug" de la esquina
      
      // Aplicamos el tema personalizado (Oscuro y Verde Neón)
      theme: appTheme(), 
      
      // --- DEFINICIÓN DE RUTAS Y NAVEGACIÓN ---
      
      // Definimos la Landing Page como la primera pantalla que ve el usuario
      initialRoute: '/onboarding', 
      
      // Mapa de rutas: Aquí le decimos a Flutter qué archivo abrir para cada nombre
      routes: {
        '/': (context) => const LandingScreen(),      // Pantalla de Inicio (Landing)
        '/login': (context) => const LoginScreen(),   // Iniciar Sesión
        '/registro': (context) => const RegisterScreen(), // Crear Cuenta
        '/home': (context) => const HomeScreen(),     // Dashboard Principal (después de loguearse)
        '/nosotros': (context) => const AboutScreen(), // Página "Nosotros"
        '/contacto': (context) => const ContactScreen(), // Página "Contacto"
        '/quote_form': (context) => const QuoteFormScreen(), // Formulario de cotización
        '/onboarding': (context) => const OnboardingScreen(),
        '/forgot_password': (context) => const ForgotPasswordScreen(),
      },
    );
  }
}