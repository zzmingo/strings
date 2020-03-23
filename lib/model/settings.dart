import 'package:flutter/foundation.dart';
import 'package:strings/model/common.dart';

class SettingsModel extends ChangeNotifier {

  List<Tuning> _customTunings;
  List<Tuning> _builtinTunings;

  List<Tuning> get builtinTunings => _builtinTunings;
  List<Tuning> get customTunings => _customTunings;

  Map<String, Tuning> _tuningMap;

  String _tuningId;

  Tuning get tuning => _tuningMap[_tuningId];

  Future<Null> load() async {
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

    _customTunings = List<Tuning>();

    _tuningId = _builtinTunings.first.id;

    _tuningMap = Map<String, Tuning>();
    _builtinTunings.forEach((tuning) {
      _tuningMap[tuning.id] = tuning;
    });
  }

  void addCustomTuning(Tuning tuning) {
    _customTunings.add(tuning);
    notifyListeners();
  }

  void selectTuning(String tuningId) {
    _tuningId = tuningId;
    notifyListeners();
  }

}