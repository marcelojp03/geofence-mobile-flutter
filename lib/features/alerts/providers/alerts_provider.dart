import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;
import '../data/alerts_repository.dart';
import '../domain/entities/alert.dart';

/// Provider del repositorio de alertas
final alertsRepositoryProvider = Provider<AlertsRepository>((ref) {
  return AlertsRepository();
});

/// Provider para obtener todas las alertas del padre
final myAlertsProvider = FutureProvider<List<Alert>>((ref) async {
  try {
    final repo = ref.read(alertsRepositoryProvider);
    final response = await repo.getMyAlerts();

    if (response.success && response.data != null) {
      return response.data!;
    }

    developer.log(
      'myAlertsProvider: ${response.message}',
      name: 'AlertsProvider',
    );
    return [];
  } catch (e) {
    developer.log('myAlertsProvider error: $e', name: 'AlertsProvider');
    return [];
  }
});

/// Provider para obtener solo alertas no leídas
final unreadAlertsProvider = FutureProvider<List<Alert>>((ref) async {
  try {
    final repo = ref.read(alertsRepositoryProvider);
    final response = await repo.getMyAlerts(isRead: false);

    if (response.success && response.data != null) {
      return response.data!;
    }

    return [];
  } catch (e) {
    developer.log('unreadAlertsProvider error: $e', name: 'AlertsProvider');
    return [];
  }
});

/// Provider para obtener el conteo de alertas no leídas
final unreadAlertsCountProvider = FutureProvider<int>((ref) async {
  try {
    final repo = ref.read(alertsRepositoryProvider);
    final response = await repo.getUnreadCount();

    if (response.success && response.data != null) {
      return response.data!;
    }

    return 0;
  } catch (e) {
    developer.log(
      'unreadAlertsCountProvider error: $e',
      name: 'AlertsProvider',
    );
    return 0;
  }
});

/// Provider para alertas de un hijo específico
final childAlertsProvider = FutureProvider.family<List<Alert>, int>((
  ref,
  childId,
) async {
  try {
    final repo = ref.read(alertsRepositoryProvider);
    final response = await repo.getAlertsByChild(childId);

    if (response.success && response.data != null) {
      return response.data!;
    }

    return [];
  } catch (e) {
    developer.log('childAlertsProvider error: $e', name: 'AlertsProvider');
    return [];
  }
});

/// Provider para refrescar alertas
final refreshAlertsProvider = Provider<void Function()>((ref) {
  return () {
    ref.invalidate(myAlertsProvider);
    ref.invalidate(unreadAlertsProvider);
    ref.invalidate(unreadAlertsCountProvider);
  };
});
