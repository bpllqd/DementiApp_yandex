import 'package:demetiapp/core/domain/entities/task_entity.dart';

class TaskLocalModel extends TaskEntity {
  const TaskLocalModel({
    required super.id,
    required super.text,
    required super.importance,
    required super.done,
    super.deadline,
    required super.lastUpdatedBy,
    super.changedAt,
    super.createdAt,
  });

  factory TaskLocalModel.fromJson(Map<String, dynamic> json) {
    return TaskLocalModel(
      id: json['id'] as String,
      text: json['text'] as String,
      importance: json['importance'] as String,
      done: json['done'] as bool,
      deadline: DateTime.parse(json['deadline'] as String),
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
      'deadline': deadline?.toIso8601String(),
      'changedAt': changedAt?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'lastUpdatedBy': lastUpdatedBy,
    };
  }

  factory TaskLocalModel.fromEntity(TaskEntity entity) {
    return TaskLocalModel(
      id: entity.id,
      text: entity.text,
      importance: entity.importance,
      deadline: entity.deadline,
      done: entity.done,
      createdAt: entity.createdAt,
      changedAt: entity.changedAt,
      lastUpdatedBy: entity.lastUpdatedBy,
    );
  }
}

class TaskLocalModelWithRevision {
  final List<TaskLocalModel>? listTasks;
  final TaskLocalModel? oneTask;
  final int localRevision;

  TaskLocalModelWithRevision({
    this.listTasks,
    this.oneTask,
    required this.localRevision,
  });
}
