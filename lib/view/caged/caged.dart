import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:strings/view/caged/content_chord.dart';
import 'package:strings/view/caged/content_fret_notes.dart';
import 'package:strings/view/caged/fretboard.dart';

class CagedPage extends StatefulWidget {
  @override
  _CagedPageState createState() => _CagedPageState();
}

enum _Tab {
  FretNotes,
  Chord,
}

class _CagedPageState extends State<CagedPage> with SingleTickerProviderStateMixin {

  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _Tab.values.length, vsync: this);
  }

  String _getTabTitle(_Tab tab) {
    switch (tab) {
      case _Tab.FretNotes: return "Fretboard Notes";
      case _Tab.Chord: return "Chord";
      default: return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Fretboard(),
          _buildTabBar(context),
          _buildTabBarView(context),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return TabBar(
        controller: _tabController,
        tabs: _Tab.values.map((tab) => Tab(text: _getTabTitle(tab))).toList()
    );
  }

  Widget _buildTabBarView(BuildContext context) {
    return Expanded(
      flex: 1,
      child: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: _tabController,
        children: _Tab.values.map((tab) { //创建3个Tab页
          switch (tab) {
            case _Tab.FretNotes: return FretNotesContent();
            case _Tab.Chord: return ChordContent();
            default: return null;
          }
        }).toList(),
      ),
    );
  }
}