import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:strings/utils.dart';
import 'package:strings/view/caged/fifths_circle.dart';
import 'package:strings/view/caged/helper.dart';

class CagedPage extends StatefulWidget {
  @override
  _CagedPageState createState() => _CagedPageState();
}

class _CagedPageState extends State<CagedPage> {

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
    var theme = Theme.of(context);
    return Container(
      child: Column(
        children: <Widget>[
          _buildGuitarPart(context),
          Expanded(
            flex: 1,
            child: Container(),
          ),
          Container(
            child: Text(_getFifthsCycleSelectedLabel(), style: TextStyle(fontFamily: "LabelFont")),
          ),
          _buildCircleOfFifths(context),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildGuitarPart(BuildContext context) {
    return Container(
      child: Image(
        image: AssetImage("assets/jita-fretboard.png"),
      ),
    );
  }

  Widget _buildCircleOfFifths(BuildContext context) {
    return SizedBox(
      width: Sizes.width(640),
      height: Sizes.width(640),
      child: FifthsCircle(_onFifthsCircleCallback),
    );
  }
}