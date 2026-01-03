import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/theme_provider.dart';
import '../../core/services/navigation_sound_service.dart';

/// Settings Toggle Button Widget
/// Provides theme and sound toggle options accessible from any screen
class SettingsToggleButton extends StatelessWidget {
  const SettingsToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.settings, size: 24),
      tooltip: 'Configuración',
      color: Theme.of(context).cardTheme.color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) => [
        // Theme Toggle
        PopupMenuItem(
          value: 'theme',
          child: Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return Row(
                children: [
                  Icon(
                    themeProvider.isDarkMode
                        ? Icons.light_mode
                        : Icons.dark_mode,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      themeProvider.isDarkMode ? 'Modo Claro' : 'Modo Oscuro',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                  Switch(
                    value: !themeProvider.isDarkMode,
                    onChanged: (_) => themeProvider.toggleTheme(),
                    activeThumbColor: Theme.of(context).colorScheme.primary,
                  ),
                ],
              );
            },
          ),
        ),

        const PopupMenuDivider(),

        // Sound Toggle
        PopupMenuItem(
          value: 'sound',
          child: Consumer<NavigationSoundService>(
            builder: (context, soundService, _) {
              return Row(
                children: [
                  Icon(
                    soundService.isEnabled ? Icons.volume_up : Icons.volume_off,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Sonido de Navegación',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                  Switch(
                    value: soundService.isEnabled,
                    onChanged: (_) => soundService.toggleSound(),
                    activeThumbColor: Theme.of(context).colorScheme.primary,
                  ),
                ],
              );
            },
          ),
        ),
      ],
      onSelected: (value) {
        if (value == 'theme') {
          context.read<ThemeProvider>().toggleTheme();
        } else if (value == 'sound') {
          context.read<NavigationSoundService>().toggleSound();
        }
      },
    );
  }
}

/// Compact Theme Toggle Icon Button
/// A simple icon button for quick theme switching
class ThemeToggleIconButton extends StatelessWidget {
  const ThemeToggleIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return IconButton(
          icon: Icon(
            themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
          ),
          tooltip: themeProvider.isDarkMode
              ? 'Cambiar a Modo Claro'
              : 'Cambiar a Modo Oscuro',
          onPressed: () => themeProvider.toggleTheme(),
        );
      },
    );
  }
}

/// Compact Sound Toggle Icon Button
/// A simple icon button for quick sound mute/unmute
class SoundToggleIconButton extends StatelessWidget {
  const SoundToggleIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationSoundService>(
      builder: (context, soundService, _) {
        return IconButton(
          icon: Icon(
            soundService.isEnabled ? Icons.volume_up : Icons.volume_off,
          ),
          tooltip: soundService.isEnabled ? 'Silenciar' : 'Activar Sonido',
          onPressed: () => soundService.toggleSound(),
        );
      },
    );
  }
}
