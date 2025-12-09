import 'dart:async';
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
import '../../schools/providers/schools_provider.dart';
import '../domain/entities/child.dart';
import '../../../config/theme/app_theme.dart';

/// Pantalla de detalle de un hijo con mapa y alertas
class ChildDetailScreen extends ConsumerStatefulWidget {
  final int childId;

  const ChildDetailScreen({super.key, required this.childId});

  @override
  ConsumerState<ChildDetailScreen> createState() => _ChildDetailScreenState();
}

class _ChildDetailScreenState extends ConsumerState<ChildDetailScreen> {
  final MapController _mapController = MapController();
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    // Auto-refresh cada 30 segundos
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        ref.invalidate(childLastPositionProvider(widget.childId));
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final childAsync = ref.watch(childDetailProvider(widget.childId));
    final positionAsync = ref.watch(childLastPositionProvider(widget.childId));
    final alertsAsync = ref.watch(childAlertsProvider(widget.childId));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        title: childAsync.when(
          data: (child) => Text(
            child.fullName,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          loading: () => const Text('Cargando...'),
          error: (_, __) => const Text('Error'),
        ),
        elevation: 0,
        scrolledUnderElevation: 2,
        actions: [
          childAsync.when(
            data: (child) => IconButton(
              icon: Icon(
                Icons.qr_code_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              tooltip: 'Vincular dispositivo',
              onPressed: () => _showQRDialog(context, child, isDark),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          IconButton(
            icon: Icon(
              Icons.refresh_rounded,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            onPressed: () {
              ref.invalidate(childLastPositionProvider(widget.childId));
              ref.invalidate(childAlertsProvider(widget.childId));
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // Mapa con la última posición y geofence
          Expanded(
            flex: 2,
            child: _buildMapSection(context, positionAsync, theme, isDark),
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
                      Text(
                        'Alertas Recientes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const Spacer(),
                      alertsAsync.when(
                        data: (alerts) {
                          final unread = alerts.where((a) => !a.isRead).length;
                          if (unread > 0) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.errorColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$unread',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
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
                        return Center(
                          child: Text(
                            'No hay alertas',
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 14,
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: alerts.length > 5 ? 5 : alerts.length,
                        itemBuilder: (context, index) {
                          final alert = alerts[index];
                          return _buildAlertTile(alert, theme, isDark);
                        },
                      );
                    },
                    loading: () => Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryColor,
                      ),
                    ),
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

  /// Construye la sección del mapa con la posición del hijo y el geofence del colegio
  Widget _buildMapSection(
    BuildContext context,
    AsyncValue<dynamic> positionAsync,
    ThemeData theme,
    bool isDark,
  ) {
    // Obtener el geofence del colegio
    final schoolGeofenceAsync = ref.watch(currentSchoolGeofenceProvider);

    return positionAsync.when(
      data: (position) {
        if (position == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_off,
                  size: 64,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'Sin ubicación registrada',
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          );
        }

        final latLng = LatLng(position.lat, position.lng);

        // Construir polígono del geofence si existe
        final List<Polygon> geofencePolygons = [];
        schoolGeofenceAsync.whenData((school) {
          if (school != null && school.hasGeofence) {
            geofencePolygons.add(
              Polygon(
                points: school.geofence!.coordinates,
                color: Colors.blue.withValues(alpha: 0.2),
                borderColor: Colors.blue,
                borderStrokeWidth: 3,
              ),
            );
          }
        });

        return Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: latLng,
                initialZoom: 16.0,
                minZoom: 10,
                maxZoom: 18,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.geofence.app',
                ),
                // Capa del geofence (polígono del colegio)
                if (geofencePolygons.isNotEmpty)
                  PolygonLayer(polygons: geofencePolygons),
                // Marcador de ubicación del hijo
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
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2a2a4a) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 18,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Última actualización: ${position.timeAgo}',
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    if (position.batteryLevel != null) ...[
                      Icon(
                        _getBatteryIcon(position.batteryLevel!),
                        size: 18,
                        color: position.batteryLevel! > 20
                            ? AppTheme.insideColor
                            : AppTheme.errorColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${position.batteryLevel}%',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: position.batteryLevel! > 20
                              ? AppTheme.insideColor
                              : AppTheme.errorColor,
                        ),
                      ),
                    ],
                  ],
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
    );
  }

  Widget _buildAlertTile(Alert alert, ThemeData theme, bool isDark) {
    final isExit = alert.type == AlertType.exitArea;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2a2a4a) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isExit
                  ? AppTheme.warningColor.withValues(alpha: 0.15)
                  : AppTheme.insideColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isExit ? Icons.logout_rounded : Icons.login_rounded,
              color: isExit ? AppTheme.warningColor : AppTheme.insideColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.type.displayName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: alert.isRead
                        ? FontWeight.w500
                        : FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDateTime(alert.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (!alert.isRead)
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: AppTheme.errorColor,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  /// Muestra un dialog con el código QR para vincular dispositivo
  void _showQRDialog(BuildContext context, Child child, bool isDark) {
    // Datos que irán en el QR
    final qrData = jsonEncode({
      'childId': child.id,
      'childName': child.fullName,
      'schoolId': child.schoolId,
    });

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF2a2a4a) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.qr_code_rounded,
                  color: AppTheme.primaryColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Flexible(
                child: Text(
                  'Vincular Dispositivo',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 280,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Instrucciones
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.infoColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: AppTheme.infoColor,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Escanea este código desde el celular de ${child.fullName}',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white70 : AppTheme.infoColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // QR Code
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
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
                    size: 180,
                    backgroundColor: Colors.white,
                    eyeStyle: QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: AppTheme.primaryColor,
                    ),
                    dataModuleStyle: QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Nombre del hijo
                Text(
                  child.fullName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cerrar',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
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
