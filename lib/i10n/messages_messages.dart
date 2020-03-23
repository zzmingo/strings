// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a messages locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'messages';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "add" : MessageLookupByLibrary.simpleMessage("Add"),
    "appName" : MessageLookupByLibrary.simpleMessage("Strings"),
    "auto" : MessageLookupByLibrary.simpleMessage("Auto"),
    "cancel" : MessageLookupByLibrary.simpleMessage("Cancel"),
    "commonTunings" : MessageLookupByLibrary.simpleMessage("Common tunings"),
    "confirm" : MessageLookupByLibrary.simpleMessage("Confirm"),
    "confirmDeleteTuning" : MessageLookupByLibrary.simpleMessage("Delete this tuning?"),
    "customTunings" : MessageLookupByLibrary.simpleMessage("Custom tunings"),
    "customTuningsWithTips" : MessageLookupByLibrary.simpleMessage("Custom tunings (long press to delete)"),
    "delete" : MessageLookupByLibrary.simpleMessage("Delete"),
    "noCustomTunings" : MessageLookupByLibrary.simpleMessage("No custom tuning"),
    "noticeTitle" : MessageLookupByLibrary.simpleMessage("Notice"),
    "tuner" : MessageLookupByLibrary.simpleMessage("Tuner"),
    "tunerSettings" : MessageLookupByLibrary.simpleMessage("Tuner Settings"),
    "tuningNameDialogTitle" : MessageLookupByLibrary.simpleMessage("Tuning name")
  };
}
