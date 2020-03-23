import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_section_table_view/flutter_section_table_view.dart';
import 'package:provider/provider.dart';
import 'package:strings/i10n/localization_intl.dart';
import 'package:strings/model/common.dart';
import 'package:strings/model/settings.dart';
import 'package:strings/model/tuner.dart';
import 'package:strings/view/tuning.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

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
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.add),
              onPressed: _onClickAddCustom
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<SettingsModel>(
          builder: (context, settingsModel, child) {
            var tunerModel = Provider.of<TunerModel>(context, listen: false);
            return SectionTableView(
              sectionCount: 2,
              numOfRowInSection: (section) {
                if (section == 0 && settingsModel.customTunings.isEmpty) {
                  return 1;
                }
                return section == 0 ?
                  settingsModel.customTunings.length :
                  settingsModel.builtinTunings.length;
              },
              cellAtIndexPath: (section, row) {
                List<Tuning> tunings;
                if (section == 0) {
                  tunings = settingsModel.customTunings;
                } else {
                  tunings = settingsModel.builtinTunings;
                }

                if (section == 0 && tunings.isEmpty) {
                  return Container(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 60),
                    child: Center(
                      child: Column(
                        children: <Widget>[
                          Icon(
                            Icons.add_alert,
                            size: 50,
                          ),
                          SizedBox(height: 20),
                          Text(
                            i18n.noCustomTunings,
                            style: theme.textTheme.caption,
                          ),
                          SizedBox(height: 20),
                          SizedBox(
                            width: 200,
                            child: RaisedButton(
                              onPressed: _onClickAddCustom,
                              child: Text(i18n.add),
                            ),
                          )
                        ],
                      )
                    ),
                  );
                }

                var tuning = tunings[row];
                var selected = tuning.id == tunerModel.tuning.id;

                return InkWell(
                  key: Key(tuning.id),
                  onTap: () {
                    settingsModel.selectTuning(tuning.id);
                  },
                  onLongPress: () {
                    if (section == 0) {
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
              },
              headerInSection: (section) {
                var titleCt = Container(
                  padding: EdgeInsets.all(20),
                  child: Text(
                      section == 0 ? i18n.customTunings : i18n.commonTunings,
                      style: theme.textTheme.caption
                  ),
                );

                if (section == 0) {
                  return titleCt;
                }
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 20,),
                    Container(
                      color: theme.dividerColor,
                      height: 0.5
                    ),
                    titleCt
                  ],
                );
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