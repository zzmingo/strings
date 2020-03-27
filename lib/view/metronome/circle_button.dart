import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CircleButton extends StatefulWidget {

  const CircleButton({
    @required this.onPressed,
    this.icon,
    this.text,
    this.size = 120,
  });

  final VoidCallback onPressed;
  final IconData icon;
  final String text;
  final double size;

  @override
  _CircleButtonState createState() => _CircleButtonState();

}

class _CircleButtonState extends State<CircleButton> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return SizedBox(
        width: widget.size,
        height: widget.size,
        child: RawMaterialButton(
          shape: RoundedRectangleBorder(
            side: BorderSide(color: theme.dividerColor),
            borderRadius: BorderRadius.circular(widget.size / 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(widget.icon, size: widget.size / 4),
              SizedBox(height: widget.size / 20),
              Text(
                  widget.text,
                  style: TextStyle(
                    fontSize: widget.size / 4,
                    fontWeight: FontWeight.bold,
                  )),
            ],
          ),
          onPressed: widget.onPressed,
        ));
  }
}