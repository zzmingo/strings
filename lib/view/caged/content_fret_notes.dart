import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:strings/i10n/localization_intl.dart';
import 'package:strings/model/fretboard.dart';
import 'package:strings/view/caged/helper.dart';
import 'package:strings/view/cells.dart';

class FretNotesContent extends StatefulWidget {
  @override
  _FretNotesContentState createState() => _FretNotesContentState();
}

enum _Item {
  AllFretboardNotes,
}

class _FretNotesContentState extends State<FretNotesContent> {

  int _selectedItem = -1;

  String _getItemLabel(_Item item) {
    switch (item) {
      case _Item.AllFretboardNotes: return "全部音";
      default: return null;
    }
  }

  void _onItemClick(int index) {
    var item = _Item.values[index];
    var fretboardModel = Provider.of<FretboardModel>(context, listen: false);
    switch (item) {
      default:
        setState(() {
          _selectedItem = index;
          var allNotes = Helper.getAllFretboardNotes();
          fretboardModel.setFretboard(allNotes, null);
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    var i18n = StringsLocalizations.of(context);
    return ListView.builder(
      itemCount: _Item.values.length,
      itemBuilder: (context, index) {
        return CellRow(
          selectable: true,
          selected: index == _selectedItem,
          onTap: () {
            _onItemClick(index);
          },
          children: <Widget>[
            SizedBox(width: 10),
            Expanded(
              flex: 1,
              child: Text(_getItemLabel(_Item.values[index])),
            ),
          ],
        );
      }
    );
  }
}