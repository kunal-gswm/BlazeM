import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/data_state.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/cache_service.dart';
import '../models/ipo_model.dart';

final ipoListProvider = FutureProvider<DataState<List<IpoModel>>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  final cacheService = ref.watch(cacheServiceProvider);
  
  final result = await apiService.getIpos();
  
  return result.when(
    success: (ipos) => DataState.fresh(ipos, DateTime.now()),
    failure: (failure) async {
      final cachedIpos = await cacheService.getIpos();
      if (cachedIpos != null && cachedIpos.isNotEmpty) {
        return DataState.stale(cachedIpos, DateTime.now().subtract(const Duration(hours: 2)));
      }
      return DataState.error(failure.toString());
    },
  );
});

// For individual IPO detail
final ipoDetailProvider = FutureProvider.family<DataState<IpoModel>, String>((ref, id) async {
  final apiService = ref.watch(apiServiceProvider);
  final cacheService = ref.watch(cacheServiceProvider);
  
  final result = await apiService.getIpos();
  
  return result.when(
    success: (ipos) {
      final ipo = ipos.firstWhere((e) => e.id == id);
      return DataState.fresh(ipo, DateTime.now());
    },
    failure: (failure) async {
      final cachedIpos = await cacheService.getIpos();
      if (cachedIpos != null && cachedIpos.isNotEmpty) {
        final ipo = cachedIpos.firstWhere((e) => e.id == id);
        return DataState.stale(ipo, DateTime.now().subtract(const Duration(hours: 2)));
      }
      return DataState.error(failure.toString());
    },
  );
});
