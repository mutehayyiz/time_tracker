import 'package:intl/intl.dart';

DateTime ymdToDate(String string) {
  return DateFormat("yyyy/MM/dd").parse(string);
}

String ymdToString(DateTime date) {
  return DateFormat("yyyy/MM/dd").format(date);
}

String getFormatted(DateTime date) {
  return DateFormat.yMMMEd().format(date);
}

String toHMS(int i) {
  Duration diff = Duration(seconds: i);
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String twoDigitMinutes = twoDigits(diff.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(diff.inSeconds.remainder(60));
  return "${twoDigits(diff.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
}

String hmsToString(DateTime date) {
  return DateFormat("HH:mm:ss").format(date);
}

int differenceToInt(DateTime from, DateTime other) {
  return from.difference(other).inSeconds;
}