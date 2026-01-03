import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';

class AdminProtectedRoute extends StatelessWidget {
  final Widget child;

  const AdminProtectedRoute({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        // 1. Check if logged in
        if (!authService.isLoggedIn) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/login');
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. Check if user is admin
        final isAdmin = authService.userRole == 'admin' ||
            authService.userRole == 'superuser';

        if (!isAdmin) {
          // Redirect strictly to home if not admin to avoid loop
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // Use pushReplacement to avoid back-navigating to forbidden page
            Navigator.of(context).pushReplacementNamed('/home');

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Acceso denegado. Se requieren permisos de administrador.'),
                backgroundColor: Colors.red,
              ),
            );
          });
          return const Scaffold(
            backgroundColor: Color(0xFF050A14), // Match app background
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 3. Authorized
        return child;
      },
    );
  }
}
