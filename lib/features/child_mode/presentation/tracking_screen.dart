import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/tracker_provider.dart';

/// Pantalla de tracking activo para el modo hijo
class TrackingScreen extends ConsumerStatefulWidget {
  static const String name = 'tracking';

  const TrackingScreen({super.key});

  @override
  ConsumerState<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends ConsumerState<TrackingScreen> {
  @override
  void initState() {
    super.initState();
    // Verificar configuración después del build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkConfig();
    });
  }

  void _checkConfig() {
    final state = ref.read(trackerNotifierProvider);
    if (!state.isConfigured) {
      context.go('/child/setup');
    }
  }

  @override
  Widget build(BuildContext context) {
    final trackerState = ref.watch(trackerNotifierProvider);
    final notifier = ref.read(trackerNotifierProvider.notifier);

    // Si no está configurado, mostrar loading mientras redirige
    if (!trackerState.isConfigured) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modo Rastreador'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettingsMenu(context, notifier),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Card de estado principal
              _buildStatusCard(trackerState),

              const SizedBox(height: 24),

              // Card de información
              _buildInfoCard(trackerState),

              const SizedBox(height: 16),

              // Error si existe
              if (trackerState.lastError != null)
                _buildErrorCard(trackerState.lastError!),

              const Spacer(),

              // Botones de control
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: trackerState.isRunning
                          ? () => notifier.sendNow()
                          : null,
                      icon: const Icon(Icons.send),
                      label: const Text('Enviar'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: () {
                        if (trackerState.isRunning) {
                          notifier.stopTracking();
                        } else {
                          notifier.startTracking();
                        }
                      },
                      icon: Icon(
                        trackerState.isRunning
                            ? Icons.stop_circle
                            : Icons.play_circle,
                      ),
                      label: Text(
                        trackerState.isRunning ? 'Detener' : 'Iniciar',
                      ),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: trackerState.isRunning
                            ? Colors.red
                            : Colors.green,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Contador de envíos
              Center(
                child: Text(
                  'Posiciones enviadas: ${trackerState.sendCount}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(TrackerState state) {
    final isRunning = state.isRunning;
    final color = isRunning ? Colors.green : Colors.orange;

    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(
              isRunning ? Icons.location_searching : Icons.location_off,
              size: 64,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            Text(
              isRunning ? 'Rastreando' : 'Pausado',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isRunning
                  ? 'Enviando ubicación cada 30 segundos'
                  : 'El rastreo está pausado',
              style: const TextStyle(fontSize: 14, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            if (state.childName != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.child_care, size: 18, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      state.childName!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(TrackerState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.access_time,
              'Último envío',
              state.lastSentAt != null
                  ? _formatDateTime(state.lastSentAt!)
                  : 'Nunca',
            ),
            const Divider(),
            _buildInfoRow(
              Icons.location_on,
              'Ubicación',
              state.lastLat != null && state.lastLng != null
                  ? '${state.lastLat!.toStringAsFixed(4)}, ${state.lastLng!.toStringAsFixed(4)}'
                  : 'Sin datos',
            ),
            const Divider(),
            _buildInfoRow(
              Icons.battery_std,
              'Batería',
              state.lastBattery != null ? '${state.lastBattery}%' : 'Sin datos',
              trailing: state.lastBattery != null
                  ? _getBatteryIcon(state.lastBattery!)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Card(
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red[700]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                error,
                style: TextStyle(color: Colors.red[900], fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getBatteryIcon(int level) {
    Color color;
    IconData icon;

    if (level > 80) {
      color = Colors.green;
      icon = Icons.battery_full;
    } else if (level > 50) {
      color = Colors.green;
      icon = Icons.battery_5_bar;
    } else if (level > 20) {
      color = Colors.orange;
      icon = Icons.battery_3_bar;
    } else {
      color = Colors.red;
      icon = Icons.battery_alert;
    }

    return Icon(icon, color: color, size: 20);
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inSeconds < 10) return 'Ahora mismo';
    if (diff.inSeconds < 60) return 'Hace ${diff.inSeconds}s';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes}min';

    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');

    return '$hour:$minute:$second';
  }

  void _showSettingsMenu(BuildContext context, TrackerNotifier notifier) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Reconfigurar dispositivo'),
              onTap: () {
                Navigator.pop(ctx);
                _showReconfigureDialog(context, notifier);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Salir del modo hijo',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () async {
                Navigator.pop(ctx);
                await notifier.clearConfig();
                if (mounted) {
                  context.go('/mode');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showReconfigureDialog(BuildContext context, TrackerNotifier notifier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reconfigurar'),
        content: const Text(
          '¿Deseas reconfigurar este dispositivo? Se detendrá el rastreo actual.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await notifier.clearConfig();
              if (mounted) {
                context.go('/child/setup');
              }
            },
            child: const Text('Reconfigurar'),
          ),
        ],
      ),
    );
  }
}
