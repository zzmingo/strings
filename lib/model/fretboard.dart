import 'package:flutter/foundation.dart';


class FretboardNote {
  int fret;
  int string;
  String note;
  double x;
  double y;
}

class FretboardModel extends ChangeNotifier {

  var _type = FretboardType.AllFretboardNotes;
  var _subtype = FretboardSubtype.None;

  var _primaryList = List<FretboardNote>();
  var _secondaryList = List<FretboardNote>();

  List<FretboardNote> get primaryList => _primaryList;
  List<FretboardNote> get secondaryList => _secondaryList;
  int get typeIndex => FretboardType.values.indexOf(_type);

  void setFretboard(FretboardType type, {
    FretboardSubtype subtype = FretboardSubtype.None,
    bool notify = true,
    String root,
  }) {
    _type = type;
    _subtype = subtype;

    switch (type) {
      case FretboardType.AllFretboardNotes:
        _primaryList = FretboardHelper.getAllFretboardNotes();
        _secondaryList = null;
        break;
      case FretboardType.RootNote:
        _primaryList = FretboardHelper.getAllFretboardNotes().where((note) {
          return note.note == root;
        }).toList();
        _secondaryList = null;
        break;
      case FretboardType.MajorScale:
        var scale = FretboardHelper.getMajorScale(root);
        _primaryList = FretboardHelper.getAllFretboardNotes().where((note) {
          return scale.contains(note.note);
        }).toList();
        _secondaryList = null;
        break;
      case FretboardType.MinorScale:
        var scale = FretboardHelper.getMinorScale(root);
        _primaryList = FretboardHelper.getAllFretboardNotes().where((note) {
          return scale.contains(note.note);
        }).toList();
        _secondaryList = null;
        break;
      case FretboardType.PentatonicMajorScale:
        var scale = FretboardHelper.getPentatonicMajorScale(root);
        _primaryList = FretboardHelper.getAllFretboardNotes().where((note) {
          return scale.contains(note.note);
        }).toList();
        _secondaryList = null;
        break;
      case FretboardType.PentatonicMinorScale:
        var scale = FretboardHelper.getPentatonicMinorScale(root);
        _primaryList = FretboardHelper.getAllFretboardNotes().where((note) {
          return scale.contains(note.note);
        }).toList();
        _secondaryList = null;
        break;
      default:
        break;
    }

    if (this._primaryList == null) {
      this._primaryList = List<FretboardNote>();
    }
    if (this._secondaryList == null) {
      this._secondaryList = List<FretboardNote>();
    }
    if (notify) {
      notifyListeners();
    }
  }

}


enum FretboardType {
  Empty,
  AllFretboardNotes,
  RootNote,
  MajorScale,
  MinorScale,
  PentatonicMajorScale,
  PentatonicMinorScale,
}

enum FretboardSubtype {
  None,
}

class FretboardHelper {
  static var _noteSequence = ["C", "D♭", "D", "E♭", "E", "F", "G♭", "G", "A♭", "A", "B♭", "B"];
  static var _allFretboardNotes = List<FretboardNote>();
  static var _allFretboardMap = Map<String, FretboardNote>();

  static var _majorScales = {};
  static var _minorScales = {};
  static var _pentatonicMajorScales = {};
  static var _pentatonicMinorScales = {};

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
        _allFretboardMap[_boardKey(fret, string)] = note;
        lastNote = getNextNote(lastNote);
        fret++;
      });
      string ++;
    });


    var majorFormat = [2,2,1,2,2,2];
    _noteSequence.forEach((root) {
      var lastNote = root;
      var scale = _majorScales[root] = [lastNote];
      majorFormat.forEach((delta) {
        while(delta > 0) {
          lastNote = getNextNote(lastNote);
          delta --;
        }
        scale.add(lastNote);
      });
    });

    var minorFormat = [2,1,2,2,1,2];
    _noteSequence.forEach((root) {
      var lastNote = root;
      var scale = _minorScales[root] = [lastNote];
      minorFormat.forEach((delta) {
        while(delta > 0) {
          lastNote = getNextNote(lastNote);
          delta --;
        }
        scale.add(lastNote);
      });
    });

    var pentatonicMajorFormat = [2,2,3,2];
    _noteSequence.forEach((root) {
      var lastNote = root;
      var scale = _pentatonicMajorScales[root] = [lastNote];
      pentatonicMajorFormat.forEach((delta) {
        while(delta > 0) {
          lastNote = getNextNote(lastNote);
          delta --;
        }
        scale.add(lastNote);
      });
    });

    var pentatonicMinorFormat = [3, 2, 2, 3];
    _noteSequence.forEach((root) {
      var lastNote = root;
      var scale = _pentatonicMinorScales[root] = [lastNote];
      pentatonicMinorFormat.forEach((delta) {
        while(delta > 0) {
          lastNote = getNextNote(lastNote);
          delta --;
        }
        scale.add(lastNote);
      });
    });
  }

  static List<String> getNoteSequence() {
    var clone = List<String>();
    clone.addAll(_noteSequence);
    return clone;
  }

  static List<String> getMajorScale(String root) {
    init();
    return _majorScales[root];
  }

  static List<String> getMinorScale(String root) {
    init();
    return _minorScales[root];
  }

  static List<String> getPentatonicMajorScale(String root) {
    init();
    return _pentatonicMajorScales[root];
  }

  static List<String> getPentatonicMinorScale(String root) {
    init();
    return _pentatonicMinorScales[root];
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
    return _allFretboardMap[_boardKey(fret, string)];
  }

  static List<FretboardNote> getAllFretboardNotes() {
    init();
    var clone = List<FretboardNote>();
    clone.addAll(_allFretboardNotes);
    return clone;
  }

  static String _boardKey(int fret, int string) {
    return "${fret}x$string";
  }
}