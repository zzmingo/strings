import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:strings/i10n/localization_intl.dart';
import 'package:strings/model/common.dart';
import 'package:strings/utils.dart';

class TuningPage extends StatefulWidget {
  @override
  _TuningPageState createState() => _TuningPageState();
}

class _TuningPageState extends State<TuningPage> {

  GlobalKey _formKey = new GlobalKey<FormState>();
  TextEditingController _nameController = new TextEditingController();
  TextEditingController _stringsController = new TextEditingController();

  _onTapStringsField(BuildContext context) async {
    var theme = Theme.of(context);
    bool confirmed = false;
    Picker picker;
    picker = new Picker(
      adapter: PickerDataAdapter<String>(
        isArray: true,
        pickerdata: DisplayHelper.getStringsPickerData(context),
      ),
      cancel: IconButton(icon: Icon(Icons.close), onPressed: () {
        picker.doCancel(context);
      },),
      confirm: IconButton(icon: Icon(Icons.check), onPressed: () {
        confirmed = true;
        picker.doConfirm(context);
      },),
      height: 300,
      itemExtent: 50,
      selecteds: DisplayHelper.getStringsSelects(context),
      changeToFirst: false,
      textAlign: TextAlign.left,
      columnPadding: const EdgeInsets.all(4.0),
      backgroundColor: theme.canvasColor,
      containerColor: theme.canvasColor,
      headercolor: theme.canvasColor,
      textStyle: TextStyle(fontSize: 24, fontFamily: "NoteFont"),
      selectedTextStyle: TextStyle(color: theme.accentColor, fontSize: 24, fontFamily: "NoteFont"),
      onConfirm: (Picker picker, List value) {
        confirmed = true;
      },
    );
    await picker.showModal(context);
    if (confirmed) {
      _stringsController.text = picker.getSelectedValues().join(" ");
    }
  }

  @override
  Widget build(BuildContext context) {
    var i18n = StringsLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(i18n.addCustomTuning),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          autovalidate: true,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: i18n.tuningName,
                  hintText: i18n.nameForTuning,
                  prefixIcon: Icon(Icons.edit)
                ),
              ),
              TextFormField(
                controller: _stringsController,
                decoration: InputDecoration(
                  labelText: i18n.strings,
                  prefixIcon: Icon(Icons.sort),
                  labelStyle: TextStyle(fontFamily: ""),
                ),
                readOnly: true,
                style: TextStyle(fontFamily: "NoteFont", fontSize: 22),
                validator: (v) {
                  return v.trim().length > 0 ? null : i18n.errorTipsStringsEmpty;
                },
                onTap: () {
                  _onTapStringsField(context);
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 50.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: RaisedButton(
                        padding: EdgeInsets.all(15.0),
                        child: Text(i18n.ok),
                        textColor: Colors.white,
                        onPressed: () {
                          if((_formKey.currentState as FormState).validate()) {
                            Tuning tuning = Tuning();
                            tuning.id = "tuning_${DateTime.now().millisecondsSinceEpoch}";
                            tuning.name = _nameController.text.trim();
                            tuning.notes = _stringsController.text.split(" ");
                            Navigator.pop(context, tuning);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              )
            ],
          )
        ),
      ),
    );
  }
}