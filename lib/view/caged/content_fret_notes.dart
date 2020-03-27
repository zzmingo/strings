import 'package:flutter/widgets.dart';
import 'package:flutter_section_table_view/flutter_section_table_view.dart';

class FretNotesContent extends StatefulWidget {
  @override
  _FretNotesContentState createState() => _FretNotesContentState();
}
class _FretNotesContentState extends State<FretNotesContent> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SectionTableView(
      sectionCount: 1,
      numOfRowInSection: (sectionIdx) {
        return 2;
      },
      cellAtIndexPath: (section, row) {
        switch (row) {
          case 0:
            return Container();
          case 1:
            return Container();
          default:
            return null;
        }
      },
    );
  }
}