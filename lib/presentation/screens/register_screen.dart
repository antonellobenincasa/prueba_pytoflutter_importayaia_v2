import 'package:flutter/material.dart';
import '../../config/theme.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          // PANEL IZQUIERDO: Informativo (Oculto en móviles)
          if (MediaQuery.of(context).size.width > 800)
            Expanded(
              flex: 1,
              child: Container(
                color: AppColors.darkBlueBackground,
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset('assets/images/logo_header.png.png', height: 50, errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, color: Colors.white)), // Arreglo para prevenir error si falta imagen
                    const SizedBox(height: 40),
                    const Text(
                      "La logística de carga integral,\nahora es Inteligente!",
                      style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Plataforma inteligente de logística internacional para importar desde cualquier parte del mundo hacia Ecuador.",
                      style: TextStyle(color: AppColors.textGrey, fontSize: 16), // Corregido a AppColors.textGrey que existe
                    ),
                    const SizedBox(height: 60),
                    // Stats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSmallStat("100%", "Inteligente"),
                        _buildSmallStat("24/7", "Disponible"),
                        _buildSmallStat("EC", "Ecuador"),
                      ],
                    )
                  ],
                ),
              ),
            ),

          // PANEL DERECHO: Formulario de Registro
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: Column(
                    children: [
                      const Icon(Icons.person_add_alt_1, size: 60, color: AppColors.neonGreen),
                      const SizedBox(height: 10),
                      const Text("Crear Cuenta", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
                      const Text("Únete a ImportaYa.ia", style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 30),
                      
                      // Campos de Formulario (Simplificados para el ejemplo)
                      _buildTextField("Nombre *", Icons.person_outline),
                      _buildTextField("Apellido *", Icons.person_outline),
                      _buildTextField("Correo Electrónico *", Icons.email_outlined),
                      _buildTextField("Nombre de Empresa", Icons.business_outlined),
                      _buildTextField("Teléfono", Icons.phone_android_outlined),
                      _buildTextField("Contraseña *", Icons.lock_outline, isPassword: true),
                      
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.neonGreen,
                            foregroundColor: Colors.black,
                          ),
                          onPressed: () {},
                          child: const Text("Crear Cuenta ✓"),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/login'),
                        child: const Text("¿Ya tienes cuenta? Inicia sesión", style: TextStyle(color: Colors.blue)),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)), // Corregido color
      ],
    );
  }

  Widget _buildTextField(String label, IconData icon, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        obscureText: isPassword,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
        ),
      ),
    );
  }
}