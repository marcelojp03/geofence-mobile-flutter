import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/schools_repository.dart';
import '../../auth/domain/entities/school.dart';
import '../../auth/providers/auth_provider.dart';

/// Provider del repositorio de colegios
final schoolsRepositoryProvider = Provider((ref) => SchoolsRepository());

/// Provider para obtener el geofence del colegio del usuario actual
final currentSchoolGeofenceProvider = FutureProvider<School?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  final repo = ref.read(schoolsRepositoryProvider);
  final result = await repo.getSchoolGeofence(user.schoolId);

  if (result.success && result.data != null) {
    return result.data;
  }

  return null;
});

/// Provider para obtener el geofence de un colegio específico
final schoolGeofenceProvider = FutureProvider.family<School?, int>((
  ref,
  schoolId,
) async {
  final repo = ref.read(schoolsRepositoryProvider);
  final result = await repo.getSchoolGeofence(schoolId);

  if (result.success && result.data != null) {
    return result.data;
  }

  return null;
});

/// Provider para obtener todos los colegios con geofences
final schoolsWithGeofencesProvider = FutureProvider<List<School>>((ref) async {
  final repo = ref.read(schoolsRepositoryProvider);
  final result = await repo.getSchoolsWithGeofences();

  if (result.success && result.data != null) {
    return result.data!;
  }

  return [];
});
