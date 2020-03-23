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
    var i18n = StringsLocalizations.of(context);
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
      textStyle: TextStyle(fontSize: 24, fontFamily: "Kiddemo"),
      selectedTextStyle: TextStyle(color: theme.accentColor, fontSize: 24, fontFamily: "Kiddemo"),
      onConfirm: (Picker picker, List value) {
        confirmed = true;
      },
    );
    await picker.showModal(context);
    if (confirmed) {
      _stringsController.text = picker.getSelectedValues().join(",").replaceAll("y", "#");
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Add custom tuning'),
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
                  labelText: "Tuning",
                  hintText: "Name for this tuning",
                  prefixIcon: Icon(Icons.edit)
                ),
                validator: (v) {
                  return v.trim().length > 0 ? null : "Name cannot be empty.";
                },
              ),
              TextFormField(
                controller: _stringsController,
                decoration: InputDecoration(
                  labelText: "Strings",
                  hintText: "Strings for this tuning",
                  prefixIcon: Icon(Icons.sort),
                ),
                readOnly: true,
                validator: (v) {
                  return v.trim().length > 0 ? null : "Please select strings.";
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
                        child: Text("OK"),
                        textColor: Colors.white,
                        onPressed: () {
                          if((_formKey.currentState as FormState).validate()) {
                            Tuning tuning = Tuning();
                            tuning.id = "tuning_${DateTime.now().millisecondsSinceEpoch}";
                            tuning.name = _nameController.text.trim();
                            tuning.notes = _stringsController.text.replaceAll("#", "♯").split(",");
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