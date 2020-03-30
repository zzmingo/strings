import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:strings/model/fretboard.dart';
import 'package:strings/utils.dart';
import 'package:strings/view/caged/fifths_circle.dart';
import 'package:strings/view/caged/helper.dart';

class ChordContent extends StatefulWidget {
  @override
  _ChordContentState createState() => _ChordContentState();
}

enum _PopupItem {
  None,
  Triads,
  SeventhChords,
}

class _ChordContentState extends State<ChordContent> {

  _PopupItem _popupItem = _PopupItem.None;
  MusicMode _musicMode;
  KeyMode _keyMode;

  _onFifthsCircleCallback(FretboardModel fretboardModel, MusicMode musicMode, KeyMode keyMode) {
    if (_musicMode == musicMode && keyMode == _keyMode) {
      return;
    }
    setState(() {
      _musicMode = musicMode;
      _keyMode = keyMode;
      if (_popupItem == _PopupItem.None) {
        fretboardModel.setFretboard(FretboardType.Empty);
      } else {
        fretboardModel.setFretboard(fretboardModel.type, root: Helper.getNoteByMode(_musicMode));
      }
    });
  }

  String _getFifthsCycleSelectedLabel() {
    if (_keyMode == null || _musicMode == null) {
      return "点击五度圈选择调式";
    } else {
      return "${Helper.getKeyModeLabel(_keyMode)} ${Helper.getMusicModeLabel(_keyMode, _musicMode)}";
    }
  }

  String _getPopupItemLabel(_PopupItem item) {
    switch (item) {
      case _PopupItem.Triads: return "三和弦";
      case _PopupItem.SeventhChords: return "七和弦";
      default: return "[未选择和弦类型]";
    }
  }


  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Consumer<FretboardModel>(builder: (context, model, child) {
      return Column(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(),
          ),
          Container(
              height: 50,
              child: Row(
                children: <Widget>[
                  SizedBox(width: 30),
                  Text(
                      _getFifthsCycleSelectedLabel(),
                      style: TextStyle(
                        fontFamily: "NoteFont",
                        fontSize: _musicMode == null ? 14 : 24,
                        color: _musicMode == null ? theme.textTheme.caption.color : theme.textTheme.body1.color,
                      ),
                  ),
                  Expanded(flex: 1, child: Container()),
                  PopupMenuButton<_PopupItem>(
                    initialValue: _popupItem,
                    child: Row(
                      children: <Widget>[
                        Text(_getPopupItemLabel(_popupItem)),
                        Icon(Icons.arrow_drop_down)
                      ],
                    ),
                    itemBuilder: (context) {
                      return _PopupItem.values.map((type) {
                        return PopupMenuItem<_PopupItem>(
                            value: type,
                            child: Text(_getPopupItemLabel(type))
                        );
                      }).toList();
                    },
                    onSelected: (value) {
                      _popupItem = value;
                      if (_popupItem == _PopupItem.None) {
                        model.setFretboard(FretboardType.Empty);
                        return;
                      }
                      var type;
                      if (_popupItem == _PopupItem.Triads) {
                        type = _keyMode == KeyMode.Major ? FretboardType.MajorTriads : FretboardType.MinorTriads;
                      } else if (_popupItem == _PopupItem.SeventhChords) {
                        type = _keyMode == KeyMode.Major ? FretboardType.MajorSeventhChords : FretboardType.MinorSeventhChords;
                      }
                      model.setFretboard(type, root: Helper.getNoteByMode(_musicMode));
                    },
                  ),
                  SizedBox(width: 24),
                ],
              )
          ),
          SizedBox(
            width: Sizes.screenW,
            height: Sizes.screenW,
            child: FifthsCircle((mode, keyMode) {
              _onFifthsCircleCallback(model, mode, keyMode);
            }),
          ),
          Expanded(
            flex: 1,
            child: Container(),
          ),
        ],
      );
    });
  }
}