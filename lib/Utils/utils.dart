import 'package:intl/intl.dart';

String formatUnixTime(DateTime dateTime) {
  final DateFormat formatter = DateFormat('HH:mm');
  return formatter.format(dateTime);
}
