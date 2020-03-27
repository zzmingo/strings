import 'package:flutter/foundation.dart';

class Debounce {

  final int milliseconds;

  int _lastMillis = 0;

  Debounce({ this.milliseconds });

  run(VoidCallback action) {
    var now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastMillis > milliseconds) {
      action();
      _lastMillis = now;
    }
  }

}