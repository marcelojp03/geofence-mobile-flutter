import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Pantalla de tracking para el modo hijo
class TrackingScreen extends ConsumerStatefulWidget {
  static const String name = 'tracking';

  const TrackingScreen({super.key});

  @override
  ConsumerState<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends ConsumerState<TrackingScreen> {
  bool _isTracking = false;
  double _lat = 0.0;
  double _lng = 0.0;
  int _battery = 100;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modo Seguimiento'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Estado del tracking
              Card(
                color: _isTracking ? Colors.green : Colors.orange,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Icon(
                        _isTracking ? Icons.check_circle : Icons.pause_circle,
                        size: 64,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _isTracking ? 'Rastreando' : 'Pausado',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isTracking
                            ? 'Tu ubicación se está enviando cada 30s'
                            : 'El rastreo está pausado',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Información del dispositivo
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Información del Dispositivo',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildInfoRow(Icons.battery_std, 'Batería', '$_battery%'),
                      const Divider(),

                      _buildInfoRow(
                        Icons.location_on,
                        'Latitud',
                        _lat.toStringAsFixed(6),
                      ),
                      const Divider(),

                      _buildInfoRow(
                        Icons.location_on,
                        'Longitud',
                        _lng.toStringAsFixed(6),
                      ),
                      const Divider(),

                      _buildInfoRow(
                        Icons.phone_android,
                        'Dispositivo',
                        'Android',
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Botón de control
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isTracking = !_isTracking;
                  });
                  // TODO: Iniciar/detener tracking real
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isTracking ? Colors.orange : Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  _isTracking ? 'Pausar Rastreo' : 'Iniciar Rastreo',
                  style: const TextStyle(fontSize: 18),
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'Esta pantalla debe permanecer abierta para enviar la ubicación en tiempo real.',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
