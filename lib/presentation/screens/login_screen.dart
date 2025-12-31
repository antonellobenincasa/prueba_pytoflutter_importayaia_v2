import 'package:flutter/material.dart';
import '../../core/api/auth_repository.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final AuthRepository _authRepository = AuthRepository();
  
  bool _isLoading = false;
  String? _errorMessage;

  void _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final username = _userController.text;
    final password = _passController.text;

    try {
      // Llamamos a tu Backend Django
      bool success = await _authRepository.login(username, password);

      if (success) {
        // Si el login es correcto, ir al Home
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Usuario o contraseña incorrectos';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error de conexión: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ImportaYa Login")),

      body: SingleChildScrollView( // <--- Agrega este widget
            child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo o Título
            if (_errorMessage != null)
               Text(_errorMessage!, style: const TextStyle(color: Colors.red)), // Aquí se imprime el HTML del error 404

            const Icon(Icons.local_shipping, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            
            // Campo Usuario
            TextField(
              controller: _userController,
              decoration: const InputDecoration(
                labelText: 'Usuario / Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),

              ),
            ),
            const SizedBox(height: 15),

            // Campo Contraseña
            TextField(
              controller: _passController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 20),

            // Mensaje de Error
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),

            // Botón de Login
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("INGRESAR"),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}