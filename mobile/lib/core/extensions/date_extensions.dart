import 'package:intl/intl.dart';

/// Date formatting extensions for market event display.
extension DateTimeExtensions on DateTime {
  /// "21 Jun 2026"
  String get formatted => DateFormat('d MMM y').format(this);

  /// "21 Jun"
  String get shortFormatted => DateFormat('d MMM').format(this);

  /// "Sat, 21 Jun 2026"
  String get fullFormatted => DateFormat('E, d MMM y').format(this);

  /// "2 days ago", "in 3 hours", etc.
  String get relative {
    final now = DateTime.now();
    final diff = now.difference(this);

    if (diff.isNegative) {
      // Future
      final absDiff = diff.abs();
      if (absDiff.inMinutes < 60) return 'in ${absDiff.inMinutes}m';
      if (absDiff.inHours < 24) return 'in ${absDiff.inHours}h';
      if (absDiff.inDays == 1) return 'Tomorrow';
      return 'in ${absDiff.inDays}d';
    } else {
      // Past
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays == 1) return 'Yesterday';
      return '${diff.inDays}d ago';
    }
  }

  /// Whether this date is today.
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Whether this date is tomorrow.
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }
}
