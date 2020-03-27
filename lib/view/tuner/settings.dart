import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_section_table_view/flutter_section_table_view.dart';
import 'package:provider/provider.dart';
import 'package:strings/i10n/localization_intl.dart';
import 'package:strings/model/common.dart';
import 'package:strings/model/settings.dart';
import 'package:strings/model/tuner.dart';
import 'package:strings/view/tuner/tuning.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

enum _SettingsSection {
  HeadType,
  CustomTunings,
  CommonTunings,
}

class _SettingsPageState extends State<SettingsPage> {

  @override
  void initState() {
    super.initState();
  }


  String _getSectionTitle(index) {
    var i18n = StringsLocalizations.of(context);
    var section = _SettingsSection.values[index];
    switch (section) {
      case _SettingsSection.HeadType: return i18n.guitarHead;
      case _SettingsSection.CustomTunings: return i18n.customTunings;
      case _SettingsSection.CommonTunings: return i18n.commonTunings;
      default: return "";
    }
  }

  int _numOfRowInSection(index, settingsModel) {
    var section = _SettingsSection.values[index];
    switch (section) {
      case _SettingsSection.HeadType: return 2;
      case _SettingsSection.CustomTunings:
        return settingsModel.customTunings.isEmpty ? 1 : settingsModel.customTunings.length;
      case _SettingsSection.CommonTunings:
        return settingsModel.builtinTunings.length;
      default: return 0;
    }
  }

  Widget _headerInSection(context, index) {
    var theme = Theme.of(context);
    var titleText = Text(
      _getSectionTitle(index),
      style: theme.textTheme.caption
    );
    var titlePadding = EdgeInsets.fromLTRB(20, 14, 20, 10);
    var section = _SettingsSection.values[index];
    switch (section) {
      case _SettingsSection.HeadType:
        return Container(
          padding: titlePadding,
          child: titleText,
        );
      case _SettingsSection.CustomTunings:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
                color: theme.dividerColor,
                height: 0.5
            ),
            Container(
              padding: titlePadding,
              child: Row(
                children: <Widget>[
                  titleText,
                  Expanded(flex: 1, child: Container()),
                  InkWell(
                    onTap: _onClickAddCustom,
                    child: Icon(Icons.add),
                  )
                ],
              ),
            )
          ],
        );
      default:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
                color: theme.dividerColor,
                height: 0.5
            ),
            Container(
              padding: titlePadding,
              child: titleText,
            )
          ],
        );
    }
  }

  Widget _cellAtIndexPath(context, index, row, SettingsModel settingsModel) {
    var theme = Theme.of(context);
    var i18n = StringsLocalizations.of(context);
    var section = _SettingsSection.values[index];
    if (section == _SettingsSection.HeadType) {
      var checkIconColor = settingsModel.guitarHead == row ? theme.primaryIconTheme.color : Colors.transparent;
      return InkWell(
        onTap: () {
          settingsModel.setGuitarHead(row);
        },
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 30,
                child: Icon(Icons.check, color: checkIconColor),
              ),
              SizedBox(width: 20),
              SizedBox(
                width: 30,
                child: ImageIcon(
                  AssetImage(row == 0 ? "assets/jita.png" : "assets/dianjita.png"),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                flex: 1,
                child: Text(
                  row == 0 ? i18n.acousticGuitar : i18n.electricGuitar
                ),
              ),
            ],
          ),
        ),
      );
    }

    List<Tuning> tunings;
    if (section == _SettingsSection.CustomTunings) {
      tunings = settingsModel.customTunings;
    } else {
      tunings = settingsModel.builtinTunings;
    }

    if (section == _SettingsSection.CustomTunings && tunings.isEmpty) {
      return Container(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Center(
            child: Column(
              children: <Widget>[
                SizedBox(
                  width: 180,
                  child: RaisedButton.icon(
                    icon: Icon(Icons.add),
                    onPressed: _onClickAddCustom,
                    label: Text(i18n.add),
                  ),
                )
              ],
            )
        ),
      );
    }

    var tunerModel = Provider.of<TunerModel>(context, listen: false);
    var tuning = tunings[row];
    var selected = tuning.id == tunerModel.tuning.id;

    return InkWell(
      key: Key(tuning.id),
      onTap: () {
        settingsModel.selectTuning(tuning.id);
      },
      onLongPress: () {
        if (section == _SettingsSection.CustomTunings) {
          _onLongPressTuning(settingsModel, tuning);
        }
      },
      child: AnimatedContainer(
        key: Key(tuning.id),
        padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        color: selected ? theme.selectedRowColor.withAlpha(0x11) : Colors.transparent,
        duration: Duration(milliseconds: 200),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 30,
              child: Icon(Icons.check, color: selected ? theme.primaryIconTheme.color : Colors.transparent),
            ),
            SizedBox(width: 20),
            Expanded(
              flex: 2,
              child: Text(
                  tuning.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: "LabelFont",
                  )
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                  tuning.notes.join(" "),
                  style: TextStyle(
                      fontSize: 18,
                      fontFamily: "NoteFont"
                  )
              ),
            ),
          ],
        ),
      ),
    );
  }


  _onClickAddCustom() async {
    var route = MaterialPageRoute<Tuning>(builder: (context) => TuningPage());
    var tuning = await Navigator.push(context, route);
    if (tuning == null) {
      return;
    }
    var settingsModel = Provider.of<SettingsModel>(context, listen: false);
    settingsModel.addCustomTuning(tuning);
  }

  _onLongPressTuning(settingsModel, tuning) {
    var i18n = StringsLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(i18n.noticeTitle),
          content: Text(i18n.confirmDeleteTuning),
          actions: <Widget>[
            FlatButton(
              child: Text(i18n.cancel),
              onPressed: () => Navigator.of(context).pop(),
            ),
            FlatButton(
              child: Text(i18n.delete),
              onPressed: () {
                settingsModel.removeCustomTuning(tuning);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var i18n = StringsLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(i18n.tunerSettings),
      ),
      body: SafeArea(
        child: Consumer<SettingsModel>(
          builder: (context, settingsModel, child) {
            return SectionTableView(
              sectionCount: _SettingsSection.values.length,
              numOfRowInSection: (sectionIdx) {
                return _numOfRowInSection(sectionIdx, settingsModel);
              },
              cellAtIndexPath: (section, row) {
                return _cellAtIndexPath(context, section, row, settingsModel);
              },
              headerInSection: (section) {
                return _headerInSection(context, section);
              },
              divider: Container(
                color: theme.dividerColor,
                height: 0,
              ),
            );
          },
        )
      ),
    );
  }
}