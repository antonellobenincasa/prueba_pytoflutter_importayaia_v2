import 'package:flutter/material.dart';
import '../../core/api/auth_repository.dart'; // Asegúrate que la ruta sea correcta
import 'quote_form_screen.dart';
import 'login_screen.dart'; // Importa tu pantalla de login para poder salir

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthRepository _authRepo = AuthRepository();
  
  String _userName = "Cargando...";
  String _companyName = "";
  String _userRuc = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final userData = await _authRepo.getUserData();
    setState(() {
      // Si el nombre viene vacío, ponemos "Usuario"
      _userName = (userData['name']?.isNotEmpty ?? false) ? userData['name']! : "Usuario";
      _companyName = userData['company'] ?? "Sin Empresa";
      _userRuc = userData['ruc'] ?? "Sin RUC registrado";
    });
  }

  void _logout() async {
    await _authRepo.logout();
    if (mounted) {
      // Regresar al login y borrar historial de navegación
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard ImportaYa"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: "Cerrar Sesión",
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- TARJETA DE PERFIL ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue,
                    child: Text(
                      _userName.isNotEmpty ? _userName[0].toUpperCase() : "U",
                      style: const TextStyle(fontSize: 24, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hola, $_userName",
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          _companyName.isNotEmpty ? _companyName : "Importador",
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        if (_userRuc.isNotEmpty && _userRuc != "Sin RUC registrado")
                          Text(
                            "RUC: $_userRuc",
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            const Text("Acciones Rápidas", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            // --- BOTÓN NUEVA COTIZACIÓN ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const QuoteFormScreen()),
                  );
                },
                icon: const Icon(Icons.add_circle_outline),
                label: const Text("SOLICITAR NUEVA COTIZACIÓN"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}