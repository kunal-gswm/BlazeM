import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

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

// ── Raw Data Providers ──────────────────────────────────────────────────────

final ipoDataProvider = FutureProvider<ApiResponse<IpoModel>>((ref) async {
  final repo = ref.watch(blamicsRepositoryProvider);
  return repo.getIpos();
});

final fiiDiiDataProvider = FutureProvider<ApiResponse<FiiDiiModel>>((ref) async {
  final repo = ref.watch(blamicsRepositoryProvider);
  return repo.getFiiDii();
});

final corporateActionsProvider =
    FutureProvider<ApiResponse<CorporateActionModel>>((ref) async {
  final repo = ref.watch(blamicsRepositoryProvider);
  return repo.getCorporateActions();
});

final globalIndicesProvider =
    FutureProvider<ApiResponse<GlobalIndexModel>>((ref) async {
  final repo = ref.watch(blamicsRepositoryProvider);
  return repo.getGlobalIndices();
});

final marketBreadthProvider =
    FutureProvider<ApiResponse<MarketBreadthModel>>((ref) async {
  final repo = ref.watch(blamicsRepositoryProvider);
  return repo.getMarketBreadth();
});

final earningsCalendarProvider =
    FutureProvider<ApiResponse<EarningsCalendarModel>>((ref) async {
  final repo = ref.watch(blamicsRepositoryProvider);
  return repo.getEarningsCalendar();
});

final sectorPerformanceProvider =
    FutureProvider<ApiResponse<SectorModel>>((ref) async {
  final repo = ref.watch(blamicsRepositoryProvider);
  return repo.getSectorPerformance();
});

final marketSentimentProvider =
    FutureProvider<ApiResponse<MarketSentimentModel>>((ref) async {
  final repo = ref.watch(blamicsRepositoryProvider);
  return repo.getMarketSentiment();
});

final highLowProvider =
    FutureProvider<ApiResponse<HighLowModel>>((ref) async {
  final repo = ref.watch(blamicsRepositoryProvider);
  return repo.getHighLow();
});

final healthStatusProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repo = ref.watch(blamicsRepositoryProvider);
  return repo.getHealthStatus();
});

// ── Computed Providers ──────────────────────────────────────────────────────

/// Parse a date string like "03 Jul 2026" into a DateTime.
DateTime? _parseDate(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) return null;
  try {
    return DateFormat('dd MMMM yyyy').parse(dateStr);
  } catch (_) {
    try {
      return DateFormat('dd MMM yyyy').parse(dateStr);
    } catch (_) {
      try {
        return DateTime.parse(dateStr);
      } catch (_) {
        return null;
      }
    }
  }
}

/// Timeline events happening today.
final criticalTodayProvider =
    FutureProvider<List<TimelineEvent>>((ref) async {
  final events = await ref.watch(timelineEventsProvider.future);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  return events.where((event) {
    if (event.parsedDate == null) return false;
    return DateTime(event.parsedDate!.year, event.parsedDate!.month, event.parsedDate!.day) == today;
  }).toList();
});

/// Timeline events in the next 7 days (excluding today).
final upcoming7DaysProvider =
    FutureProvider<List<TimelineEvent>>((ref) async {
  final events = await ref.watch(timelineEventsProvider.future);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final weekOut = today.add(const Duration(days: 7));

  return events.where((event) {
    if (event.parsedDate == null) return false;
    final d = DateTime(event.parsedDate!.year, event.parsedDate!.month, event.parsedDate!.day);
    return d.isAfter(today) && !d.isAfter(weekOut);
  }).toList();
});

/// Filtered corporate actions by type.
final filteredCorporateActionsProvider =
    FutureProvider.family<List<CorporateActionModel>, String>(
        (ref, actionType) async {
  final response = await ref.watch(corporateActionsProvider.future);
  if (actionType == 'All') return response.data;
  return response.data
      .where((a) => a.actionType.toLowerCase() == actionType.toLowerCase())
      .toList();
});

/// All events aggregated for timeline, sorted by importance then date.
final timelineEventsProvider =
    FutureProvider<List<TimelineEvent>>((ref) async {
  final corpActions = await ref.watch(corporateActionsProvider.future);
  final earnings = await ref.watch(earningsCalendarProvider.future);

  final events = <TimelineEvent>[];

  // Add corporate actions
  for (final action in corpActions.data) {
    events.add(TimelineEvent(
      title: action.cleanPurpose,
      entity: action.shortName,
      date: action.exDate,
      parsedDate: _parseDate(action.exDate),
      eventType: action.actionType,
      source: 'BSE',
      dividendAmount: action.dividendAmount,
    ));
  }

  // Add earnings
  for (final earning in earnings.data) {
    events.add(TimelineEvent(
      title: 'Board Meeting',
      entity: earning.shortName,
      date: earning.meetingDate,
      parsedDate: _parseDate(earning.meetingDate),
      eventType: 'Earnings',
      source: 'BSE',
    ));
  }

  // Sort by importance (Critical > High > Medium > Low), then by date
  events.sort((a, b) {
    final importanceComparison =
        a.importanceIndex.compareTo(b.importanceIndex);
    if (importanceComparison != 0) return importanceComparison;
    if (a.parsedDate == null && b.parsedDate == null) return 0;
    if (a.parsedDate == null) return 1;
    if (b.parsedDate == null) return -1;
    return a.parsedDate!.compareTo(b.parsedDate!);
  });

  return events;
});

/// Unified timeline event model.
class TimelineEvent {
  final String title;
  final String entity;
  final String? date;
  final DateTime? parsedDate;
  final String eventType;
  final String source;
  final double? dividendAmount;

  TimelineEvent({
    required this.title,
    required this.entity,
    this.date,
    this.parsedDate,
    required this.eventType,
    required this.source,
    this.dividendAmount,
  });

  /// Importance based on proximity to today.
  int get importanceIndex {
    if (parsedDate == null) return 3; // Low
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(parsedDate!.year, parsedDate!.month, parsedDate!.day);
    final diff = d.difference(today).inDays;

    if (diff == 0) return 0; // Critical — today
    if (diff == 1) return 1; // High — tomorrow
    if (diff <= 7) return 2; // Medium — this week
    return 3; // Low
  }

  String get dateLabel {
    if (parsedDate == null) return 'TBA';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(parsedDate!.year, parsedDate!.month, parsedDate!.day);
    final diff = d.difference(today).inDays;

    if (diff == 0) return 'TODAY';
    if (diff == 1) return 'TOMORROW';
    return DateFormat('dd MMMM yyyy').format(parsedDate!).toUpperCase();
  }
}
