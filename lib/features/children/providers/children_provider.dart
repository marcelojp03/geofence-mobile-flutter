import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/children_repository.dart';
import '../domain/entities/entities.dart';

/// Provider del repositorio de children
final childrenRepositoryProvider = Provider<ChildrenRepository>((ref) {
  return ChildrenRepository();
});

/// Provider para obtener la lista de hijos del padre
final myChildrenProvider = FutureProvider<List<Child>>((ref) async {
  final repo = ref.read(childrenRepositoryProvider);
  final response = await repo.getMyChildren();

  if (response.success && response.data != null) {
    return response.data!;
  }

  throw Exception(response.message);
});

/// Provider para obtener el detalle de un hijo específico
final childDetailProvider = FutureProvider.family<Child, int>((
  ref,
  childId,
) async {
  final repo = ref.read(childrenRepositoryProvider);
  final response = await repo.getChildDetail(childId);

  if (response.success && response.data != null) {
    return response.data!;
  }

  throw Exception(response.message);
});

/// Provider para invalidar y refrescar la lista de hijos
final childrenRefreshProvider = Provider<void Function()>((ref) {
  return () {
    ref.invalidate(myChildrenProvider);
  };
});
