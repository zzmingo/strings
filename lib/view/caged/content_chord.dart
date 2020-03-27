import 'package:flutter/widgets.dart';
import 'package:strings/utils.dart';
import 'package:strings/view/caged/fifths_circle.dart';
import 'package:strings/view/caged/helper.dart';

class ChordContent extends StatefulWidget {
  @override
  _ChordContentState createState() => _ChordContentState();
}
class _ChordContentState extends State<ChordContent> {

  MusicMode _musicMode;
  KeyMode _keyMode;

  _onFifthsCircleCallback(MusicMode musicMode, KeyMode keyMode) {
    if (_musicMode == musicMode && keyMode == _keyMode) {
      return;
    }
    setState(() {
      _musicMode = musicMode;
      _keyMode = keyMode;
    });
  }

  String _getFifthsCycleSelectedLabel() {
    if (_keyMode == null || _musicMode == null) {
      return "";
    } else {
      return "${Helper.getKeyModeLabel(_keyMode)} ${Helper.getMusicModeLabel(_keyMode, _musicMode)}";
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Container(),
        ),
        Container(
          child: Text(
              _getFifthsCycleSelectedLabel(),
              style: TextStyle(fontFamily: "NoteFont", fontSize: 24)
          ),
        ),
        SizedBox(
          width: Sizes.screenW,
          height: Sizes.screenW,
          child: FifthsCircle(_onFifthsCircleCallback),
        ),
        Expanded(
          flex: 1,
          child: Container(),
        ),
      ],
    );
  }
}