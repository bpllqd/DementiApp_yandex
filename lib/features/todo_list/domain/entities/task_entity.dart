import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_entity.freezed.dart';
part 'task_entity.g.dart';

enum Priority { no, low, high }

@freezed
class TaskEntity with _$TaskEntity {
  const factory TaskEntity({
    required String taskID,
    required String title, 
    required bool done,
    required Priority? priority,
    final DateTime? date, 
  }) = _TaskEntity;

  factory TaskEntity.fromJson(Map<String, Object?> json)
      => _$TaskEntityFromJson(json);
}