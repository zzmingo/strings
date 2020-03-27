import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:strings/model/tuner.dart';


double _NOTE_FACTOR = pow(2, 1/12);

typedef PitchCallback = void Function(double pitch, double targetPitch);

class Tuner {

  static const pitchStream = const EventChannel('mingo.app_strings.events/patch');

  PitchHelper _pitchHelper;
  StreamSubscription _pitchSub;
  dynamic _widgetState;
  PitchCallback _pitchCallback;


  Tuner(this._widgetState, this._pitchCallback, VoidCallback idleCallback) {
    _pitchHelper = PitchHelper(idleCallback);
  }

  void dispose() {
    stop();
    _pitchHelper.dispose();
  }

  void start() {
    if (_pitchSub == null) {
      _pitchSub = pitchStream.receiveBroadcastStream().listen(_onNativePitch);
      _pitchHelper.reset();
    }
  }

  void stop() {
    if (_pitchSub != null) {
      _pitchSub.cancel();
      _pitchSub = null;
      _pitchHelper.reset();
    }
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        stop();
        break;
      case AppLifecycleState.resumed:
        start();
        break;
      default:
        break;
    }
  }

  void _onNativePitch(result) {
    var tunerModel = Provider.of<TunerModel>(_widgetState.context, listen: false);
    var acceptResult = _pitchHelper.acceptPitch(result, tunerModel);
    if (!acceptResult.accept) {
      return;
    }

    if (tunerModel.auto) {
      if (tunerModel.string != acceptResult.string) {
        _pitchHelper.reset();
        tunerModel.selectString(acceptResult.string);
        return;
      }
    }

    var capoPitch = tunerModel.selectedNote.pitch * pow(_NOTE_FACTOR, tunerModel.capo);
    var targetPitch = capoPitch;
    _pitchCallback(acceptResult.avgPitch, targetPitch);
  }

}

class PitchAcceptResult {
  bool accept;
  int string;
  double pitch;
  double avgPitch;
  int matches;
}

enum PitchRejectReason {
  SUCCESSFUL,
  FIRST_PITCH,
  SMALL_PROB,
  TS_TOO_LARGE,
  RMS_TOO_SMALL,
  UNEXPECTED_VAL,
  UNEXPECTED_STRING,
}

class PitchHelper {

  PitchAcceptResult _result;

  Timer _timer;

  int count = 0;
  int matches = 0;
  int continuousRms = 0;
  int continuousString = 0;
  int continuousPitch = 0;
  int lastTs = 0;
  int lastRms = 0;
  int lastString = -1;
  double lastPitch = 0;
  double lastAcceptPitch = 0;

  List<double> lastAcceptPitches = List<double>();

  int lastTimerTime = 0;
  bool updating = false;
  VoidCallback _idleCallback;

  PitchHelper(VoidCallback idleCallback) {
    _idleCallback = idleCallback;
    _result = PitchAcceptResult();
    _timer = Timer.periodic(Duration(milliseconds: 100), this._onTimerRun);
  }

  void dispose() {
    _timer.cancel();
    _idleCallback = null;
  }

  _onTimerRun(_) {
    var now = DateTime.now().millisecondsSinceEpoch;
    if (now - lastTimerTime > 2000) {
      if (updating) {
        updating = false;
        reset();
        if (_idleCallback != null) {
          _idleCallback();
        }
      }
    } else {
      if (!updating) {
        updating = true;
      }
    }
  }


  void reset() {
    count = 0;
    matches = 0;
    continuousRms = 0;
    continuousString = 0;
    continuousPitch = 0;
    lastTs = 0;
    lastRms = 0;
    lastString = -1;
    lastPitch = 0;
    lastAcceptPitches.clear();
  }

