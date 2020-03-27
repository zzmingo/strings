import 'dart:math';

import 'package:charts_flutter/flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:strings/utils.dart';
import 'package:strings/utils/debounce.dart';

import 'helper.dart';


typedef FifthsCircleCallback = void Function(MusicMode mode, KeyMode keyMode);

class FifthsCircle extends StatefulWidget {

  FifthsCircle(this._callback);

  FifthsCircleCallback _callback;


  @override
  _FifthsCircleState createState() => _FifthsCircleState(_callback);
}

class _FifthsCircleState extends State<FifthsCircle> {

  _FifthsCircleState(this._callback);

  FifthsCircleCallback _callback;

  final _debounce = Debounce(milliseconds: 0);

  List<Series<CirclePart, int>> _getMinorCircleData() {
    return [
      Series<CirclePart, int>(
        id: "FifthsCircle",
        domainFn: (part, _) => part.mode.index,
        measureFn: (part, _) => 1,
        labelAccessorFn: (part, _) => Helper.getMinorLabel(part.mode),
        data: MusicMode.values.reversed.map((mode) {
          return CirclePart(mode);
        }).toList(),
      ),
    ];
  }

  List<Series<CirclePart, int>> _getMajorCircleData() {
    return [
      Series<CirclePart, int>(
        id: "FifthsCircle",
        domainFn: (part, _) => part.mode.index,
        measureFn: (part, _) => 1,
        labelAccessorFn: (part, _) => Helper.getMajorLabel(part.mode),
        data: MusicMode.values.reversed.map((mode) {
          return CirclePart(mode);
        }).toList(),
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
  }

  void _onPointerUpdate(PointerEvent event) {
    var pointer = event.localPosition;
    var mode = Helper.getMusicModeByPointer(event.localPosition);
    var screenWHalf = Sizes.screenW / 2;
    pointer = Offset(pointer.dx - screenWHalf, pointer.dy - screenWHalf);
    var keyMode = pointer.distance > Sizes.width(420) / 2 ? KeyMode.Major : KeyMode.Minor;
    _debounce.run(() {
      _callback(mode, keyMode);
    });
  }

  Color _getMajorFillColor(MusicMode mode) {
    return mode.index % 2 == 0 ? Color.fromHex(code: "#FFFFFF") : Color.fromHex(code: "#F1F1F1");
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var innerSize = Sizes.width(450);
    var outerSize = Sizes.width(184);
    var textColor = theme.primaryColorDark;
    var chartTextColor = Color(r: textColor.red, g: textColor.green, b: textColor.blue, a: textColor.alpha);

    return Listener(
      onPointerDown: _onPointerUpdate,
      onPointerMove: _onPointerUpdate,
      onPointerUp: _onPointerUpdate,
      child: Container(
          child: Stack(
            children: <Widget>[
              Container(
                color: Colors.transparent,
              ),
              IgnorePointer(
                key: Key("Major"),
                child: PieChart(
                    _getMajorCircleData(),
                    animate: false,
                    defaultRenderer: ArcRendererConfig(
                        arcWidth: (outerSize / 2).ceil(),
                        startAngle: -pi / 2 + pi / 12,
                        strokeWidthPx: 0,
                        arcRendererDecorators: [
                          ArcLabelDecorator(
                              labelPosition: ArcLabelPosition.inside,
                              insideLabelStyleSpec: TextStyleSpec(
                                fontSize: 22,
                                fontFamily: "NoteFont",
                                color: chartTextColor,
                              )
                          )
                        ]
                    )
                ),
              ),
              IgnorePointer(
                key: Key("Minor"),
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: innerSize,
                    height: innerSize,
                    child: PieChart(
                        _getMinorCircleData(),
                        animate: false,
                        defaultRenderer: ArcRendererConfig(
                            arcWidth: (innerSize / 4).ceil(),
                            startAngle: -pi / 2 + pi / 12,
                            strokeWidthPx: 0,
                            arcRendererDecorators: [
                              ArcLabelDecorator(
                                  labelPosition: ArcLabelPosition.inside,
                                  insideLabelStyleSpec: TextStyleSpec(
                                    fontSize: 18,
                                    fontFamily: "NoteFont",
                                    color: chartTextColor,
                                  )
                              ),
                            ]
                        )
                    ),
                  ),
                ),
              )
            ],
          )
      ),
    );
  }
}

class CirclePart {
  final MusicMode mode;

  CirclePart(this.mode);
}