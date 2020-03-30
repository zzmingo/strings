import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:strings/model/fretboard.dart';
import 'package:strings/view/caged/content_base.dart';

class FretboardNotesContent extends StatefulWidget {
  @override
  _FretboardNotesContentState createState() => _FretboardNotesContentState();
}

class _FretboardNotesContentState extends BaseContentState<FretboardNotesContent> {

  @override
  bool isTypeofScale(FretboardType type) {
    return type == FretboardType.RootNote ||
        type == FretboardType.MajorScale ||
        type == FretboardType.MinorScale ||
        type == FretboardType.PentatonicMajorScale ||
        type == FretboardType.PentatonicMinorScale;
  }

  @override
  List<FretboardType> getDisplayFretboardTypes() {
    return [
      FretboardType.AllFretboardNotes,
      FretboardType.RootNote,
      FretboardType.MajorScale,
      FretboardType.MinorScale,
      FretboardType.PentatonicMajorScale,
      FretboardType.PentatonicMinorScale,
    ];
  }

}