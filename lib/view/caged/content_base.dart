import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:strings/model/fretboard.dart';
import 'package:strings/view/caged/helper.dart';
import 'package:strings/view/cells.dart';

abstract class BaseContentState<T extends StatefulWidget> extends State<T> {

  FretboardModel _fretboardModel;
  var _rootMap = Map<FretboardType, String>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fretboardModel = Provider.of<FretboardModel>(context, listen: false);
  }

  @override
  void dispose() {
    super.dispose();
    _fretboardModel.setFretboard(FretboardType.Empty, notify: false );
  }

  List<FretboardType> getDisplayFretboardTypes();

  bool isTypeofScale(FretboardType type);

  @override
  Widget build(BuildContext context) {
    return Consumer<FretboardModel>(builder: (context, model, child) {
      var types = getDisplayFretboardTypes();
      return ListView.builder(
          itemCount: types.length,
          itemBuilder: (context, index) {
            var type = types[index];
            var children = <Widget>[
              SizedBox(width: 10),
              Text(Helper.getFretboardTypeLabel(context, type)),
              Expanded(flex: 1, child: Container()),
            ];
            if (type == FretboardType.AllFretboardNotes) {
              return CellRow(
                selectable: true,
                selected: index == model.typeIndex - 1,
                onTap: () {
                  model.setFretboard(type);
                },
                children: children,
              );
            }

            var widget;
            var isScale = isTypeofScale(type);


            if (isScale) {
              var root = _rootMap[type];
              var notes = FretboardHelper.getNoteSequence();
              if (root == null) {
                root = _rootMap[type] = notes[0];
              }
              children.add(PopupMenuButton<String>(
                initialValue: root,
                child: Row(
                  children: <Widget>[
                    Text("根音: $root"),
                    Icon(Icons.arrow_drop_down)
                  ],
                ),
                itemBuilder: (context) {
                  return notes.map((note) {
                    return PopupMenuItem<String>(value: note, child: Text(note));
                  }).toList();
                },
                onSelected: (value) {
                  _rootMap[type] = value;
                  model.setFretboard(type, root: value);
                },
              ));
              children.add(SizedBox(width: 20));

              return CellRow(
                selectable: true,
                selected: index == model.typeIndex - 1,
                onTap: () {
                  model.setFretboard(type, root: _rootMap[type]);
                },
                children: children,
              );
            }

            return widget;
          }
      );
    });
  }
}