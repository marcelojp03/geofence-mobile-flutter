import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

/// Diálogo para guiar al usuario a desactivar la optimización de batería
class BatteryOptimizationDialog extends StatelessWidget {
  const BatteryOptimizationDialog({super.key});

  static Future<void> showIfNeeded(BuildContext context) async {
    if (!Platform.isAndroid) return;

    final status = await Permission.ignoreBatteryOptimizations.status;
    if (status.isGranted) return;

    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const BatteryOptimizationDialog(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.battery_alert, color: Colors.orange, size: 28),
          SizedBox(width: 12),
          Expanded(child: Text('Optimización de Batería')),
        ],
      ),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Para que el rastreo funcione correctamente en segundo plano, necesitas desactivar la optimización de batería para esta app.',
            style: TextStyle(fontSize: 14),
          ),
          SizedBox(height: 16),
          Text(
            '¿Por qué es necesario?',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          SizedBox(height: 8),
          _BulletPoint('Android puede detener el rastreo para ahorrar batería'),
          _BulletPoint('Sin esto, la ubicación podría no enviarse'),
          _BulletPoint('Tu hijo/a podría aparecer "sin conexión"'),
          SizedBox(height: 16),
          Text(
            '💡 Esto solo afecta a esta app, no a todo el teléfono.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Más tarde'),
        ),
        FilledButton.icon(
          onPressed: () async {
            Navigator.pop(context);
            await _openBatterySettings();
          },
          icon: const Icon(Icons.settings),
          label: const Text('Configurar'),
        ),
      ],
    );
  }

  static Future<void> _openBatterySettings() async {
    // Intentar abrir la configuración de ignorar optimización de batería
    final status = await Permission.ignoreBatteryOptimizations.request();

    if (!status.isGranted) {
      // Si no se pudo abrir directamente, abrir configuración de la app
      await openAppSettings();
    }
  }
}

class _BulletPoint extends StatelessWidget {
  final String text;
  const _BulletPoint(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 14)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}

/// Widget para mostrar el estado de la optimización de batería
class BatteryOptimizationStatus extends StatefulWidget {
  const BatteryOptimizationStatus({super.key});

  @override
  State<BatteryOptimizationStatus> createState() =>
      _BatteryOptimizationStatusState();
}

class _BatteryOptimizationStatusState extends State<BatteryOptimizationStatus>
    with WidgetsBindingObserver {
  bool _isOptimized = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Verificar de nuevo cuando la app vuelve al primer plano
    if (state == AppLifecycleState.resumed) {
      _checkStatus();
    }
  }

  Future<void> _checkStatus() async {
    if (!Platform.isAndroid) {
      if (mounted) {
        setState(() {
          _isOptimized = false;
          _isLoading = false;
        });
      }
      return;
    }

    final status = await Permission.ignoreBatteryOptimizations.status;
    if (mounted) {
      setState(() {
        _isOptimized = !status.isGranted;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox.shrink();
    }

    if (!_isOptimized) {
      return const SizedBox.shrink();
    }

    return Card(
      color: Colors.orange.shade50,
      child: InkWell(
        onTap: () => BatteryOptimizationDialog.showIfNeeded(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.orange.shade700),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Optimización de batería activa',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade900,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      'El rastreo podría no funcionar correctamente',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.orange.shade700),
            ],
          ),
        ),
      ),
    );
  }
}
