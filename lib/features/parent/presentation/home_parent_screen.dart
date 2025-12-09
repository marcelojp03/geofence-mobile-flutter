import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:ui' as ui;
import '../../../config/theme/app_theme.dart';
import '../../../shared/providers/theme_notifier.dart';
import '../../children/providers/children_provider.dart';
import '../../children/domain/entities/entities.dart';
import '../../alerts/providers/alerts_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../tracking/providers/tracking_provider.dart';
import '../../tracking/domain/entities/child_current_location.dart';
import '../../notifications/providers/fcm_provider.dart';
import '../../schools/providers/schools_provider.dart';

/// Pantalla principal del modo padre
class HomeParentScreen extends ConsumerStatefulWidget {
  static const String name = 'parent';

  const HomeParentScreen({super.key});

  @override
  ConsumerState<HomeParentScreen> createState() => _HomeParentScreenState();
}

class _HomeParentScreenState extends ConsumerState<HomeParentScreen> {
  int _selectedIndex = 0;
  bool _fcmRegistered = false;

  @override
  void initState() {
    super.initState();
    // Registrar dispositivo del padre para notificaciones FCM
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _registerParentDevice();
    });
  }

  Future<void> _registerParentDevice() async {
    if (_fcmRegistered) return;
    _fcmRegistered = true;

    await ref
        .read(parentDeviceNotifierProvider.notifier)
        .registerParentDeviceForAllChildren();
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = ref.watch(unreadAlertsCountProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.asset(
                'assets/geofencing_logo.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.location_on_rounded,
                  size: 18,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Geofence',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        automaticallyImplyLeading: false,
        elevation: 0,
        scrolledUnderElevation: 2,
        backgroundColor: theme.scaffoldBackgroundColor,
        actions: [
          // Badge de notificaciones
          Stack(
            children: [
              IconButton(
                icon: Icon(
                  Icons.notifications_outlined,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                onPressed: () {
                  setState(() => _selectedIndex = 2);
                },
              ),
              unreadCount.when(
                data: (count) {
                  if (count == 0) return const SizedBox.shrink();
                  return Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        count > 9 ? '9+' : '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
          IconButton(
            icon: Icon(
              ref.watch(themeNotifierProvider)
                  ? Icons.dark_mode_outlined
                  : Icons.light_mode_outlined,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            onPressed: () {
              ref.read(themeNotifierProvider.notifier).toggleDarkMode();
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        elevation: 3,
        height: 70,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        indicatorColor: AppTheme.primaryColor.withValues(alpha: 0.12),
        destinations: [
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            selectedIcon: Icon(
              Icons.home_rounded,
              color: AppTheme.primaryColor,
            ),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.map_outlined,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            selectedIcon: Icon(Icons.map_rounded, color: AppTheme.primaryColor),
            label: 'Mapa',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible:
                  unreadCount.valueOrNull != null &&
                  unreadCount.valueOrNull! > 0,
              backgroundColor: AppTheme.errorColor,
              label: Text(
                '${unreadCount.valueOrNull ?? 0}',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: Icon(
                Icons.notifications_outlined,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            selectedIcon: Icon(
              Icons.notifications_rounded,
              color: AppTheme.primaryColor,
            ),
            label: 'Alertas',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.settings_outlined,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            selectedIcon: Icon(
              Icons.settings_rounded,
              color: AppTheme.primaryColor,
            ),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildMapTab();
      case 2:
        return _buildAlertsTab();
      case 3:
        return _buildSettingsTab();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    // Usar el provider de tracking que tiene info actualizada de deviceStatus/locationStatus
    final locationsAsync = ref.watch(childrenCurrentLocationsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(childrenCurrentLocationsProvider);
        ref.invalidate(unreadAlertsCountProvider);
      },
      child: locationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar datos',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () =>
                      ref.invalidate(childrenCurrentLocationsProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
        data: (locations) {
          if (locations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.child_care, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No tienes hijos registrados',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () {
                      // TODO: Navegar a pantalla para agregar hijo
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar Hijo'),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Resumen de estados
              _buildSummaryCardFromLocations(locations),

              const SizedBox(height: 24),

              Text(
                'Mis Hijos (${locations.length})',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              // Lista de hijos
              ...locations.map(
                (location) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildChildCardFromLocation(location),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryCardFromLocations(List<ChildCurrentLocation> locations) {
    // Contar estados basados en deviceStatus
    int withSignal = 0;
    int noSignal = 0;

    for (final location in locations) {
      // hasSignal es true si deviceStatus es online o recent
      if (location.hasSignal) {
        withSignal++;
      } else {
        noSignal++;
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatColumn(
              'Activos',
              '$withSignal',
              Colors.green,
              Icons.signal_cellular_alt,
            ),
            Container(width: 1, height: 50, color: Colors.grey[300]),
            _buildStatColumn(
              'Sin Señal',
              '$noSignal',
              Colors.orange,
              Icons.signal_cellular_off,
            ),
            Container(width: 1, height: 50, color: Colors.grey[300]),
            _buildStatColumn(
              'Total',
              '${locations.length}',
              Colors.blue,
              Icons.group,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildChildCardFromLocation(ChildCurrentLocation location) {
    // Determinar estado del niño basado en deviceStatus
    String statusText;
    Color statusColor;
    IconData statusIcon;

    switch (location.deviceStatus) {
      case DeviceStatus.online:
        statusText = 'En línea';
        statusColor = Colors.green;
        statusIcon = Icons.signal_cellular_alt;
        break;
      case DeviceStatus.recent:
        statusText = location.deviceStatusLabel; // "Hace Xmin"
        statusColor = Colors.green.shade700;
        statusIcon = Icons.signal_cellular_alt;
        break;
      case DeviceStatus.noSignal:
        statusText = 'Sin señal';
        statusColor = Colors.orange;
        statusIcon = Icons.signal_cellular_off;
        break;
      case DeviceStatus.noDevice:
        statusText = 'Sin dispositivo';
        statusColor = Colors.grey;
        statusIcon = Icons.device_unknown;
        break;
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.push('/children/${location.childId}');
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar con indicador de estado
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      location.fullName[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Indicador de estado (dot)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre y chip de estado
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            location.fullName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // Chip de estado
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(statusIcon, size: 12, color: statusColor),
                              const SizedBox(width: 4),
                              Text(
                                statusText,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Grado + ubicación
                    Row(
                      children: [
                        Text(
                          location.grade?.isNotEmpty == true
                              ? location.grade!
                              : 'Sin grado',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                        if (location.hasSignal) ...[
                          const SizedBox(width: 8),
                          Icon(
                            location.locationStatus == LocationStatus.inside
                                ? Icons.school
                                : Icons.location_off,
                            size: 14,
                            color:
                                location.locationStatus == LocationStatus.inside
                                ? Colors.green
                                : Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            location.locationStatusLabel,
                            style: TextStyle(
                              color:
                                  location.locationStatus ==
                                      LocationStatus.inside
                                  ? Colors.green
                                  : Colors.orange,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Info de última conexión y batería
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          location.timeAgo,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (location.batteryLevel != null) ...[
                          const SizedBox(width: 16),
                          Icon(
                            _getBatteryIcon(location.batteryLevel!),
                            size: 14,
                            color: location.batteryLevel! > 20
                                ? Colors.grey[500]
                                : Colors.red,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${location.batteryLevel}%',
                            style: TextStyle(
                              fontSize: 12,
                              color: location.batteryLevel! > 20
                                  ? Colors.grey[600]
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Flecha
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapTab() {
    final childrenAsync = ref.watch(myChildrenProvider);

    return childrenAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $e'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => ref.invalidate(myChildrenProvider),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
      data: (children) {
        if (children.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No hay hijos registrados',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return _ChildrenMapView(children: children);
      },
    );
  }

  Widget _buildAlertsTab() {
    final alertsAsync = ref.watch(myAlertsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(myAlertsProvider);
        ref.invalidate(unreadAlertsCountProvider);
      },
      child: alertsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (alerts) {
          if (alerts.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No hay alertas',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final alert = alerts[index];
              return _buildAlertCard(alert);
            },
          );
        },
      ),
    );
  }

  Widget _buildAlertCard(dynamic alert) {
    final isExit = alert.type.value == 'EXIT_AREA';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isExit ? Colors.orange : Colors.green,
          child: Icon(isExit ? Icons.logout : Icons.login, color: Colors.white),
        ),
        title: Text(
          alert.child?.fullName ?? 'Hijo',
          style: TextStyle(
            fontWeight: alert.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(alert.type.displayName),
            const SizedBox(height: 4),
            Text(
              _formatDateTime(alert.createdAt),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: !alert.isRead
            ? Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              )
            : null,
        onTap: () {
          if (alert.childId != null) {
            context.push('/children/${alert.childId}');
          }
        },
      ),
    );
  }

  Widget _buildSettingsTab() {
    final user = ref.watch(currentUserProvider);

    return ListView(
      children: [
        // Header con info del usuario
        Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  user?.fullName.isNotEmpty == true
                      ? user!.fullName[0].toUpperCase()
                      : 'U',
                  style: const TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                user?.fullName ?? 'Usuario',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                user?.email ?? '',
                style: TextStyle(color: Colors.grey[600]),
              ),
              if (user?.school != null) ...[
                const SizedBox(height: 4),
                Text(
                  user!.school!.name,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ],
          ),
        ),

        const Divider(),

        ListTile(
          leading: const Icon(Icons.person),
          title: const Text('Mi Perfil'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.child_care),
          title: const Text('Gestionar Hijos'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.devices),
          title: const Text('Dispositivos'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.notifications),
          title: const Text('Notificaciones'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),

        const Divider(),

        ListTile(
          leading: const Icon(Icons.help_outline),
          title: const Text('Ayuda'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('Acerca de'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),

        const Divider(),

        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text(
            'Cerrar Sesión',
            style: TextStyle(color: Colors.red),
          ),
          onTap: () => _showLogoutDialog(),
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authRepositoryProvider).logout();
              if (!mounted) return;
              context.go('/mode');
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }

  String _formatLastSeen(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inSeconds < 60) return 'Hace un momento';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours}h';
    return 'Hace ${diff.inDays}d';
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'Hace un momento';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} hora(s)';

    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  IconData _getBatteryIcon(int level) {
    if (level > 80) return Icons.battery_full;
    if (level > 60) return Icons.battery_5_bar;
    if (level > 40) return Icons.battery_4_bar;
    if (level > 20) return Icons.battery_2_bar;
    return Icons.battery_alert;
  }
}

/// Widget del mapa con todos los hijos
class _ChildrenMapView extends ConsumerStatefulWidget {
  final List<Child> children;

  const _ChildrenMapView({required this.children});

  @override
  ConsumerState<_ChildrenMapView> createState() => _ChildrenMapViewState();
}

class _ChildrenMapViewState extends ConsumerState<_ChildrenMapView> {
  final MapController _mapController = MapController();
  ChildCurrentLocation? _selectedLocation;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    // Auto-refresh cada 30 segundos
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        ref.invalidate(childrenCurrentLocationsProvider);
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
    // Obtener el geofence del colegio del usuario
    final schoolGeofenceAsync = ref.watch(currentSchoolGeofenceProvider);

    // Obtener ubicaciones actuales de todos los hijos (con info enriquecida del backend)
    final locationsAsync = ref.watch(childrenCurrentLocationsProvider);

    return locationsAsync.when(
      data: (locations) => _buildMap(context, locations, schoolGeofenceAsync),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildMap(
    BuildContext context,
    List<ChildCurrentLocation> locations,
    AsyncValue<dynamic> schoolGeofenceAsync,
  ) {
    final markers = <Marker>[];

    // Crear marcadores para cada hijo con ubicación
    for (final location in locations) {
      if (location.hasLocation) {
        // Color según el status del backend
        Color markerColor;
        switch (location.status) {
          case ChildLocationStatus.inside:
            markerColor = Colors.green;
            break;
          case ChildLocationStatus.outside:
            markerColor = Colors.orange;
            break;
          case ChildLocationStatus.noSignal:
            markerColor = Colors.grey;
            break;
        }

        markers.add(
          Marker(
            point: LatLng(location.lat!, location.lng!),
            width: 120,
            height: 60,
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedLocation = location);
                _showLocationInfo(location);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Nombre del hijo
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: markerColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      location.fullName.split(' ').first,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Flecha indicadora
                  CustomPaint(
                    size: const Size(12, 8),
                    painter: _TrianglePainter(color: markerColor),
                  ),
                  // Punto de ubicación
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: markerColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    // Crear mapa de childId -> location para acceso rápido
    final locationsMap = {for (var l in locations) l.childId: l};

    // Centro del mapa (promedio de posiciones o ubicación por defecto)
    LatLng center = const LatLng(-17.7833, -63.1821); // Santa Cruz, Bolivia
    double zoom = 13.0;

    final withLocation = locations.where((l) => l.hasLocation).toList();
    if (withLocation.isNotEmpty) {
      double avgLat = 0, avgLng = 0;
      for (final loc in withLocation) {
        avgLat += loc.lat!;
        avgLng += loc.lng!;
      }
      avgLat /= withLocation.length;
      avgLng /= withLocation.length;
      center = LatLng(avgLat, avgLng);

      // Ajustar zoom si hay múltiples marcadores
      if (withLocation.length > 1) {
        zoom = 14.0;
      } else {
        zoom = 16.0;
      }
    }

    final hasPositions = markers.isNotEmpty;

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
        // Mapa
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: center,
            initialZoom: zoom,
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
            // Capa de marcadores (ubicación de hijos)
            if (hasPositions) MarkerLayer(markers: markers),
          ],
        ),

        // Mensaje si no hay posiciones
        if (!hasPositions)
          Center(
            child: Container(
              margin: const EdgeInsets.all(32),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_off,
                    size: 48,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sin ubicaciones disponibles',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Los dispositivos de tus hijos aún no han enviado su ubicación',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () {
                      ref.invalidate(childrenCurrentLocationsProvider);
                    },
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Actualizar'),
                  ),
                ],
              ),
            ),
          ),

        // Leyenda
        Positioned(
          top: 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Geofence del colegio
                if (geofencePolygons.isNotEmpty) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.3),
                          border: Border.all(color: Colors.blue, width: 2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Zona escolar',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'En el colegio',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Fuera del colegio',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Sin señal',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Botón de refrescar
        Positioned(
          top: 16,
          right: 16,
          child: FloatingActionButton.small(
            heroTag: 'refresh_map',
            onPressed: () {
              // Invalidar todas las ubicaciones
              ref.invalidate(childrenCurrentLocationsProvider);
            },
            child: const Icon(Icons.refresh),
          ),
        ),

        // Botón de centrar
        if (hasPositions)
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton.small(
              heroTag: 'center_map',
              onPressed: () {
                _mapController.move(center, zoom);
              },
              child: const Icon(Icons.center_focus_strong),
            ),
          ),

        // Lista de hijos (chips) con status
        Positioned(
          bottom: 16,
          left: 16,
          right: 72,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: widget.children.map((child) {
                final location = locationsMap[child.id];
                final hasLocation = location?.hasLocation ?? false;
                final isSelected = _selectedLocation?.childId == child.id;

                // Color según status
                Color chipColor;
                if (location == null) {
                  chipColor = Colors.grey;
                } else {
                  switch (location.status) {
                    case ChildLocationStatus.inside:
                      chipColor = Colors.green;
                      break;
                    case ChildLocationStatus.outside:
                      chipColor = Colors.orange;
                      break;
                    case ChildLocationStatus.noSignal:
                      chipColor = Colors.grey;
                      break;
                  }
                }

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: isSelected,
                    avatar: CircleAvatar(
                      radius: 12,
                      backgroundColor: chipColor,
                      child: Text(
                        child.fullName[0],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    label: Text(
                      child.fullName.split(' ').first,
                      style: const TextStyle(fontSize: 12),
                    ),
                    onSelected: (selected) {
                      if (hasLocation && location != null) {
                        _mapController.move(
                          LatLng(location.lat!, location.lng!),
                          17,
                        );
                        setState(() => _selectedLocation = location);
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  void _showLocationInfo(ChildCurrentLocation location) {
    // Color según status
    Color statusColor;
    IconData statusIcon;
    switch (location.status) {
      case ChildLocationStatus.inside:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case ChildLocationStatus.outside:
        statusColor = Colors.orange;
        statusIcon = Icons.warning;
        break;
      case ChildLocationStatus.noSignal:
        statusColor = Colors.grey;
        statusIcon = Icons.signal_wifi_off;
        break;
    }

    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: statusColor,
                  child: Text(
                    location.fullName[0],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location.fullName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (location.grade != null)
                        Text(
                          location.grade!,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Status con icono
            Row(
              children: [
                Icon(statusIcon, color: statusColor),
                const SizedBox(width: 8),
                Text(
                  location.statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Última actualización
            Row(
              children: [
                const Icon(Icons.access_time, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Última actualización: ${location.timeAgo}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),

            // Batería
            if (location.batteryLevel != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    _getBatteryIcon(location.batteryLevel!),
                    size: 20,
                    color: location.batteryLevel! > 20
                        ? Colors.green
                        : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Batería: ${location.batteryLevel}%',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 24),

            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      // Ver historial del hijo
                      context.push('/parent/child/${location.childId}/history');
                    },
                    icon: const Icon(Icons.history),
                    label: const Text('Historial'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      // Centrar mapa en el hijo
                      if (location.hasLocation) {
                        _mapController.move(
                          LatLng(location.lat!, location.lng!),
                          17,
                        );
                      }
                    },
                    icon: const Icon(Icons.center_focus_strong),
                    label: const Text('Centrar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getBatteryIcon(int level) {
    if (level > 80) return Icons.battery_full;
    if (level > 60) return Icons.battery_5_bar;
    if (level > 40) return Icons.battery_4_bar;
    if (level > 20) return Icons.battery_2_bar;
    return Icons.battery_alert;
  }
}

/// Painter para el triángulo del marcador
class _TrianglePainter extends CustomPainter {
  final Color color;

  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = ui.Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
