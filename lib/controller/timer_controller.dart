import 'dart:async';
import 'package:time_tracker/model/entry.dart';
import '../common.dart';

class TimerController {
  late int counter;
  late Timer periodic;
  late DateTime _start;
  late DateTime _stop;

  TimerController() {
    resetCounter();
  }

  start(getCounter) {
    _start = DateTime.now();
    periodic = Timer.periodic(const Duration(seconds: 1), (timer) {
      counter++;
      getCounter(counter);
    });
  }

  Entry stop() {
    periodic.cancel();
    _stop = DateTime.now();
    resetCounter();

    int diff = differenceToInt(_stop, _start);

    Entry entry = Entry();
    entry.start = hmsToString(_start);
    entry.stop = hmsToString(_stop);
    entry.seconds = diff;
    entry.date = ymdToString(_start);

    return entry;
  }

  resetCounter() {
    counter = 0;
  }
}
