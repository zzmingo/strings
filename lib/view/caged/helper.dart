import 'dart:math';

import 'package:flutter/material.dart';
import 'package:strings/utils.dart';

enum KeyMode {
  Major,
  Minor,
}

enum MusicMode {
  C, F, Bb, Eb, Ab, Db, Gb, B, E, A, D, G
}

class Helper {
  static String getKeyModeLabel(KeyMode keyMode) {
    switch (keyMode) {
      case KeyMode.Major: return "Major";
      case KeyMode.Minor: return "Minor";
      default: return "";
    }
  }

  static String getMusicModeLabel(KeyMode keyMode, MusicMode mode) {
    if (keyMode == KeyMode.Major) {
      return getMajorLabel(mode);
    } else {
      return getMinorLabel(mode);
    }
  }

  static String getMajorLabel(MusicMode mode) {
    switch (mode) {
      case MusicMode.C: return "C";
      case MusicMode.F: return "F";
      case MusicMode.Bb: return "B♭";
      case MusicMode.Eb: return "E♭";
      case MusicMode.Ab: return "A♭";
      case MusicMode.Db: return "D♭";
      case MusicMode.Gb: return "G♭";
      case MusicMode.B: return "B♭";
      case MusicMode.E: return "E";
      case MusicMode.A: return "A";
      case MusicMode.D: return "D";
      case MusicMode.G: return "G";
      default: return null;
    }
  }

  static String getMinorLabel(MusicMode mode) {
    switch (mode) {
      case MusicMode.C: return "a";
      case MusicMode.F: return "d";
      case MusicMode.Bb: return "g";
      case MusicMode.Eb: return "c";
      case MusicMode.Ab: return "f";
      case MusicMode.Db: return "b♭";
      case MusicMode.Gb: return "e♭";
      case MusicMode.B: return "a♭";
      case MusicMode.E: return "c#";
      case MusicMode.A: return "f#";
      case MusicMode.D: return "b";
      case MusicMode.G: return "e";
      default: return null;
    }
  }

  static MusicMode getMusicModeByPointer(Offset pointer) {
    var screenWHalf = Sizes.screenW / 2;
    pointer = Offset(pointer.dx - screenWHalf, pointer.dy - screenWHalf);
    var anger = ((atan2(pointer.dx, pointer.dy) + pi) / pi * 180).ceil();
    if (anger > 360 - 15) {
      anger = 15 - (anger - 360).abs();
    } else {
      anger = anger + 15;
    }
    var index = (anger/30).floor();
    if (index == 12) {
      index = 11;
    }
    var mode = MusicMode.values[index];
    return mode;
  }
}