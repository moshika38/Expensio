import 'package:intl/intl.dart';

class AppDateUtils {
  static final DateFormat _shortDateFormatter = DateFormat('MMM dd, yyyy');
  static final DateFormat _monthYearFormatter = DateFormat('MMMM yyyy');
  static final DateFormat _dayNameFormatter = DateFormat('EEE, MMM dd');

  static String formatDate(DateTime date) {
    return _shortDateFormatter.format(date);
  }

  static String formatMonthYear(DateTime date) {
    return _monthYearFormatter.format(date);
  }

  static String formatDayName(DateTime date) {
    return _dayNameFormatter.format(date);
  }

  static bool isSameMonth(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month;
  }

  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  static String getRelativeDateString(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    final difference = today.difference(targetDate).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7 && difference > 0) {
      return DateFormat('EEEE').format(date);
    } else {
      return formatDate(date);
    }
  }
}
