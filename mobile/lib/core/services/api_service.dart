import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../error/result.dart';
import '../error/failures.dart';
import '../models/timeline_event.dart';
import '../../features/ipo/models/ipo_model.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:8000/api/v1', // Emulator localhost
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
    ),
  );
  return dio;
});

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(ref.watch(dioProvider));
});

class ApiService {
  ApiService(this._dio);
  final Dio _dio;

  Future<Result<List<TimelineEvent>>> getTimelineEvents() async {
    try {
      final response = await _dio.get('/events/timeline');
      final dataList = response.data['data'] as List<dynamic>;
      final events = dataList
          .map((e) => TimelineEvent.fromJson(e as Map<String, dynamic>))
          .toList();
      return Success(events);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout || 
          e.type == DioExceptionType.receiveTimeout) {
        return const Err(TimeoutFailure());
      }
      return Err(ServerFailure(e.response?.statusCode ?? 500, e.message ?? 'Server error'));
    } catch (e) {
      return Err(UnexpectedFailure(e));
    }
  }

  Future<Result<List<IpoModel>>> getIpos() async {
    try {
      final response = await _dio.get('/ipos');
      final dataList = response.data['data'] as List<dynamic>;
      final ipos = dataList
          .map((e) => IpoModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Success(ipos);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout || 
          e.type == DioExceptionType.receiveTimeout) {
        return const Err(TimeoutFailure());
      }
      return Err(ServerFailure(e.response?.statusCode ?? 500, e.message ?? 'Server error'));
    } catch (e) {
      return Err(UnexpectedFailure(e));
    }
  }
}