  PitchAcceptResult acceptPitch(result, TunerModel tunerModel) {
    bool accept = true;
    bool pitched = result["pitched"] > 0;
    double pitch = (result["pitch"] * 1000).ceil() / 1000.0;
    int prob = (result["probability"] * 100).ceil();
    int rms = (result["rms"] * 1000).ceil();
    int ts = (result["timestamp"] * 1000).ceil();
    int string = tunerModel.string;
    var hasResonance = false;
    var multiple = 1.0;
    var reason = PitchRejectReason.SUCCESSFUL;

    if (lastTs <= 0) {
      lastTs = ts;
      accept = false;
      reason = PitchRejectReason.FIRST_PITCH;
    }

    int deltaTs = ts - lastTs;
    lastTs = ts;
    lastTimerTime = DateTime.now().millisecondsSinceEpoch;

    if (lastRms <= 0) {
      lastRms = rms;
    }

    int deltaRms = rms - lastRms;
    lastRms = rms;

    do {
      if (!accept) {
        break;
      }
      if (prob < 60) {
        accept = false;
        reason = PitchRejectReason.SMALL_PROB;
        break;
      }

      // ts是第一个，直接返回
      if (deltaTs <= 0) {
        break;
      }

      // ts连续性, > 500ms 不连续
      if (deltaTs > 1000) {
        reset();
        accept = false;
        reason = PitchRejectReason.TS_TOO_LARGE;
        break;
      }

      // 声音响度连续性
      if (rms < -10203012) {
        accept = false;
        reason = PitchRejectReason.RMS_TOO_SMALL;
        break;
      }

//      if (continuousRms >= 5 && deltaRms >= 300) {
//        accept = false;
//        break;
//      }

      lastRms = rms;
      continuousRms ++;

      if (lastPitch == 0) {
        lastPitch = pitch;
        lastAcceptPitch = pitch;
      }


      // 对比历史pitch
      // 低频共振现象
      var lastPitchDelta = (pitch - lastPitch).abs();
      if (lastPitchDelta > 20) {
        var lastAcceptPitchDelta = (lastAcceptPitch - pitch).abs();
        if (lastAcceptPitch > pitch) {
          multiple = lastAcceptPitch / pitch;
        } else {
          multiple = pitch / lastAcceptPitch;
        }
        if (continuousPitch >= 2 && (multiple - 2.0).abs() <= 0.03) {
          hasResonance = true;
          pitch = lastAcceptPitch;
        }

        if (!hasResonance && lastAcceptPitchDelta > 2) {
          accept = false;
          reason = PitchRejectReason.UNEXPECTED_VAL;
          break;
        }
      }
      lastAcceptPitch = pitch;
      if (!hasResonance) {
        continuousPitch ++;
      }

      if (lastString < 0) {
        lastString = tunerModel.string;
      }

      var nearestString = _getNearestString(tunerModel, pitch);
      if (nearestString != -1) {
        string = nearestString;
      }

      // 和当前选的string不对
      if (string != tunerModel.string) {
        if (lastString != string) {
          lastString = string;
          continuousString = 0;
        }
        if ((lastPitch - pitch) < 3) {
          continuousString ++;
        }

        if (continuousString <= 0) {
          string = tunerModel.string;
        }
      } else {
        continuousString = 0;
        lastString = string;
      }

      var deltaPitch = (pitch - tunerModel.selectedNote.pitch).abs();
      if ((deltaPitch).abs() < 2) {
        matches ++;
      }

      break;
    } while(true);


    if (accept) {
      if (lastAcceptPitches.length >= 3) {
        lastAcceptPitches.removeAt(0);
      }
      lastAcceptPitches.add(pitch);
      var total = lastAcceptPitches.reduce((a,b ) => a + b);
      _result.avgPitch = total / lastAcceptPitches.length;
    } else {
      _result.avgPitch = pitch;
    }

    _result.accept = accept;
    _result.string = string;
    _result.pitch = pitch;
    _result.matches = matches;


    debugPrint("pitch $count [${accept ? "Y" : "N"}] $pitch[$continuousPitch, ${hasResonance ? "2" : "1"}, ${(multiple - 2.0).abs()}] ($prob%) matches=$matches pitched=$pitched rms=$rms($deltaRms) t=$ts($deltaTs) $reason");

    lastTs = ts;
    lastRms = rms;
    lastPitch = pitch;
    count ++;
    return _result;
  }

  int _getNearestString(TunerModel tunerModel, double pitch) {
    var pitchDelta = double.maxFinite;
    var found = tunerModel.string;
    var index = 0;
    tunerModel.tuning.notes.forEach((item) {
      var stringPitch = tunerModel.noteMap[item].pitch;
      var capoPitch = stringPitch * pow(_NOTE_FACTOR, tunerModel.capo);
      var delta = (capoPitch - pitch).abs();
      if (delta < pitchDelta) {
        found = index;
        pitchDelta = delta;
      }
      index ++;
    });
    if (pitchDelta >= 5) {
      return -1;
    }
    return found;
  }

}