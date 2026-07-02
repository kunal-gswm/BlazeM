import 'package:timezone/timezone.dart' as tz;
import '../../data/models/ipo_model.dart';
import '../constants/app_enums.dart';

class IpoStatusHelper {
  // Helper to determine status based on live dates
  static IpoStatus determineStatus(IpoModel ipo) {
    final ist = tz.getLocation('Asia/Kolkata');
    final nowIst = tz.TZDateTime.now(ist);
    
    DateTime? parseDate(String? dateStr) {
      if (dateStr == null || dateStr.isEmpty) return null;
      try {
        return DateTime.parse(dateStr);
      } catch (e) {
        return null;
      }
    }

    final today = DateTime(nowIst.year, nowIst.month, nowIst.day);
    
    final listingDate = parseDate(ipo.listingDateRaw);
    final closeDate = parseDate(ipo.issueCloseRaw);
    final openDate = parseDate(ipo.issueOpenRaw);
    
    if (listingDate != null && (listingDate.isBefore(today) || listingDate.isAtSameMomentAs(today))) {
      return IpoStatus.listed;
    }
    
    if (closeDate != null) {
      if (closeDate.isBefore(today)) {
        return IpoStatus.closed;
      } else if (closeDate.isAtSameMomentAs(today)) {
        // Closes at 5:00 PM IST
        if (nowIst.hour >= 17) {
          return IpoStatus.closed;
        }
      }
    }
    
    if (openDate != null) {
      if (openDate.isBefore(today)) {
        // Must be open if before close date and after open date
        if (closeDate == null || closeDate.isAfter(today) || (closeDate.isAtSameMomentAs(today) && nowIst.hour < 17)) {
          return IpoStatus.open;
        }
      } else if (openDate.isAtSameMomentAs(today)) {
        // Opens at 10:00 AM IST
        if (nowIst.hour >= 10) {
          return IpoStatus.open;
        }
      }
    }
    
    return IpoStatus.upcoming;
  }
}
