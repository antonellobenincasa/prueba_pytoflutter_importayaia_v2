import 'package:flutter/material.dart';
import '../widgets/main_drawer.dart';
class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text("Contacto")), drawer: const MainDrawer(), body: const Center(child: Text("Página Contacto (Diseño Pendiente)")));
  }
}