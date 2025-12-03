import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../children/providers/children_provider.dart';
import '../../tracking/providers/tracking_provider.dart';
import '../../alerts/providers/alerts_provider.dart';
import '../../alerts/domain/entities/alert.dart';
import '../domain/entities/child.dart';
import '../../../shared/utils/responsive.dart';

/// Pantalla de detalle de un hijo con mapa y alertas
class ChildDetailScreen extends ConsumerStatefulWidget {
  final int childId;

  const ChildDetailScreen({super.key, required this.childId});

  @override
  ConsumerState<ChildDetailScreen> createState() => _ChildDetailScreenState();
}

class _ChildDetailScreenState extends ConsumerState<ChildDetailScreen> {
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    final childAsync = ref.watch(childDetailProvider(widget.childId));
    final positionAsync = ref.watch(childLastPositionProvider(widget.childId));
    final alertsAsync = ref.watch(childAlertsProvider(widget.childId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: childAsync.when(
          data: (child) => Text(child.fullName),
          loading: () => const Text('Cargando...'),
          error: (_, __) => const Text('Error'),
        ),
        actions: [
          // Botón para vincular dispositivo (generar QR)
          childAsync.when(
            data: (child) => IconButton(
              icon: const Icon(Icons.qr_code),
              tooltip: 'Vincular dispositivo',
              onPressed: () => _showQRDialog(context, child),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(childLastPositionProvider(widget.childId));
              ref.invalidate(childAlertsProvider(widget.childId));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Mapa con la última posición
          Expanded(
            flex: 2,
            child: positionAsync.when(
              data: (position) {
                if (position == null) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Sin ubicación registrada',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                final latLng = LatLng(position.lat, position.lng);

                return Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: latLng,
                        initialZoom: 16.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.geokids.app',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: latLng,
                              width: 50,
                              height: 50,
                              child: const Icon(
                                Icons.location_pin,
                                color: Colors.red,
                                size: 50,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Info de la última posición
                    Positioned(
                      top: 16,
                      left: 16,
                      right: 16,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Última actualización: ${position.timeAgo}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              const Spacer(),
                              if (position.batteryLevel != null) ...[
                                Icon(
                                  _getBatteryIcon(position.batteryLevel!),
                                  size: 16,
                                  color: position.batteryLevel! > 20
                                      ? Colors.green
                                      : Colors.red,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${position.batteryLevel}%',
                                  style: TextStyle(
                                    color: position.batteryLevel! > 20
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Botón para centrar mapa
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: FloatingActionButton.small(
                        heroTag: 'center_map',
                        onPressed: () {
                          _mapController.move(latLng, 16.0);
                        },
                        child: const Icon(Icons.my_location),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: $e'),
                  ],
                ),
              ),
            ),
          ),

          // Lista de alertas recientes
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Text(
                        'Alertas Recientes',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      alertsAsync.when(
                        data: (alerts) {
                          final unread = alerts.where((a) => !a.isRead).length;
                          if (unread > 0) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$unread',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: alertsAsync.when(
                    data: (alerts) {
                      if (alerts.isEmpty) {
                        return const Center(
                          child: Text(
                            'No hay alertas',
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: alerts.length > 5 ? 5 : alerts.length,
                        itemBuilder: (context, index) {
                          final alert = alerts[index];
                          return _buildAlertTile(alert);
                        },
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Error: $e')),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertTile(Alert alert) {
    final isExit = alert.type == AlertType.exitArea;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isExit ? Colors.orange : Colors.green,
          child: Icon(isExit ? Icons.logout : Icons.login, color: Colors.white),
        ),
        title: Text(
          alert.type.displayName,
          style: TextStyle(
            fontWeight: alert.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Text(
          _formatDateTime(alert.createdAt),
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: !alert.isRead
            ? Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              )
            : null,
      ),
    );
  }

  /// Muestra un dialog con el código QR para vincular dispositivo
  void _showQRDialog(BuildContext context, Child child) {
    // Datos que irán en el QR
    final qrData = jsonEncode({
      'childId': child.id,
      'childName': child.fullName,
      'schoolId': child.schoolId,
    });

    showDialog(
      context: context,
      builder: (dialogContext) {
        final dr = dialogContext.responsive;
        final primaryColor = Theme.of(dialogContext).colorScheme.primary;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(dr.dp(2)),
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.qr_code, color: primaryColor, size: dr.dp(3)),
              SizedBox(width: dr.wp(2)),
              Flexible(
                child: Text(
                  'Vincular Dispositivo',
                  style: TextStyle(fontSize: dr.dp(2.2)),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: dr.wp(75),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Instrucciones
                Container(
                  padding: EdgeInsets.all(dr.dp(1.2)),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(dr.dp(1)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue[700],
                        size: dr.dp(2.2),
                      ),
                      SizedBox(width: dr.wp(2)),
                      Expanded(
                        child: Text(
                          'Escanea este código desde el celular de ${child.fullName}',
                          style: TextStyle(
                            fontSize: dr.dp(1.5),
                            color: Colors.blue[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: dr.hp(2.5)),
                // QR Code
                Container(
                  padding: EdgeInsets.all(dr.dp(1.5)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(dr.dp(1.5)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data: qrData,
                    version: QrVersions.auto,
                    size: dr.wp(45),
                    backgroundColor: Colors.white,
                    eyeStyle: QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: primaryColor,
                    ),
                    dataModuleStyle: QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: primaryColor,
                    ),
                  ),
                ),
                SizedBox(height: dr.hp(2)),
                // Nombre del hijo
                Text(
                  child.fullName,
                  style: TextStyle(
                    fontSize: dr.dp(1.8),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Cerrar', style: TextStyle(fontSize: dr.dp(1.6))),
            ),
          ],
        );
      },
    );
  }

  IconData _getBatteryIcon(int level) {
    if (level > 80) return Icons.battery_full;
    if (level > 60) return Icons.battery_5_bar;
    if (level > 40) return Icons.battery_4_bar;
    if (level > 20) return Icons.battery_2_bar;
    return Icons.battery_alert;
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'Hace un momento';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} hora(s)';

    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
