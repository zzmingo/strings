import 'package:json_annotation/json_annotation.dart';

part 'common.g.dart';

@JsonSerializable()
class Note {

  double pitch;
  String name;
  int octave;

  Note();

  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);
  Map<String, dynamic> toJson() => _$NoteToJson(this);
}

@JsonSerializable()
class Tuning {
  String id;
  String name;
  List<String> notes;

  Tuning();

  factory Tuning.fromJson(Map<String, dynamic> json) => _$TuningFromJson(json);
  Map<String, dynamic> toJson() => _$TuningToJson(this);
}