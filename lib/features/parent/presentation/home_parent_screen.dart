import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/providers/theme_notifier.dart';
import '../../children/providers/children_provider.dart';
import '../../children/domain/entities/entities.dart';
import '../../alerts/providers/alerts_provider.dart';
import '../../auth/providers/auth_provider.dart';

/// Pantalla principal del modo padre
class HomeParentScreen extends ConsumerStatefulWidget {
  static const String name = 'parent';

  const HomeParentScreen({super.key});

  @override
  ConsumerState<HomeParentScreen> createState() => _HomeParentScreenState();
}

class _HomeParentScreenState extends ConsumerState<HomeParentScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final unreadCount = ref.watch(unreadAlertsCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('GeoKids'),
        automaticallyImplyLeading: false,
        actions: [
          // Badge de notificaciones
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
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
                      decoration: const BoxDecoration(
                        color: Colors.red,
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
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            onPressed: () {
              ref.read(themeNotifierProvider.notifier).toggleDarkMode();
            },
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          const NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Mapa',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible:
                  unreadCount.valueOrNull != null &&
                  unreadCount.valueOrNull! > 0,
              label: Text('${unreadCount.valueOrNull ?? 0}'),
              child: const Icon(Icons.notifications_outlined),
            ),
            selectedIcon: const Icon(Icons.notifications),
            label: 'Alertas',
          ),
          const NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
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
    final childrenAsync = ref.watch(myChildrenProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(myChildrenProvider);
        ref.invalidate(unreadAlertsCountProvider);
      },
      child: childrenAsync.when(
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
                  onPressed: () => ref.invalidate(myChildrenProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
        data: (children) {
          if (children.isEmpty) {
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
              _buildSummaryCard(children),

              const SizedBox(height: 24),

              Text(
                'Mis Hijos (${children.length})',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              // Lista de hijos
              ...children.map(
                (child) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildChildCard(child),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(List<Child> children) {
    // Contar estados basados en la última actividad de dispositivos
    int withSignal = 0;
    int noSignal = 0;

    for (final child in children) {
      if (child.devices != null && child.devices!.isNotEmpty) {
        final device = child.devices!.first;
        if (device.lastSeen != null) {
          final diff = DateTime.now().difference(device.lastSeen!);
          if (diff.inMinutes < 10) {
            withSignal++;
          } else {
            noSignal++;
          }
        } else {
          noSignal++;
        }
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
              '${children.length}',
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

  Widget _buildChildCard(Child child) {
    final device = child.devices?.isNotEmpty == true
        ? child.devices!.first
        : null;
    final lastSeen = device?.lastSeen;
    final battery = device?.lastBatteryLevel;
    final isRecent =
        lastSeen != null && DateTime.now().difference(lastSeen).inMinutes < 10;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.push('/children/${child.id}');
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 28,
                backgroundColor: isRecent ? Colors.green : Colors.grey,
                child: Text(
                  child.fullName[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.fullName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      child.grade,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Estado de señal
                        Icon(
                          isRecent
                              ? Icons.signal_cellular_alt
                              : Icons.signal_cellular_off,
                          size: 16,
                          color: isRecent ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          lastSeen != null
                              ? _formatLastSeen(lastSeen)
                              : 'Sin conexión',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),

                        if (battery != null) ...[
                          const SizedBox(width: 16),
                          Icon(
                            _getBatteryIcon(battery),
                            size: 16,
                            color: battery > 20 ? Colors.grey : Colors.red,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$battery%',
                            style: TextStyle(
                              fontSize: 12,
                              color: battery > 20
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
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Mapa General',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Próximamente: ver todos los hijos en el mapa',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
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
              context.go('/login');
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
