import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:strings/model/common.dart';

const String _CUSTOM_TUNINGS_KEY = "mingo.strings.settings.customTunings";
const String _SELECTED_TUNING_KEY = "mingo.strings.settings.selectedTuning";
const String _SELECTED_GUITAR_HEAD_KEY = "mingo.strings.settings.selectedGuitarHead";

class SettingsModel extends ChangeNotifier {

  List<Tuning> _customTunings;
  List<Tuning> _builtinTunings;

  List<Tuning> get builtinTunings => _builtinTunings;
  List<Tuning> get customTunings => _customTunings;

  Map<String, Tuning> _tuningMap;

  String _tuningId;
  int _guitarHead = 0;

  Tuning get tuning => _tuningMap[_tuningId];
  int get guitarHead => _guitarHead;

  Future<Null> load() async {
    _builtinTunings = List<Tuning>();
    var tuning = Tuning();
    tuning.id = "strings.builtin.tuning.standard";
    tuning.name = "Standard";
    tuning.notes = "E2 A2 D3 G3 B3 E4".split(" ").toList();
    _builtinTunings.add(tuning);
    tuning = Tuning();
    tuning.id = "strings.builtin.tuning.openD";
    tuning.name = "Open D";
    tuning.notes = "D2 A2 #F3 D3 A3 D4".split(" ").toList();
    _builtinTunings.add(tuning);

    _customTunings = List<Tuning>();
    var prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(_CUSTOM_TUNINGS_KEY)) {
      var jsonStr = prefs.getString(_CUSTOM_TUNINGS_KEY);
      var jsonList = jsonDecode(jsonStr);
      jsonList.forEach((item) {
        _customTunings.add(Tuning.fromJson(item));
      });
    }

    _tuningMap = Map<String, Tuning>();
    _builtinTunings.forEach((tuning) {
      _tuningMap[tuning.id] = tuning;
    });
    _customTunings.forEach((tuning) {
      _tuningMap[tuning.id] = tuning;
    });

    _tuningId = _builtinTunings.first.id;
    if (prefs.containsKey(_SELECTED_TUNING_KEY)) {
      _tuningId = prefs.getString(_SELECTED_TUNING_KEY);
    }
    if (!_tuningMap.containsKey(_tuningId)) {
      _tuningId = _builtinTunings.first.id;
    }

    if (prefs.containsKey(_SELECTED_GUITAR_HEAD_KEY)) {
      _guitarHead = prefs.getInt(_SELECTED_GUITAR_HEAD_KEY);
    }
  }

  void addCustomTuning(Tuning tuning) async {
    _customTunings.add(tuning);
    _tuningMap[tuning.id] = tuning;
    notifyListeners();
    saveCustomTunings();
  }

  void removeCustomTuning(Tuning tuning) async {
    _customTunings.remove(tuning);
    _tuningMap.remove(tuning.id);
    if (tuning.id == _tuningId) {
      if (_customTunings.isEmpty) {
        _tuningId = _builtinTunings.first.id;
      } else {
        _tuningId = _customTunings.first.id;
      }
    }
    notifyListeners();
    saveCustomTunings();
  }

  void saveCustomTunings() async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString(_CUSTOM_TUNINGS_KEY, jsonEncode(_customTunings));
  }

  void selectTuning(String tuningId) async {
    _tuningId = tuningId;
    notifyListeners();

    var prefs = await SharedPreferences.getInstance();
    prefs.setString(_SELECTED_TUNING_KEY, _tuningId);
  }

  void setGuitarHead(int guitarHead) async {
    _guitarHead = guitarHead;
    notifyListeners();

    var prefs = await SharedPreferences.getInstance();
    prefs.setInt(_SELECTED_GUITAR_HEAD_KEY, _guitarHead);
  }

}