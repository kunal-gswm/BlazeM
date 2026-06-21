import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/data_state.dart';
import '../../../core/services/api_service.dart';
import '../models/ipo_model.dart';

final ipoListProvider = FutureProvider<DataState<List<IpoModel>>>((ref) async {
  final service = ref.watch(apiServiceProvider);
  final result = await service.getIpos();
  
  return result.when(
    success: (ipos) => DataState.fresh(ipos, DateTime.now()),
    failure: (failure) => DataState.error(failure.message),
  );
});

// For individual IPO detail
final ipoDetailProvider = FutureProvider.family<DataState<IpoModel>, String>((ref, id) async {
  final service = ref.watch(apiServiceProvider);
  final result = await service.getIpos();
  
  return result.when(
    success: (ipos) {
      final ipo = ipos.firstWhere((i) => i.id == id, orElse: () => throw Exception('Not found'));
      return DataState.fresh(ipo, DateTime.now());
    },
    failure: (failure) => DataState.error(failure.message),
  );
});
