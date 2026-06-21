import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/timeline_event.dart';
import '../../features/ipo/models/ipo_model.dart';

final cacheServiceProvider = Provider<CacheService>((ref) {
  return CacheService();
});

class CacheService {
  static const String _timelineKey = 'cache_timeline_events';
  static const String _iposKey = 'cache_ipos';

  Future<List<TimelineEvent>?> getTimelineEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_timelineKey);
    
    if (jsonStr != null) {
      final dataList = jsonDecode(jsonStr) as List<dynamic>;
      return dataList.map((e) => TimelineEvent.fromJson(e as Map<String, dynamic>)).toList();
    }
    
    // Fallback to seed data so the user always sees something on first install
    try {
      final String jsonString = await rootBundle.loadString('assets/data/seed_data.json');
      final Map<String, dynamic> data = jsonDecode(jsonString);
      final List<dynamic> eventsJson = data['timeline_events'];
      return eventsJson.map((e) => TimelineEvent.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> saveTimelineEvents(List<dynamic> jsonList) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_timelineKey, jsonEncode(jsonList));
  }

  Future<List<IpoModel>?> getIpos() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_iposKey);
    
    if (jsonStr != null) {
      final dataList = jsonDecode(jsonStr) as List<dynamic>;
      return dataList.map((e) => IpoModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    
    // Fallback to seed data
    try {
      final String jsonString = await rootBundle.loadString('assets/data/seed_data.json');
      final Map<String, dynamic> data = jsonDecode(jsonString);
      final List<dynamic> iposJson = data['ipos'];
      return iposJson.map((e) => IpoModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> saveIpos(List<dynamic> jsonList) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_iposKey, jsonEncode(jsonList));
  }
}
