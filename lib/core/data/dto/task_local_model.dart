import 'package:demetiapp/core/domain/entities/task_entity.dart';

class TaskLocalModel extends TaskEntity {
  const TaskLocalModel({
    required super.id,
    required super.text,
    required super.importance,
    required super.done,
    super.deadline,
    super.color,
    required super.lastUpdatedBy,
    required super.changedAt,
    required super.createdAt,
  });

  factory TaskLocalModel.fromJson(Map<String, dynamic> json) {
    return TaskLocalModel(
      id: json['id'] as String,
      text: json['text'] as String,
      importance: json['importance'] as String,
      done: json['done'] as bool,
      color: json['color'] != null ? json['color'] as String : null,
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'] as String)
          : null,
      lastUpdatedBy: json['last_updated_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      changedAt: DateTime.parse(json['changed_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'importance': importance,
      'done': done,
      'color': color,
      'deadline': deadline?.toIso8601String(),
      'changed_at': changedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'last_updated_by': lastUpdatedBy,
    };
  }

  factory TaskLocalModel.fromEntity(TaskEntity entity) {
    return TaskLocalModel(
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

class TaskLocalModelWithRevision {
  final List<TaskLocalModel> listTasks;
  final int localRevision;

  TaskLocalModelWithRevision({
    required this.listTasks,
    required this.localRevision,
  });
}
