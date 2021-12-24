import 'dart:async';

import 'package:intl/intl.dart';
import 'package:time_tracker/model/entry.dart';

import '../common.dart';

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
    entry.seconds = diff;
    entry.date = ymdToString(started_at);

    return entry;
  }

  resetCounter() {
    counter = 0;
  }

}