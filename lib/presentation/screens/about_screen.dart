import 'package:flutter/material.dart';
import '../widgets/main_drawer.dart';
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text("Nosotros")), drawer: const MainDrawer(), body: const Center(child: Text("Página Nosotros (Diseño Pendiente)")));
  }
}