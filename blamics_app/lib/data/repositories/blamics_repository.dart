import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/api_constants.dart';
import '../models/api_response.dart';
import '../models/ipo_model.dart';
import '../models/fii_dii_model.dart';
import '../models/corporate_action_model.dart';
import '../models/global_index_model.dart';
import '../models/market_breadth_model.dart';
import '../models/earnings_calendar_model.dart';
import '../models/sector_model.dart';
import '../models/market_sentiment_model.dart';
import '../models/high_low_model.dart';

class BlamicsRepository {
  final Dio _dio;
  final Box _cacheBox;

  BlamicsRepository(this._dio, this._cacheBox);

  Future<ApiResponse<T>> _fetchAndCache<T>(
    String url,
    String cacheKey,
    T Function(Map<String, dynamic>) fromJsonT,
  ) async {
    try {
      final response = await _dio.get(url);
      final jsonMap = response.data is String 
          ? const JsonDecoder().convert(response.data) as Map<String, dynamic>
          : response.data as Map<String, dynamic>;

      // Cache the raw JSON map
      await _cacheBox.put(cacheKey, jsonMap);

      return ApiResponse.fromJson(jsonMap, fromJsonT);
    } catch (e) {
      // On error, try to load from cache
      final cachedData = _cacheBox.get(cacheKey);
      if (cachedData != null) {
        final map = Map<String, dynamic>.from(cachedData);
        return ApiResponse.fromJson(map, fromJsonT);
      }
      rethrow;
    }
  }

  Future<ApiResponse<IpoModel>> getIpos() async {
    return _fetchAndCache<IpoModel>(
      ApiConstants.ipoData,
      'ipos_cache',
      (json) => IpoModel.fromJson(json),
    );
  }

  Future<ApiResponse<FiiDiiModel>> getFiiDii() async {
    return _fetchAndCache<FiiDiiModel>(
      ApiConstants.fiiDiiData,
      'fiidii_cache',
      (json) => FiiDiiModel.fromJson(json),
    );
  }

  Future<ApiResponse<CorporateActionModel>> getCorporateActions() async {
    return _fetchAndCache<CorporateActionModel>(
      ApiConstants.corporateActions,
      'corporate_cache',
      (json) => CorporateActionModel.fromJson(json),
    );
  }

  Future<ApiResponse<GlobalIndexModel>> getGlobalIndices() async {
    return _fetchAndCache<GlobalIndexModel>(
      ApiConstants.globalIndices,
      'indices_cache',
      (json) => GlobalIndexModel.fromJson(json),
    );
  }

  Future<ApiResponse<MarketBreadthModel>> getMarketBreadth() async {
    return _fetchAndCache<MarketBreadthModel>(
      ApiConstants.marketBreadth,
      'breadth_cache',
      (json) => MarketBreadthModel.fromJson(json),
    );
  }

  Future<ApiResponse<EarningsCalendarModel>> getEarningsCalendar() async {
    return _fetchAndCache<EarningsCalendarModel>(
      ApiConstants.earningsCalendar,
      'earnings_cache',
      (json) => EarningsCalendarModel.fromJson(json),
    );
  }

  Future<ApiResponse<SectorModel>> getSectorPerformance() async {
    return _fetchAndCache<SectorModel>(
      ApiConstants.sectorPerformance,
      'sector_cache',
      (json) => SectorModel.fromJson(json),
    );
  }

  Future<ApiResponse<MarketSentimentModel>> getMarketSentiment() async {
    return _fetchAndCache<MarketSentimentModel>(
      ApiConstants.marketSentiment,
      'sentiment_cache',
      (json) => MarketSentimentModel.fromJson(json),
    );
  }

  Future<ApiResponse<HighLowModel>> getHighLow() async {
    return _fetchAndCache<HighLowModel>(
      ApiConstants.highLow,
      'high_low_cache',
      (json) => HighLowModel.fromJson(json),
    );
  }
}
