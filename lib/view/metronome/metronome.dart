import 'dart:async';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:strings/i10n/localization_intl.dart';
import 'package:strings/utils.dart';
import 'package:strings/view/metronome/circle_button.dart';

class MetronomePage extends StatefulWidget {
  @override
  _MetronomePageState createState() => _MetronomePageState();
}

class _MetronomePageState extends State<MetronomePage> {

  AudioCache _audioCache;

  Timer _timer;
  bool _working = false;
  List<String> _meterList = ["1/4", "2/4", "3/4", "4/4", "3/8", "6/8"];

  int bpm = 60;
  String meter = "4/4";
  String beatSound = "knock";
  String beatingId;


  @override
  void initState() {
    super.initState();
    _audioCache = AudioCache(prefix: "");

//    meter = GlobalData.userSettings.meter;
//    bpm = GlobalData.userSettings.bpm;
//    beatSound = GlobalData.userSettings.beatSound;
//    beatingId = GlobalData.userSettings.beatingId;
  }

  void _startOrStop() async {
    if (_working) {
      return;
    }
    _working = true;
    String sound = "$beatSound.mp3";
    await _audioCache.load(sound);
    if (_timer != null) {
      _timer.cancel();
      _timer = null;
    } else {
      int millis = (60 * 1000 / bpm).ceil();
      _timer = Timer.periodic(Duration(milliseconds: millis), (timer) {
        _audioCache.play(sound, mode: PlayerMode.LOW_LATENCY);
      });
    }
    setState(() {
      _working = false;
    });
  }

  void _onMeterButtonTapped() {
    var theme = Theme.of(context);
    var i18n = StringsLocalizations.of(context);
    Picker picker = new Picker(
        adapter: PickerDataAdapter<String>(
          isArray: true,
          pickerdata: [_meterList],
        ),
        height: 200,
        itemExtent: 40,
        selecteds: [_meterList.indexOf(meter)],
        hideHeader: true,
        title: Text(i18n.meter),
        textAlign: TextAlign.left,
        columnPadding: EdgeInsets.all(4.0),
        cancelText: i18n.cancel,
        confirmText: i18n.confirm,
        backgroundColor: theme.canvasColor,
        containerColor: theme.canvasColor,
        headercolor: theme.canvasColor,
        cancelTextStyle: TextStyle(color: theme.primaryTextTheme.body1.color),
        confirmTextStyle: TextStyle(color: theme.primaryTextTheme.body1.color),
        textStyle: TextStyle(fontSize: 32),
        selectedTextStyle: TextStyle(color: theme.accentColor, fontSize: 32),
        onConfirm: (Picker picker, List value) {
          setState(() {
            meter = picker.getSelectedValues()[0];
          });

          // TODO
        }
    );
    picker.showDialog(context);
  }

  void _onBpmButtonTapped() {
    var theme = Theme.of(context);
    var i18n = StringsLocalizations.of(context);
    Picker picker = Picker(
        adapter: NumberPickerAdapter(data: [
          NumberPickerColumn(begin: 20, end: 400),
        ]),
        selecteds: [bpm - 20],
        height: 240,
        hideHeader: true,
        title: Text(i18n.bpm),
        itemExtent: 50,
        cancelText: i18n.cancel,
        confirmText: i18n.confirm,
        backgroundColor: theme.canvasColor,
        cancelTextStyle: TextStyle(color: theme.primaryTextTheme.body1.color),
        confirmTextStyle: TextStyle(color: theme.primaryTextTheme.body1.color),
        textStyle: TextStyle(fontSize: 36),
        selectedTextStyle: TextStyle(color: theme.accentColor, fontSize: 36),
        onConfirm: (Picker picker, List value) {
          setState(() {
            bpm = picker.getSelectedValues()[0];
          });
          // TODO
        }
    );
    picker.showDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    var childMargin = 10.0;
    var columns = DisplayHelper.getMeterColumnWeights(meter);
    var columnsWidgets = columns.map((value) {
      if (value > 0) {
        return getBeatColumn(context, value);
      } else {
        return SizedBox(width: childMargin);
      }
    }).toList();

    return Container(
        child: Flex(
          direction: Axis.vertical,
          children: <Widget>[
            Container(
              height: 60,
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
//              child: Flex(
//                direction: Axis.horizontal,
//                children: <Widget>[
//                  OutlineButton.icon(
//                    icon: Icon(Icons.tune),
//                    label: Text(DisplayHelper.getBeatingName(beatingId),
//                        style: TextStyle(
//                          fontSize: 16,
//                        )),
//                    onPressed: () {},
//                  ),
//                  Expanded(flex: 1, child: Container()),
//                  OutlineButton.icon(
//                    icon: Icon(Icons.music_note),
//                    label: Text(DisplayHelper.getBeatingSoundName(beatSound),
//                        style: TextStyle(
//                          fontSize: 16,
//                        )),
//                    onPressed: () {},
//                  ),
//                ],
//              ),
            ),
            Expanded(
              flex: 10,
              child: Container(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  children: columnsWidgets,
                ),
              ),
            ),
            Expanded(
              flex: 12,
              child: Container(
                padding: EdgeInsets.fromLTRB(40, 0, 40, 0),
                child: Flex(
                  direction: Axis.horizontal,
                  children: <Widget>[
                    CircleButton(
                      size: 120,
                      text: meter,
                      icon: Icons.nature,
                      onPressed: _onMeterButtonTapped,
                    ),
                    Expanded(flex: 1, child: Container()),
                    CircleButton(
                      size: 120,
                      text: "$bpm",
                      icon: Icons.flash_on,
                      onPressed: _onBpmButtonTapped,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
                flex: 7,
                child: Container(
                  child: Align(
                      alignment: Alignment.topCenter,
                      child: OutlineButton(
                        focusColor: theme.accentColor,
                        hoverColor: theme.accentColor,
                        highlightColor: theme.accentColor,
                        highlightedBorderColor: theme.accentColor,
                        padding: EdgeInsets.fromLTRB(50, 0, 50, 0),
                        child: Icon(_timer == null ? Icons.play_arrow : Icons.pause,
                            size: 80, color: theme.accentColor),
                        color: theme.accentColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40.0)),
                        onPressed: () {
                          _startOrStop();
                        },
                      )
                  ),
                )
            )
          ],
        ));
  }

  Widget getBeatColumn(BuildContext context, int strong) {
    return Expanded(
      flex: 1,
      child: Column(
        children: <Widget>[
          getBeatBox(context, strong == 3),
          SizedBox(height: 1),
          getBeatBox(context, strong >= 2),
          SizedBox(height: 1),
          getBeatBox(context, strong >= 1),
        ],
      ),
    );
  }

  Widget getBeatBox(BuildContext context, bool fill) {
    var theme = Theme.of(context);
    return Expanded(
      flex: 1,
      child: Container(
        color: fill ? Color(0xFFB50001) : theme.dividerColor,
      ),
    );
  }
}
