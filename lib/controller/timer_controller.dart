import 'dart:async';

import 'package:intl/intl.dart';
import 'package:time_tracker/model/entry.dart';

class TimerController {
  late int counter;
  late Timer periodic;
  late DateTime started_at;
  late DateTime stopped_at;

  TimerController() {
    resetCounter();
  }

  start(getCounter) {
    started_at = DateTime.now();
    periodic = Timer.periodic(const Duration(seconds: 1), (timer) {
      counter ++ ;
      getCounter(counter);
    });
  }

  Entry stop() {
    periodic.cancel();
    stopped_at = DateTime.now();
    resetCounter();

    int diff = differenceToInt(stopped_at, started_at);

    Entry entry = Entry();
    entry.start = hmsToString(started_at);
    entry.stop = hmsToString(stopped_at);
    entry.diff = diff;
    entry.date = mdyToString(started_at);

    return entry;
  }

  resetCounter() {
    counter = 0;
  }

  String mdyToString(DateTime date) {
    return DateFormat.yMd().format(date);
  }

  String hmsToString(DateTime date) {
    return DateFormat("HH:mm:ss").format(date);
  }

  int differenceToInt(DateTime from, DateTime other) {
    return from.difference(other).inSeconds;
  }

}