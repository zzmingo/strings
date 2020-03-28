import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';
import 'package:provider/provider.dart';
import 'package:strings/model/fretboard.dart';
import 'package:strings/utils.dart';
import 'package:strings/view/caged/helper.dart';

class Fretboard extends StatefulWidget {
  @override
  _FretboardState createState() => _FretboardState();
}

class _FretboardState extends State<Fretboard> {

  final ValueNotifier<Matrix4> notifier = ValueNotifier(Matrix4.identity());
  Matrix4 matrix = Matrix4.identity();

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var imageW = 2238;
    var imageH = 1176;
    var containerH = Sizes.screenW * imageH / imageW;

    return Container(
      color: theme.primaryColorDark,
      width: Sizes.screenW,
      height: containerH,
      child: MatrixGestureDetector(
        shouldRotate: false,
        focalPointAlignment: Alignment.center,
        onMatrixUpdate: (m, tm, sm, rm) {
          matrix = MatrixGestureDetector.compose(matrix, tm, sm, null);
          var scale = matrix.storage[0];
          var minScale = 1;
          var maxScale = 2.2;
          if (scale < minScale) {
            matrix.scale(minScale/scale, minScale/scale, minScale/scale);
            scale = matrix.storage[0];
          } else if (scale >= maxScale) {
            matrix.scale(maxScale/scale, maxScale/scale, maxScale/scale);
            scale = matrix.storage[0];
          }

          var xy = matrix.getTranslation();
          var fixY = (-containerH * (scale - 1) / 2 - xy.y) / scale;
          var max = 50;
          var min = -50 - Sizes.screenW * (scale - 1);
          if (xy.x > 50) {
            matrix.translate(max - xy.x, fixY);
          } else if (xy.x < min) {
            matrix.translate(min - xy.x, fixY);
          } else {
            matrix.translate(0.0, fixY);
          }
          notifier.value = matrix;
        },
        child: AnimatedBuilder(
          animation: notifier,
          builder: (ctx, child) {
            return Transform(
              transform: notifier.value,
              child: _buildZoomBody(context),
            );
          },
        ),
      ),
    );
  }

  Widget _buildZoomBody(BuildContext context) {
    var imageW = 2238;
    var imageH = 1176;
    var containerH = Sizes.screenW * imageH / imageW;
    var noteW = 12.0;
    var noteH = 8.0;
    return Consumer<FretboardModel>(
      builder: (context, model, child) {
        var children = List<Widget>();
        children.add(Image(
          image: AssetImage("assets/jita-fretboard2.png"),
        ));
        children.addAll([3, 5, 7, 9, 12, 15].map((pos) {
          var note = Helper.getFretboardNode(pos, 5);
          return Positioned(
            left: note.x / imageW * Sizes.screenW - noteW / 2-4,
            top: note.y / imageH * containerH - noteH / 2 + 16,
            width: 16,
            height: 12,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.green[900],
                borderRadius: BorderRadius.circular(2),
              ),
              child: Center(
                child: Text("${note.fret}", style: TextStyle(fontSize: 10, fontFamily: "LabelFont")),
              ),
            ),
          );
        }));
        children.addAll(model.primaryList.map((item) {
          var offset = item.note.length == 1 ? Offset(noteW / 2 - 1.5, -1.5) : Offset(noteW / 2 - 3.5, -3.5);
          var fontSize = item.note.length == 1 ? 10.0 : 9.0;
          return Positioned(
            left: item.x / imageW * Sizes.screenW - noteW / 2 - 2,
            top: item.y / imageH * containerH - noteH / 2 - 1,
            width: noteW,
            height: noteH,
            child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.green[400],
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Transform.translate(
                  offset: offset,
                  child: Text(
                    item.note,
                    overflow: TextOverflow.visible,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      fontFamily: "NoteFont",
                      letterSpacing: -2.5,
                    ),
                  ),
                )),
          );
        }));
        return Stack(
          children: children,
        );
      },
    );
  }
}
