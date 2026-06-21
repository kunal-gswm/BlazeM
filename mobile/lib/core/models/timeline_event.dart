import 'source_meta.dart';

/// The type of market event.
enum EventType {
  // IPO lifecycle
  ipoOpen,
  ipoClose,
  ipoAllotment,
  ipoListing,

  // Dividends
  dividendEx,
  dividendRecord,
  dividendPayment,

  // Bonus
  bonusEx,
  bonusRecord,

  // Stock split
  splitEx,
  splitRecord,

  // Rights issue
  rightsOpen,
  rightsClose,

  // Bonds
  bondOpen,
  bondClose,

  // News
  newsPublished,
}

/// The entity that generated the event.
enum EntityType {
  ipo,
  corporateAction,
  bond,
  news,
  event,
}

/// Current status of an event.
enum EventStatus {
  upcoming,
  active,
  completed,
  cancelled,
  withdrawn,
  changed,
}

/// Importance level for dashboard ranking.
///
/// Used to sort "Today's Events" and similar views.
/// Higher value = more important.
enum EventImportance {
  /// Informational, no urgency (e.g., dividend record date next month).
  low(25),

  /// Worth knowing about (e.g., bond opens next week).
  medium(50),

  /// Action may be needed soon (e.g., IPO opens tomorrow).
  high(75),

  /// Deadline today or imminent (e.g., IPO closes today, rights issue ends).
  critical(100);

  const EventImportance(this.value);
  final int value;
}

/// Normalized event model.
///
/// The entire app is event-first. Every IPO date, dividend ex-date,
/// bond closing — everything becomes a TimelineEvent.
///
/// Dashboard, watchlist, search, upcoming events — all consume this.
class TimelineEvent {
  const TimelineEvent({
    required this.id,
    required this.eventType,
    required this.entityType,
    required this.entityId,
    required this.title,
    required this.date,
    required this.status,
    required this.importance,
    required this.importanceScore,
    required this.meta,
    this.subtitle,
  });

  final String id;
  final EventType eventType;
  final EntityType entityType;
  final String entityId;
  final String title;
  final String? subtitle;
  final DateTime date;
  final EventStatus status;
  final EventImportance importance;
  final int importanceScore;
  final SourceMeta meta;

  factory TimelineEvent.fromJson(Map<String, dynamic> json) {
    return TimelineEvent(
      id: json['id'] as String,
      eventType: EventType.values.byName(json['event_type'] as String),
      entityType: EntityType.values.byName(json['entity_type'] as String),
      entityId: json['entity_id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      date: DateTime.parse(json['date'] as String),
      status: EventStatus.values.byName(json['status'] as String),
      importance: EventImportance.values.byName(json['importance'] as String),
      importanceScore: json['importance_score'] as int? ?? 0,
      meta: SourceMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_type': eventType.name,
      'entity_type': entityType.name,
      'entity_id': entityId,
      'title': title,
      'subtitle': subtitle,
      'date': date.toIso8601String(),
      'status': status.name,
      'importance': importance.name,
      'importance_score': importanceScore,
      'meta': meta.toJson(),
    };
  }
}
