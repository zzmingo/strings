import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:strings/i10n/localization_intl.dart';
import 'package:strings/utils.dart';
import 'package:strings/view/metronome/circle_button.dart';
import 'package:strings/view/picker.dart';

class MetronomePage extends StatefulWidget {
  @override
  _MetronomePageState createState() => _MetronomePageState();
}

enum _SoundType {
  Simple,
  Drum,
}

class _SoundPlayArg {
  File file;
  double volume = 1.0;

  _SoundPlayArg(this.file, { this.volume });
}

class _Meter {
  String name;
  List<int> sequence;

  _Meter(this.name, this.sequence);
}

class _MetronomePageState extends State<MetronomePage> {

  AudioCache _audioCache;
  AudioPlayer _audioPlayer;
  var _audioPlayerList = List<AudioPlayer>();
  int _playerIndex = -1;

  Timer _timer;
  bool _preparing = false;
  bool _working = false;
  List<_Meter> _meterList = [
    _Meter("1/4", [3]),
    _Meter("2/4", [3, 1]),
    _Meter("3/4", [3, 1, 1]),
    _Meter("4/4", [3, 1, 2, 1]),
    _Meter("3/8", [3, 1, 1, 1, 1, 1]),
    _Meter("6/8", [3, 1, 1, 2, 1, 1]),
  ];
  var _soundArgList = List<_SoundPlayArg>();
  var _nextTick = 0;

  int _bpm = 60;
  _Meter _meter;
  _SoundType _soundType = _SoundType.Simple;


  @override
  void initState() {
    super.initState();
    _meter = _meterList[3];
    for (var i=0; i<8; i++) {
      _audioPlayerList.add(AudioPlayer(mode: PlayerMode.LOW_LATENCY));
    }
    _audioCache = AudioCache(prefix: "", fixedPlayer: _audioPlayer);
  }

  @override
  void dispose() {
    super.dispose();
    if (_timer != null) {
      _timer.cancel();
    }
  }

  String _getSoundTypeLabel(_SoundType type) {
    switch (type) {
      case _SoundType.Simple: return "Simple";
      case _SoundType.Drum: return "Drums";
      default: return "";
    }
  }

  Future<Null> _prepareSounds() async {
    _soundArgList.clear();
    switch (_soundType) {
      case _SoundType.Simple:
        File file = await _audioCache.load("knock.mp3");
        await Future.wait(_audioPlayerList.map((player) {
          return player.play(file.path, volume: 0);
        }));
        _soundArgList = _meter.sequence.map((value) {
          return _SoundPlayArg(file, volume: value == 3 ? 1.0 : 0.6);
        }).toList();
        break;
      case _SoundType.Drum:
        File strong = await _audioCache.load("drum_strong.mp3");
        File strong2 = await _audioCache.load("drum_strong2.mp3");
        File weak = await _audioCache.load("drum_weak.mp3");
        await Future.wait(_audioPlayerList.map((player) {
          return player.play(strong.path, volume: 0);
        }));
        await Future.wait(_audioPlayerList.map((player) {
          return player.play(strong2.path, volume: 0);
        }));
        await Future.wait(_audioPlayerList.map((player) {
          return player.play(weak.path, volume: 0);
        }));
        _soundArgList = _meter.sequence.map((value) {
          if (value == 3) return _SoundPlayArg(strong);
          if (value == 2) return _SoundPlayArg(strong2, volume: 0.8);
          return _SoundPlayArg(weak);
        }).toList();
        break;
      default: return;
    }
  }

  void _startOrStop() async {
    if (_preparing) {
      return;
    }
    if (_timer != null) {
      _timer.cancel();
      _timer = null;
      _working = false;
    } else {
      _preparing = true;
      await _prepareSounds();
      if (!_preparing) {
        return;
      }
      int millis = (60 * 1000 / _bpm).ceil();
      _nextTick = 0;
      _playerIndex = 0;
      _timer = Timer.periodic(Duration(milliseconds: millis), (timer) {
        if (!_working) {
          return;
        }
        if (_nextTick >= _soundArgList.length) {
          _nextTick = 0;
        }
        _nextTick ++;
        var player = _audioPlayerList[_playerIndex];
        var sound = _soundArgList[_nextTick-1];
        player.play(sound.file.path, volume: sound.volume);

        _playerIndex ++;
        if (_playerIndex >= _audioPlayerList.length) {
          _playerIndex = 0;
        }
        setState(() {});
      });
    }
    setState(() {
      _preparing = false;
      _working = true;
    });
  }

