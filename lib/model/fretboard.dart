import 'package:flutter/foundation.dart';


class FretboardNote {
  int fret;
  int string;
  String note;
  double x;
  double y;
}

class FretboardModel extends ChangeNotifier {

  var _primaryList = List<FretboardNote>();
  var _secondaryList = List<FretboardNote>();

  List<FretboardNote> get primaryList => _primaryList;
  List<FretboardNote> get secondaryList => _secondaryList;

  void setFretboard(List<FretboardNote> primaryList, List<FretboardNote> secondaryList) {
    this._primaryList = primaryList;
    this._secondaryList = secondaryList;
    if (this._primaryList == null) {
      this._primaryList = List<FretboardNote>(0);
    }
    if (this._secondaryList == null) {
      this._secondaryList = List<FretboardNote>(0);
    }
    notifyListeners();
  }

}