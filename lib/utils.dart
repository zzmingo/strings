
import 'package:flutter/widgets.dart';

class Sizes {

  static int designW = 640;

  static double screenW = 640;

  static void init(BuildContext context) {
    screenW = MediaQuery.of(context).size.width;
  }

  static double width(int width) {
    return width / designW * screenW;
  }

}

class DisplayHelper {

  static double _pitchRange = 10;
  static double _pitchScale = 10;

  static String getPitchDeltaText(pitch, targetPitch) {
    var pitchDelta = ((pitch - targetPitch) * _pitchScale).ceil();
    if (pitchDelta < -999) {
      pitchDelta = -999;
    } else if (pitchDelta > 999) {
      pitchDelta = 999;
    }
    var pitchText = pitchDelta.toString();
    if (pitchDelta > 0) {
      pitchText = "+$pitchDelta";
    }
    return pitchText;
  }

  static double getOffsetX(BuildContext context, pitch, targetPitch) {
    double deltaPitch = pitch - targetPitch;
    double width = MediaQuery.of(context).size.width;
    double offset = width / 2 * deltaPitch / _pitchRange;
    if (offset < - width / 2) {
      offset = - width / 2 + 20;
    } else if (offset > width / 2) {
      offset = width / 2 - 20;
    }
    return offset;
  }

}