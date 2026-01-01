import 'package:flutter/material.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Contacto")),
      body: const Center(
        child: Text("Información de Contacto",
            style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
