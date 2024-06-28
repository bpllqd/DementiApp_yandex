import 'package:demetiapp/core/data/models/task_local_model.dart';
import 'package:demetiapp/core/data/models/task_api_model.dart';
import 'package:equatable/equatable.dart';

class TaskEntity extends Equatable {
  final String id;
  final String text;
  final String importance;
  final DateTime? deadline;
  final bool done;
  final DateTime? createdAt;
  final DateTime? changedAt;
  final String lastUpdatedBy;

  const TaskEntity({
    required this.id,
    required this.text,
    required this.importance,
    this.deadline,
    required this.done,
    this.createdAt,
    this.changedAt,
    required this.lastUpdatedBy,
  });

  @override
  List<Object?> get props => [
        id,
        text,
        importance,
        deadline,
        done,
        createdAt,
        changedAt,
        lastUpdatedBy,
  ];

  TaskEntity copyWith({
    String? id,
    String? text,
    String? importance,
    DateTime? deadline,
    bool? done,
    DateTime? createdAt,
    DateTime? changedAt,
    String? lastUpdatedBy,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      text: text ?? this.text,
      importance: importance ?? this.importance,
      deadline: deadline ?? this.deadline,
      done: done ?? this.done,
      createdAt: createdAt ?? this.createdAt,
      changedAt: changedAt ?? this.changedAt,
      lastUpdatedBy: lastUpdatedBy ?? this.lastUpdatedBy,
    );
  }

  factory TaskEntity.fromLocalModel(TaskLocalModel model) {
    return TaskEntity(
      id: model.id,
      text: model.text,
      importance: model.importance,
      deadline: model.deadline,
      done: model.done,
      createdAt: model.createdAt,
      changedAt: model.changedAt,
      lastUpdatedBy: model.lastUpdatedBy,
    );
  }

  factory TaskEntity.fromApiModel(TaskApiModel model) {
    return TaskEntity(
      id: model.id,
      text: model.text,
      importance: model.importance,
      deadline: model.deadline,
      done: model.done,
      createdAt: model.createdAt,
      changedAt: model.changedAt,
      lastUpdatedBy: model.lastUpdatedBy,
    );
  }
}
