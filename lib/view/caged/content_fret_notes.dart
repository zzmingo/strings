import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:strings/model/fretboard.dart';
import 'package:strings/view/caged/helper.dart';
import 'package:strings/view/cells.dart';

class FretNotesContent extends StatefulWidget {
  @override
  _FretNotesContentState createState() => _FretNotesContentState();
}

class _FretNotesContentState extends State<FretNotesContent> {

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

  @override
  Widget build(BuildContext context) {
    return Consumer<FretboardModel>(builder: (context, model, child) {
      return ListView.builder(
        itemCount: FretboardType.values.length - 1,
        itemBuilder: (context, index) {
          var children = <Widget>[
            SizedBox(width: 10),
            Text(Helper.getFretboardTypeLabel(context, FretboardType.values[index+1])),
            Expanded(flex: 1, child: Container()),
          ];
          var type = FretboardType.values[index+1];
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
          var isScale = type == FretboardType.RootNote ||
              type == FretboardType.MajorScale ||
              type == FretboardType.MinorScale ||
              type == FretboardType.PentatonicMajorScale ||
              type == FretboardType.PentatonicMinorScale;


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