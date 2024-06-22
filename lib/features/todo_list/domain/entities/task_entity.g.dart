// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TaskEntityImpl _$$TaskEntityImplFromJson(Map<String, dynamic> json) =>
    _$TaskEntityImpl(
      taskID: json['taskID'] as String,
      title: json['title'] as String,
      done: json['done'] as bool,
      priority: $enumDecodeNullable(_$PriorityEnumMap, json['priority']),
      date:
          json['date'] == null ? null : DateTime.parse(json['date'] as String),
    );

Map<String, dynamic> _$$TaskEntityImplToJson(_$TaskEntityImpl instance) =>
    <String, dynamic>{
      'taskID': instance.taskID,
      'title': instance.title,
      'done': instance.done,
      'priority': _$PriorityEnumMap[instance.priority],
      'date': instance.date?.toIso8601String(),
    };

const _$PriorityEnumMap = {
  Priority.no: 'no',
  Priority.low: 'low',
  Priority.high: 'high',
};
