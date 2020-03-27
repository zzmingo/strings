import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Fretboard extends StatefulWidget {
  @override
  _FretboardState createState() => _FretboardState();
}

class _FretboardState extends State<Fretboard> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Container(
      color: theme.primaryColorDark,
      child: Image(
        image: AssetImage("assets/jita-fretboard2.png"),
      ),
    );
  }
}