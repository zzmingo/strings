import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CellRow extends StatefulWidget {

  final Key key;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final bool selected;
  final bool selectable;
  final List<Widget> children;
  final EdgeInsets padding;

  CellRow({
    this.key,
    this.selectable = false,
    this.selected = false,
    this.onTap,
    this.onLongPress,
    this.children,
    this.padding = const EdgeInsets.fromLTRB(20, 15, 20, 15),
  });

  @override
  _CellRowState createState() => _CellRowState();
}
class _CellRowState extends State<CellRow> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var children = List<Widget>();
    if (widget.selectable) {
      children.add(SizedBox(
        width: 30,
        child: Icon(Icons.check, color: widget.selected ? theme.primaryIconTheme.color : Colors.transparent),
      ));
      children.add(SizedBox(width: 20));
    }
    children.addAll(widget.children);
    return InkWell(
      key: widget.key,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: AnimatedContainer(
        padding: widget.padding,
        color: widget.selected ? theme.selectedRowColor.withAlpha(0x11) : Colors.transparent,
        duration: Duration(milliseconds: 200),
        child: Row(
          children: children,
        ),
      ),
    );
  }
}