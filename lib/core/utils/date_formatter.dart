import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final DateFormat _time = DateFormat('h:mm a');
  static final DateFormat _dayMonth = DateFormat('d MMM');
  static final DateFormat _dayMonthYear = DateFormat('d MMM yyyy');

  static String relative(DateTime dateTime) {
    final now = DateTime.now();
    final local = dateTime.toLocal();
    final isToday =
        local.year == now.year &&
        local.month == now.month &&
        local.day == now.day;
    final yesterday = now.subtract(const Duration(days: 1));
    final isYesterday =
        local.year == yesterday.year &&
        local.month == yesterday.month &&
        local.day == yesterday.day;

    if (isToday) return 'Today, ${_time.format(local)}';
    if (isYesterday) return 'Yesterday, ${_time.format(local)}';
    if (local.year == now.year) return _dayMonth.format(local);
    return _dayMonthYear.format(local);
  }

  static String time(DateTime dateTime) => _time.format(dateTime.toLocal());

  static String date(DateTime dateTime) =>
      _dayMonthYear.format(dateTime.toLocal());
}
