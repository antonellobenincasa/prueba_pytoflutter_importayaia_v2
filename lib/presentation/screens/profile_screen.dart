import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mi Perfil")),
      body: const Center(
        child: Text("Datos del Usuario", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
