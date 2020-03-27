
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:strings/model/tuner.dart';

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

  static List<String> allNotes;

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

  static List<int> getStringsSelects(BuildContext context) {
    _ensureAllNotes(context);
    return "E2 A2 D3 G3 B3 E4".split(" ").map((note) {
      return allNotes.indexOf(note);
    }).toList();
  }

  static dynamic getStringsPickerData(BuildContext context) {
    _ensureAllNotes(context);
    return [
      allNotes,
      allNotes,
      allNotes,
      allNotes,
      allNotes,
      allNotes,
    ];
  }

  static void _ensureAllNotes(BuildContext context) {
    var tunerModel = Provider.of<TunerModel>(context, listen: false);
    if (allNotes == null) {
      var noteMap = tunerModel.noteMap;
      allNotes = noteMap.keys.toList();
      allNotes.sort((a, b) {
        var aNote = noteMap[a];
        var bNote = noteMap[b];
        return aNote.pitch - bNote.pitch > 0 ? 1 : -1;
      });
    }
  }

  static List<int> getMeterColumnWeights(String meter) {
    List<int> columns;
    switch (meter) {
      case "1/4": columns = [3]; break;
      case "2/4": columns = [3,0,1]; break;
      case "3/4": columns = [3,0,1,0,1]; break;
      case "4/4": columns = [3,0,1,0,2,0,1]; break;
      case "3/8": columns = [3,0,1,0,1]; break;
      case "6/8": columns = [3,0,1,0,1,0,2,0,1,0,1]; break;
      default:    columns = [3,0,1,0,2,0,1];
    }
    return columns;
  }

//  static String getBeatingSoundName(String key) {
//    switch (key) {
//      case "knock": return "物理";
//      default: return "未知";
//    }
//  }

//  static String getBeatingName(String beatingId) {
//    var beatingData = GlobalData.beatingMap[beatingId];
//    if (beatingData.mode == BEATING_MODE_INTERVAL_BPM) {
//      var d = beatingData;
//      return "渐变 ${d.step > 0 ? "+${d.step}" : d.step} ${d.fromBpm}~${d.toBpm}/${d.interval}";
//    } else {
//      return "无限循环";
//    }
//  }

}