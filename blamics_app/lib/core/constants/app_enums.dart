import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum ImportanceLevel {
  critical,
  high,
  medium,
  low;

  Color get color {
    switch (this) {
      case ImportanceLevel.critical:
        return AppColors.importanceCritical;
      case ImportanceLevel.high:
        return AppColors.importanceHigh;
      case ImportanceLevel.medium:
        return AppColors.importanceMedium;
      case ImportanceLevel.low:
        return AppColors.importanceLow;
    }
  }

  String get label {
    switch (this) {
      case ImportanceLevel.critical:
        return 'CRITICAL';
      case ImportanceLevel.high:
        return 'HIGH';
      case ImportanceLevel.medium:
        return 'MEDIUM';
      case ImportanceLevel.low:
        return 'LOW';
    }
  }
}

enum IpoStatus {
  upcoming,
  open,
  closed,
  listed;

  String get label {
    switch (this) {
      case IpoStatus.upcoming:
        return 'UPCOMING';
      case IpoStatus.open:
        return 'OPEN';
      case IpoStatus.closed:
        return 'CLOSED';
      case IpoStatus.listed:
        return 'LISTED';
    }
  }

  Color get color {
    switch (this) {
      case IpoStatus.upcoming:
        return AppColors.warning;
      case IpoStatus.open:
        return AppColors.success;
      case IpoStatus.closed:
        return AppColors.textSecondary;
      case IpoStatus.listed:
        return AppColors.primary;
    }
  }
}

enum EventType {
  ipo,
  dividend,
  bonus,
  split,
  rights,
  buyback,
  earnings;

  String get label {
    switch (this) {
      case EventType.ipo:
        return 'IPO';
      case EventType.dividend:
        return 'DIVIDEND';
      case EventType.bonus:
        return 'BONUS';
      case EventType.split:
        return 'SPLIT';
      case EventType.rights:
        return 'RIGHTS';
      case EventType.buyback:
        return 'BUYBACK';
      case EventType.earnings:
        return 'EARNINGS';
    }
  }
}
