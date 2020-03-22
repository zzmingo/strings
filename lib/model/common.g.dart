// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'common.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Note _$NoteFromJson(Map<String, dynamic> json) {
  return Note()
    ..pitch = (json['pitch'] as num)?.toDouble()
    ..name = json['name'] as String
    ..octave = json['octave'] as int;
}

Map<String, dynamic> _$NoteToJson(Note instance) => <String, dynamic>{
      'pitch': instance.pitch,
      'name': instance.name,
      'octave': instance.octave
    };

Tuning _$TuningFromJson(Map<String, dynamic> json) {
  return Tuning()
    ..id = json['id'] as String
    ..name = json['name'] as String
    ..notes = (json['notes'] as List)?.map((e) => e as String)?.toList();
}

Map<String, dynamic> _$TuningToJson(Tuning instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'notes': instance.notes
    };
