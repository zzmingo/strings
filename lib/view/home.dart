import 'package:flutter/material.dart';
import 'package:strings/events.dart';
import 'package:strings/i10n/localization_intl.dart';
import 'package:strings/utils.dart';
import 'package:strings/view/metronome/metronome.dart';
import 'package:strings/view/tuner/tuner.dart';

import 'caged/caged.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

enum _Page {
  Home,
  Tuner,
  Metronome,
  CAGEDSystem,
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {

  _Page _page;

  @override
  void initState() {
    super.initState();
    _page = _Page.Home;
  }

  IconData _getMenuIcon(_Page page) {
    switch (page) {
      case _Page.Tuner: return Icons.room;
      case _Page.Metronome: return Icons.nature;
      case _Page.CAGEDSystem: return Icons.category;
      default: return Icons.home;
    }
  }

  String _getPageTitle(_Page page, bool drawer) {
    var i18n = StringsLocalizations.of(context);
    switch (page) {
      case _Page.Tuner: return i18n.tuner;
      case _Page.Metronome: return i18n.metronome;
      case _Page.CAGEDSystem: return i18n.CAGEDSystem;
      default: return drawer ? i18n.home : i18n.appName;
    }
  }

  void _toSettingsPage(_Page page) {
    eventBus.emit(Events.SettingClicked);
  }

  void _switchPage(_Page page) {
    setState(() {
      _page = page;
    });
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    Sizes.init(context);
    return Scaffold(
      drawer: Drawer(
        child: _buildDrawerBody(context),
      ),
      appBar: AppBar(
        title: Text(
          _getPageTitle(_page, false),
          style: TextStyle(fontFamily: _page == _Page.Home ? "LogoFont" : "LabelFont"),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                _toSettingsPage(_page);
              }
          ),
        ],
      ),
      body: _buildPageBody(context),
    );
  }

  Widget _buildPageBody(BuildContext context) {
    switch (_page) {
      case _Page.Tuner: return TunerPage();
      case _Page.Metronome: return MetronomePage();
      case _Page.CAGEDSystem: return CagedPage();
      default: return _buildHomePage(context);
    }
  }

  Widget _buildHomePage(BuildContext context) {
    var theme = Theme.of(context);
    var children = List<Widget>();
    _Page.values.forEach((page) {
      if (page == _Page.Home) {
        return;
      }
      children.add(InkWell(
        onTap: () {
          _switchPage(page);
        },
        child: Container(
          color: theme.cardColor,
          child: Column(
            children: <Widget>[
              Expanded(flex: 3, child: Container(),),
              Icon(_getMenuIcon(page), size: 38,),
              Expanded(flex: 1, child: Container(),),
              Text(_getPageTitle(page, false)),
              Expanded(flex: 3, child: Container(),),
            ],
          ),
        ),
      ));
    });
    return Container(
      child: GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 1,
        children: children,
        padding: EdgeInsets.all(20),
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
      ),
    );
  }

  Widget _buildDrawerBody(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: _Page.values.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildDrawerHeader(context);
        } else {
          var page = _Page.values[index - 1];
          return ListTile(
            title: Text(_getPageTitle(page, true)),
            leading: Icon(_getMenuIcon(page)),
            trailing: _page == page ? Icon(Icons.check) : null,
            selected: _page == page,
            onTap: () {
              _switchPage(page);
            },
          );
        }
      }
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    var i18n = StringsLocalizations.of(context);
    return DrawerHeader(
      padding: EdgeInsets.fromLTRB(0, 30, 0, 20),
      child: Column(
        children: <Widget>[
          Text(i18n.appName, style: TextStyle(fontFamily: "LogoFont", fontSize: 24)),
          Expanded(
            flex: 1,
            child: Container(),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                FlatButton.icon(
                    onPressed: () {

                    },
                    icon: Icon(Icons.share),
                    label: Text(
                      i18n.share,
                    )
                ),
                FlatButton.icon(
                    onPressed: () {

                    },
                    icon: Icon(Icons.monetization_on),
                    label: Text(
                      i18n.appreciate,
                    )
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

}
