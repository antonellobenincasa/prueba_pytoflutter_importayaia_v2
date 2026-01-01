import 'package:flutter/material.dart';
import '../widgets/main_drawer.dart';
import '../../config/theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: AppColors.darkBlueBackground,
      ),
      drawer: const MainDrawer(),
      body: const Center(
        child: Text(
          "Bienvenido al Dashboard",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }
}
