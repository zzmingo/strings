import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:strings/model/common.dart';
import 'package:strings/model/settings.dart';

class TunerModel extends ChangeNotifier {

  bool _loading = true;

  bool _auto = true;
  int _string = 5;


  Map<String, Note> _noteMap;

  SettingsModel _settingsModel;

  TunerModel(this._settingsModel);

  bool get loading => _loading;
  bool get auto => _auto;
  int get string => _string;
  int get guitarHead => _settingsModel.guitarHead;
  Tuning get tuning => _settingsModel.tuning;
  Map<String, Note> get noteMap => _noteMap;
  Note get selectedNote => noteMap[tuning.notes[string]];

  Future<Null> load() async {
    await this._settingsModel.load();

    String noteJson = await rootBundle.loadString("assets/notes.json");
    Map<String, dynamic> noteRawMap = jsonDecode(noteJson);
    _noteMap = Map<String, Note>();
    noteRawMap.forEach((key, value) {
      _noteMap[key] = Note.fromJson(value);
    });

    var prefs = await SharedPreferences.getInstance();

    _loading = false;
    notifyListeners();
  }

  void toggleAuto() {
    this._auto = !this._auto;
    notifyListeners();
  }

  void selectString(int string) {
    this._string = string;
    notifyListeners();
  }

}

