import 'package:flutter/foundation.dart';

/// Returns e.g. "Sunday, October 25th, 2025"
String formatLongDate(DateTime dt) {
  const weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return '${weekdays[(dt.weekday - 1) % 7]}, '
      '${months[dt.month - 1]} ${_ordinal(dt.day)}, ${dt.year}';
}

/// Returns e.g. "Oct 25th"
String formatShortDate(DateTime dt) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[dt.month - 1]} ${_ordinal(dt.day)}';
}

/// Returns e.g. "5:00 PM"
String formatTime(DateTime dt) {
  final h12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final m = dt.minute.toString().padLeft(2, '0');
  final ap = dt.hour < 12 ? 'AM' : 'PM';
  return '$h12:$m $ap';
}

/// Returns e.g. "Oct 25th, 5:00 PM" — nice for cards
String formatCardDateTime(DateTime dt) =>
    '${formatShortDate(dt)}, ${formatTime(dt)}';

/// Truncate to midnight for calendar day keys
DateTime truncateToDay(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

/// 1 -> 1st, 2 -> 2nd, 3 -> 3rd, 4 -> 4th...
String _ordinal(int n) {
  if (n >= 11 && n <= 13) return '${n}th';
  switch (n % 10) {
    case 1:
      return '${n}st';
    case 2:
      return '${n}nd';
    case 3:
      return '${n}rd';
    default:
      return '${n}th';
  }
}
