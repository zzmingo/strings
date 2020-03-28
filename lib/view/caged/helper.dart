import 'dart:math';

import 'package:flutter/material.dart';
import 'package:strings/model/fretboard.dart';
import 'package:strings/utils.dart';

enum KeyMode {
  Major,
  Minor,
}

enum MusicMode {
  C, F, Bb, Eb, Ab, Db, Gb, B, E, A, D, G
}

class Helper {

  static var _noteSequence = ["C", "D♭", "D", "E♭", "E", "F", "G♭", "G", "A♭", "A", "B♭", "B"];
  static var _allFretboardNotes = List<FretboardNote>();
  static var _allFretboardMap = Map<String, FretboardNote>();

  static void init() {
    if (_allFretboardNotes.isNotEmpty) {
      return;
    }
    var standardStrings = ["E", "B", "G", "D", "A" , "E"];
    var string = 0;
    getStringYList().forEach((y) {
      var lastNote = standardStrings[string];
      var fret = 0;
      getFretXList().forEach((x) {
        var note = FretboardNote();
        note.fret = fret;
        note.string = string;
        note.x = x.toDouble();
        note.y = y.toDouble();
        note.note = lastNote;
        _allFretboardNotes.add(note);
        _allFretboardMap["${fret}x${note.string}"] = note;
        debugPrint("${fret}x${note.string}");
        lastNote = getNextNote(lastNote);
        fret++;
      });
      string ++;
    });
  }

  static List<int> getFretXList() {
    return [50, 220, 410, 586, 754, 910, 1066, 1208, 1346, 1472, 1600, 1710, 1820, 1920, 2008, 2100, 2180];
  }

  static List<int> getStringYList() {
    return [446, 498, 548, 600, 650, 700];
  }

  static String getNextNote(String note) {
    var index = _noteSequence.indexOf(note);
    if (index == _noteSequence.length - 1) {
      index = 0;
    } else {
      index ++;
    }
    return _noteSequence[index];
  }

  static FretboardNote getFretboardNode(int fret, int string) {
    init();
    return _allFretboardMap["${fret}x$string"];
  }

  static List<FretboardNote> getAllFretboardNotes() {
    init();
    var clone = List<FretboardNote>();
    clone.addAll(_allFretboardNotes);
    return clone;
  }

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
      case MusicMode.Db: return "D♭ C♯";
      case MusicMode.Gb: return "G♭ F♯";
      case MusicMode.B: return "C♭ B";
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
      case MusicMode.Db: return "b♭ a♯";
      case MusicMode.Gb: return "e♭ d♯";
      case MusicMode.B: return "a♭ g♯";
      case MusicMode.E: return "c♯";
      case MusicMode.A: return "f♯";
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