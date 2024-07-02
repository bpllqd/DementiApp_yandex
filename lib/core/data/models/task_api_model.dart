import 'package:demetiapp/core/domain/entities/task_entity.dart';

class TaskApiModel extends TaskEntity {
  const TaskApiModel({
    required super.id,
    required super.text,
    required super.importance,
    required super.done,
    super.color,
    super.deadline,
    required super.lastUpdatedBy,
    required super.changedAt,
    required super.createdAt,
  });

  factory TaskApiModel.fromJson(Map<String, dynamic> json) {
    return TaskApiModel(
      id: json['id'] as String,
      text: json['text'] as String,
      importance: json['importance'] as String,
      done: json['done'] as bool,
      color: json['color'] as String?,
      deadline: json['deadline'] != null ? DateTime.fromMillisecondsSinceEpoch(json['deadline'] as int) : null,
      lastUpdatedBy: json['last_updated_by'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at'] as int),
      changedAt: DateTime.fromMillisecondsSinceEpoch(json['changed_at'] as int),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'importance': importance,
      'done': done,
      'color' : color,
      'deadline': deadline?.millisecondsSinceEpoch,
      'changed_at': changedAt.millisecondsSinceEpoch,
      'created_at': createdAt.millisecondsSinceEpoch,
      'last_updated_by': lastUpdatedBy,
    };
  }

  factory TaskApiModel.fromEntity(TaskEntity entity) {
    return TaskApiModel(
      id: entity.id,
      text: entity.text,
      importance: entity.importance,
      deadline: entity.deadline,
      done: entity.done,
      color: entity.color,
      createdAt: entity.createdAt,
      changedAt: entity.changedAt,
      lastUpdatedBy: entity.lastUpdatedBy,
    );
  }
}

class TaskApiModelWithRevision {
  final List<TaskApiModel> listTasks;
  final int apiRevision;

  TaskApiModelWithRevision({
    required this.listTasks,
    required this.apiRevision,
  });
}
