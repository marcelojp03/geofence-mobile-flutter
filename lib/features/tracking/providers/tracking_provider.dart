import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;
import '../data/tracking_repository.dart';
import '../domain/entities/position.dart';

/// Provider del repositorio de tracking
final trackingRepositoryProvider = Provider<TrackingRepository>((ref) {
  return TrackingRepository();
});

/// Provider para obtener la última posición de un hijo
final childLastPositionProvider = FutureProvider.family<Position?, int>((
  ref,
  childId,
) async {
  try {
    final repo = ref.read(trackingRepositoryProvider);
    final response = await repo.getChildLastPosition(childId);

    if (response.success && response.data != null) {
      return response.data!;
    }

    // Si no hay posición (404), retornamos null
    developer.log(
      'No position for child $childId: ${response.message}',
      name: 'TrackingProvider',
    );
    return null;
  } catch (e) {
    developer.log('Error getting position: $e', name: 'TrackingProvider');
    return null;
  }
});

/// Provider para obtener el historial de posiciones de un hijo
final childPositionHistoryProvider = FutureProvider.family<List<Position>, int>(
  (ref, childId) async {
    try {
      final repo = ref.read(trackingRepositoryProvider);
      final response = await repo.getChildPositionHistory(childId, limit: 50);

      if (response.success && response.data != null) {
        return response.data!;
      }

      return [];
    } catch (e) {
      developer.log('Error getting history: $e', name: 'TrackingProvider');
      return [];
    }
  },
);

/// Provider para refrescar la posición de un hijo
final refreshChildPositionProvider = Provider.family<void Function(), int>((
  ref,
  childId,
) {
  return () {
    ref.invalidate(childLastPositionProvider(childId));
  };
});
