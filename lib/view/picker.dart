import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:strings/i10n/localization_intl.dart';

class Pickers {

  static void showDialog(BuildContext context, {
    double height = 200,
    double itemExtent = 40,
    hideHeader = true,
    List<int> selecteds,
    String title,
    @required PickerAdapter adapter,
    PickerConfirmCallback onConfirm,
  }) {
    var theme = Theme.of(context);
    var i18n = StringsLocalizations.of(context);
    Picker picker = new Picker(
        adapter: adapter,
        height: height,
        itemExtent: itemExtent,
        selecteds: selecteds,
        hideHeader: true,
        title: Text(title),
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
        onConfirm: onConfirm
    );
    picker.showDialog(context);
  }

}