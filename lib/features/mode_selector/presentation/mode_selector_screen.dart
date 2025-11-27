import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Pantalla para seleccionar el modo de la aplicación
class ModeSelectorScreen extends ConsumerWidget {
  static const String name = 'mode';

  const ModeSelectorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.family_restroom, size: 100, color: Colors.grey),
              const SizedBox(height: 32),
              const Text(
                '¿Cómo vas a usar la app?',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Botón Modo Padre
              ElevatedButton.icon(
                onPressed: () {
                  context.go('/login');
                },
                icon: const Icon(Icons.person, size: 32),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Soy Padre/Madre',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Botón Modo Hijo
              OutlinedButton.icon(
                onPressed: () {
                  context.go('/child/setup');
                },
                icon: const Icon(Icons.phone_android, size: 32),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Este es el celular de mi hijo/a',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),

              const SizedBox(height: 32),
              Text(
                'Puedes cambiar esto más tarde en la configuración',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
