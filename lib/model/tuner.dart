import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:strings/model/common.dart';

class TunerModel extends ChangeNotifier {

  // 持久化状态
  String _tuningId;
  bool _auto = true;
  List<Tuning> _customTunings;

  // 以下是临时状态
  @JsonKey(ignore: true)
  int _string = 5;

  @JsonKey(ignore: true)
  bool _loading = true;

  @JsonKey(ignore: true)
  Map<String, Note> _noteMap;

  @JsonKey(ignore: true)
  Map<String, Tuning> _tuningMap;

  @JsonKey(ignore: true)
  List<Tuning> _builtinTunings;

  SharedPreferences _prefs;

  TunerModel() {
    load();
  }

  bool get loading => _loading;
  bool get auto => _auto;
  int get string => _string;
  Tuning get tuning => _tuningMap[_tuningId];
  Map<String, Note> get noteMap => _noteMap;
  Note get selectedNote => noteMap[tuning.notes[string]];

  void load() async {
    String noteJson = await rootBundle.loadString("assets/notes.json");
    Map<String, dynamic> noteRawMap = jsonDecode(noteJson);
    _noteMap = Map<String, Note>();
    noteRawMap.forEach((key, value) {
      _noteMap[key] = Note.fromJson(value);
    });

    _builtinTunings = List<Tuning>();
    var tuning = Tuning();
    tuning.id = "strings.builtin.tuning.standard";
    tuning.name = "Standard";
    tuning.notes = "E2,A2,D3,G3,B3,E4".split(",").toList();
    _builtinTunings.add(tuning);
    tuning = Tuning();
    tuning.id = "strings.builtin.tuning.openD";
    tuning.name = "Open D";
    tuning.notes = "D2,A2,♯F3,D3,A3,D4".split(",").toList();
    _builtinTunings.add(tuning);

    _tuningId = _builtinTunings.first.id;

    _tuningMap = Map<String, Tuning>();
    _builtinTunings.forEach((tuning) {
      _tuningMap[tuning.id] = tuning;
    });

    _prefs = await SharedPreferences.getInstance();

    _loading = false;
    notifyListeners();
  }

  void toggleAuto() {
    this._auto = !this._auto;
    notifyListeners();
  }

  void selectString(int string) {
    debugPrint("select string");
    this._string = string;
    notifyListeners();
  }

}

