import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/api_response.dart';
import '../models/ipo_model.dart';
import '../models/fii_dii_model.dart';
import '../models/corporate_action_model.dart';
import '../models/global_index_model.dart';
import 'blamics_repository.dart';

final dioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));
});

final cacheBoxProvider = Provider<Box>((ref) {
  return Hive.box('blamics_cache');
});

final blamicsRepositoryProvider = Provider<BlamicsRepository>((ref) {
  return BlamicsRepository(
    ref.watch(dioProvider),
    ref.watch(cacheBoxProvider),
  );
});

// Async Data Providers
final ipoDataProvider = FutureProvider<ApiResponse<IpoModel>>((ref) async {
  final repo = ref.watch(blamicsRepositoryProvider);
  return repo.getIpos();
});

final fiiDiiDataProvider = FutureProvider<ApiResponse<FiiDiiModel>>((ref) async {
  final repo = ref.watch(blamicsRepositoryProvider);
  return repo.getFiiDii();
});

final corporateActionsProvider = FutureProvider<ApiResponse<CorporateActionModel>>((ref) async {
  final repo = ref.watch(blamicsRepositoryProvider);
  return repo.getCorporateActions();
});

final globalIndicesProvider = FutureProvider<ApiResponse<GlobalIndexModel>>((ref) async {
  final repo = ref.watch(blamicsRepositoryProvider);
  return repo.getGlobalIndices();
});
