import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:provider/provider.dart';
import 'package:strings/i10n/localization_intl.dart';
import 'package:strings/model/tuner.dart';
import 'package:strings/tuner.dart';
import 'package:strings/utils.dart';
import 'package:strings/view/settings.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {

  Tuner _tuner;
  double _offsetX = 0;
  String _pitchText = "0";
  bool _pitchCorrect = true;
  double _correctRangeW = 5;
  int _partCursorFlex = 40;
  int _partGuitarFlex = 90;

  _HomePageState() {
    this._tuner = Tuner(this, _onPitchAccepted, _onPitchIdle);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    this._tuner.didChangeAppLifecycleState(state);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    this._tuner.start();

  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    this._tuner.stop();
  }

  void _onPitchAccepted(pitch, targetPitch) {
    setState(() {
      _offsetX = DisplayHelper.getOffsetX(context, pitch, targetPitch);
      _pitchText = DisplayHelper.getPitchDeltaText(pitch, targetPitch);

      var partCursorH = MediaQuery.of(context).size.height * (_partCursorFlex + 0.0) / (_partCursorFlex + _partGuitarFlex);
      _correctRangeW =  74.0 / 735 * partCursorH;
      _pitchCorrect = _correctRangeW >= (_offsetX * 2).abs();
    });
  }

  void _onPitchIdle() {
    setState(() {
      _offsetX = 0;
      _pitchText = "0";
      _pitchCorrect = true;
    });
  }

  void _toSettingsPage() async {
    var route = MaterialPageRoute(builder: (context) => SettingsPage());
    this._tuner.stop();
    await Navigator.push(context, route);
    this._tuner.start();
  }

  void _toSelectCapo() async {
    var theme = Theme.of(context);
    var tunerModel = Provider.of<TunerModel>(context, listen: false);
    bool confirmed = false;
    Picker picker;
    picker = new Picker(
      adapter: NumberPickerAdapter(data: [
        NumberPickerColumn(begin: 0, end: 12),
      ]),
      cancel: IconButton(icon: Icon(Icons.close), onPressed: () {
        picker.doCancel(context);
      },),
      confirm: IconButton(icon: Icon(Icons.check), onPressed: () {
        confirmed = true;
        picker.doConfirm(context);
      },),
      title: Text("Capo"),
      height: 300,
      itemExtent: 50,
      selecteds: [tunerModel.capo],
      changeToFirst: false,
      textAlign: TextAlign.left,
      columnPadding: const EdgeInsets.all(4.0),
      backgroundColor: theme.canvasColor,
      containerColor: theme.canvasColor,
      headercolor: theme.canvasColor,
      textStyle: TextStyle(fontSize: 24, fontFamily: "LabelFont"),
      selectedTextStyle: TextStyle(color: theme.accentColor, fontSize: 24, fontFamily: "LabelFont"),
      onConfirm: (Picker picker, List value) {
        confirmed = true;
      },
    );
    await picker.showModal(context);
    if (confirmed) {
      tunerModel.setCapo(picker.getSelectedValues()[0]);
    }
  }

  @override
  Widget build(BuildContext context) {
    Sizes.init(context);
    var i18n = StringsLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(i18n.appName, style: TextStyle(fontFamily: "LogoFont")),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.settings),
              onPressed: _toSettingsPage
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Image.asset("assets/bg.jpg", fit: BoxFit.cover),
          ),
          Consumer<TunerModel>(
            builder: (context, tuner, child) {
              if (tuner.loading) {
                return Container();
              }
              return Flex(
                direction: Axis.vertical,
                children: <Widget>[
                  Expanded(
                    flex: _partCursorFlex,
                    child: _getCursorPart(),
                  ),
                  Expanded(
                    flex: _partGuitarFlex,
                    child: _getGuitarPart(),
                  )
                ],
              );
            },
          )
        ],
      ),
    );
  }

  Widget _getCursorPart() {
    var media = MediaQuery.of(context);

    var numberContainerAspect = 160.0 / 106;
    double pointerContainerWidth = media.size.width * 1 / 8;

    return Stack(
      children: <Widget>[
        Align(
          alignment: Alignment.center,
          child: Image.asset(
            "assets/range_correct.png",
          ),
        ),
        AnimatedPositioned(
          duration: Duration(milliseconds: 200),
          top: 0,
          bottom: 0,
          left: _offsetX + media.size.width / 2 - pointerContainerWidth / 2,
          width: pointerContainerWidth,
          child: Container(
              width: pointerContainerWidth,
              child: Stack(
                children: <Widget>[
                  Align(
                    alignment: Alignment.center,
                    child: Image.asset("assets/line.png"),
                  ),
                  Column(
                    children: <Widget>[
                      Expanded(flex: 1, child: Container()),
                      Image.asset(
                          _pitchCorrect ? "assets/pointer_light.png" : "assets/pointer_blue.png",
                          width: media.size.width * 0.5 / 8
                      ),
                      Container(
                          width: pointerContainerWidth,
                          height: pointerContainerWidth / numberContainerAspect,
                          child: Stack(
                            children: <Widget>[
                              Image.asset(
                                _pitchCorrect ? "assets/bg_number_correct.png" : "assets/bg_number_error.png",
                                width: media.size.width * 1 / 8,
                              ),
                              Align(
                                alignment: Alignment(0, 0.2),
                                child: Text(
                                  _pitchText,
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontFamily: "LabelFont",
                                      fontWeight: FontWeight.bold,
                                      color: _pitchCorrect ? Color(0xFF01E7E1) : Color(0xFFD61756)
                                  ),
                                ),
                              )
                            ],
                          )
                      ),
                      Expanded(flex: 1, child: Container()),
                    ],
                  ),
                ],
              )
          ),
        )
      ],
    );
  }

  Widget _getGuitarPart() {
    var i18n = StringsLocalizations.of(context);
    return Stack(
      children: <Widget>[
        Container(
          width: Sizes.screenW,
          child: Column(
            children: <Widget>[
              Consumer<TunerModel>(
                  builder: (context, tuner, child) {
                    return SizedBox(
                      height: Sizes.width(80),
                      child: Transform.translate(
                          offset: Offset(0, Sizes.width(-20)),
                          child: Text(
                            tuner.tuning.notes[tuner.string],
                            style: TextStyle(
                              fontSize: 42,
                              fontFamily: "NoteFont",
                              color: Color(0xFF266064),
                            ),
                          )
                      ),
                    );
                  }
              ),
              Expanded(
                flex: 1,
                child: Consumer<TunerModel>(
                  builder: (context, tuner, child) {
                    return Image.asset(
                      tuner.guitarHead == 0 ? "assets/jita.png" : "assets/dianjita.png",
                      width: Sizes.width(350),
                    );
                  },
                ),
              )
            ],
          ),
        ),
        Container(
            width: Sizes.screenW,
            child: Stack(
              children: <Widget>[
                _getNoteCircleLayout(context),
                Positioned(
                  left: Sizes.width(40),
                  bottom: Sizes.width(50),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: Sizes.width(62),
                        child: OutlineButton(
                          padding: EdgeInsets.all(0),
                          child: Consumer<TunerModel>(
                            builder: (context, tunerModel, child) {
                              return Text(tunerModel.tuning.name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: "LabelFont",
                                  )
                              );
                            },
                          ),
                          onPressed: _toSettingsPage,
                        ),
                      ),
                      SizedBox(height: Sizes.width(20)),
                      SizedBox(
                        height: Sizes.width(62),
                        child: OutlineButton(
                          padding: EdgeInsets.all(0),
                          child: Consumer<TunerModel>(
                            builder: (context, tunerModel, child) {
                              return Text("Capo: ${tunerModel.capo}",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: "LabelFont",
                                  )
                              );
                            },
                          ),
                          onPressed: () {
                            _toSelectCapo();
                          },
                        ),
                      )
                    ],
                  ),
                ),
                Positioned(
                  right: Sizes.width(40),
                  bottom: Sizes.width(50),
                  child: Consumer<TunerModel>(
                    builder: (context, tuner, child) {
                      return GestureDetector(
                        onTap: () {
                          tuner.toggleAuto();
                        },
                        child: Image.asset(
                          tuner.auto ? "assets/${i18n.autoImageHName}.png" : "assets/${i18n.autoImageName}.png",
                          width: Sizes.width(142),
                          height: Sizes.width(62),
                        ),
                      );
                    },
                  )
                )
              ],
            )
        )
      ],
    );
  }

  Widget _getNoteCircleLayout(BuildContext context) {
    return Consumer<TunerModel>(
        builder: (context, tuner, child) {

          if (tuner.guitarHead == 1) {
            return Align(
              alignment: Alignment.center,
              child: Row(
                children: <Widget>[
                  SizedBox(width: Sizes.width(32)),
                  Column(
                    children: <Widget>[
                      SizedBox(height: Sizes.width(84)),
                      SizedBox(height: Sizes.width(100)),
                      _getNoteCircle(2),
                      SizedBox(height: Sizes.width(20)),
                      _getNoteCircle(1),
                      SizedBox(height: Sizes.width(20)),
                      _getNoteCircle(0),
                    ],
                  ),
                  Expanded(flex: 1, child: Container()),
                  Column(
                    children: <Widget>[
                      SizedBox(height: Sizes.width(54)),
                      _getNoteCircle(3),
                      SizedBox(height: Sizes.width(20)),
                      _getNoteCircle(4),
                      SizedBox(height: Sizes.width(20)),
                      _getNoteCircle(5),
                    ],
                  ),
                  SizedBox(width: Sizes.width(32)),
                ],
              ),
            );
          }

          return Align(
            alignment: Alignment.center,
            child: Row(
              children: <Widget>[
                SizedBox(width: Sizes.width(32)),
                Column(
                  children: <Widget>[
                    SizedBox(height: Sizes.width(84)),
                    _getNoteCircle(2),
                    SizedBox(height: Sizes.width(50)),
                    _getNoteCircle(1),
                    SizedBox(height: Sizes.width(50)),
                    _getNoteCircle(0),
                  ],
                ),
                Expanded(flex: 1, child: Container()),
                Column(
                  children: <Widget>[
                    SizedBox(height: Sizes.width(84)),
                    _getNoteCircle(3),
                    SizedBox(height: Sizes.width(50)),
                    _getNoteCircle(4),
                    SizedBox(height: Sizes.width(50)),
                    _getNoteCircle(5),
                  ],
                ),
                SizedBox(width: Sizes.width(32)),
              ],
            ),
          );
        }
    );
  }

  Widget _getNoteCircle(int string) {
    return Consumer<TunerModel>(
        builder: (context, tuner, child) {
          return GestureDetector(
              onTap: () {
                tuner.selectString(string);
              },
              child: Container(
                  width: Sizes.width(110),
                  height: Sizes.width(110),
                  child: Stack(
                    children: <Widget>[
                      Image.asset(
                        tuner.string == string ? "assets/circle-h.png" : "assets/circle.png",
                        width: Sizes.width(110),
                        height: Sizes.width(110),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                            tuner.noteMap[tuner.tuning.notes[string]].name,
                            style: TextStyle(
                              color: string == tuner.string ? Colors.blueAccent : Color(0xFF58545A),
                              fontSize: 40,
                              fontFamily: "NoteFont",
                            )
                        ),
                      )
                    ],
                  )
              )
          );
        }
    );
  }

}
