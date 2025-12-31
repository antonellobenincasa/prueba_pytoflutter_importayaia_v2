import 'package:flutter/material.dart';
import '../../config/theme.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold);

    return Drawer(
      backgroundColor: AppColors.darkBlueBackground,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.darkBlueBackground,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                 const Icon(Icons.local_shipping, size: 50, color: AppColors.neonGreen),
                const SizedBox(height: 10),
                Text('ImportaYa.ia', style: textStyle.copyWith(fontSize: 24, color: Colors.white)),
                Text('Logística Inteligente', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textGrey)),
              ],
            ),
          ),
          // Opciones del Menú
          ListTile(
            leading: const Icon(Icons.home, color: AppColors.textWhite),
            title: Text('Inicio', style: textStyle.copyWith(color: AppColors.textWhite)),
            onTap: () => Navigator.pushReplacementNamed(context, '/'),
          ),
          ListTile(
            leading: const Icon(Icons.people, color: AppColors.textWhite),
            title: Text('Nosotros', style: textStyle.copyWith(color: AppColors.textWhite)),
            onTap: () {
               Navigator.pop(context); // Cerrar drawer
               Navigator.pushNamed(context, '/nosotros');
            },
          ),
          ListTile(
            leading: const Icon(Icons.contact_mail, color: AppColors.textWhite),
            title: Text('Contacto', style: textStyle.copyWith(color: AppColors.textWhite)),
            onTap: () {
               Navigator.pop(context);
               Navigator.pushNamed(context, '/contacto');
            },
          ),
          const Divider(color: AppColors.textGrey),
           Padding(
             padding: const EdgeInsets.all(16.0),
             child: ElevatedButton(
               style: ElevatedButton.styleFrom(
                 backgroundColor: AppColors.neonGreen,
                  foregroundColor: AppColors.darkBlueBackground,
               ),
              onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/registro');
              },
              child: const Text("COTIZA AHORA"),
                     ),
           ),
          ListTile(
            leading: const Icon(Icons.login, color: AppColors.neonGreen),
            title: Text('Iniciar Sesión', style: textStyle.copyWith(color: AppColors.neonGreen)),
            onTap: () {
               Navigator.pop(context);
               Navigator.pushNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}