  void _stop() {
    setState(() {
      _preparing = false;
      _working = false;
    });
    if (_timer != null) {
      _timer.cancel();
      _timer = null;
    }
  }

  void _tryRestart() {
    if (_working) {
      _stop();
      _startOrStop();
    }
  }

  List<int> _getMeterColumnWeights(String meter) {
    List<int> columns;
    switch (meter) {
      case "1/4": columns = [3]; break;
      case "2/4": columns = [3,0,1]; break;
      case "3/4": columns = [3,0,1,0,1]; break;
      case "4/4": columns = [3,0,1,0,2,0,1]; break;
      case "3/8": columns = [3,0,1,0,1,0,1,0,1,0,1]; break;
      case "6/8": columns = [3,0,1,0,1,0,2,0,1,0,1]; break;
      default:    columns = [3,0,1,0,2,0,1];
    }
    return columns;
  }

  void _onMeterButtonTapped() {
    var i18n = StringsLocalizations.of(context);
    debugPrint(_meterList.map((meter) => meter.name).join(","));
    Pickers.showDialog(context,
      title: i18n.meter,
      selecteds: [_meterList.indexOf(_meter)],
      adapter: PickerDataAdapter<String>(
        isArray: true,
        pickerdata: [_meterList.map((meter) => meter.name).toList()],
      ),
      onConfirm: (Picker picker, List value) {
        setState(() {
          _meter = _meterList.firstWhere((meter) {
            return picker.getSelectedValues()[0] == meter.name;
          });
          _tryRestart();
        });
      }
    );
  }

  void _onBpmButtonTapped() {
    var i18n = StringsLocalizations.of(context);
    Pickers.showDialog(
      context,
      adapter: NumberPickerAdapter(data: [
        NumberPickerColumn(begin: 20, end: 400),
      ]),
      selecteds: [_bpm - 20],
      title: i18n.bpm,
      onConfirm: (Picker picker, List value) {
        setState(() {
          _bpm = picker.getSelectedValues()[0];
          _tryRestart();
        });
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    var childMargin = 10.0;
    var columns = _getMeterColumnWeights(_meter.name);
    var columnIdx = 0;
    var columnsWidgets = columns.map((value) {
      if (value > 0) {
        return getBeatColumn(context, value, columnIdx++);
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
              child: Flex(
                direction: Axis.horizontal,
                children: <Widget>[
                  PopupMenuButton<_SoundType>(
                    initialValue: _soundType,
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.music_note),
                        SizedBox(width: 5),
                        Text(_getSoundTypeLabel(_soundType),
                            style: TextStyle(
                              fontSize: 16,
                            )
                        ),
                        SizedBox(width: 5),
                        Icon(Icons.arrow_drop_down),
                      ],
                    ),
                    itemBuilder: (context) {
                      return _SoundType.values.map((type) {
                        return PopupMenuItem<_SoundType>(
                            value: type,
                            child: Text(_getSoundTypeLabel(type))
                        );
                      }).toList();
                    },
                    onSelected: (value) {
                      setState(() {
                        _soundType = value;
                        _tryRestart();
                      });
                    },
                  ),

                  Expanded(flex: 1, child: Container()),
                ],
              ),
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
                      text: _meter.name,
                      icon: Icons.nature,
                      onPressed: _onMeterButtonTapped,
                    ),
                    Expanded(flex: 1, child: Container()),
                    CircleButton(
                      size: 120,
                      text: "$_bpm",
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

  Widget getBeatColumn(BuildContext context, int strong, int columnIdx) {
    return Expanded(
      flex: 1,
      child: Column(
        children: <Widget>[
          getBeatBox(context, strong == 3, columnIdx),
          SizedBox(height: 1),
          getBeatBox(context, strong >= 2, columnIdx),
          SizedBox(height: 1),
          getBeatBox(context, strong >= 1, columnIdx),
        ],
      ),
    );
  }

  Widget getBeatBox(BuildContext context, bool fill, int columnIdx) {
    var theme = Theme.of(context);
    var light = _working && columnIdx == _nextTick - 1;
    var color = theme.dividerColor;
    if (fill) {
      color = light ? Color(0xFFFF0001) : Color(0xFFB50001);
    }
    return Expanded(
      flex: 1,
      child: Container(
        color: color,
      ),
    );
  }
}
