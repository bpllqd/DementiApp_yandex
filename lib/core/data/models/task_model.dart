import 'package:demetiapp/core/domain/entities/task_entity.dart';


class TaskModel extends TaskEntity{
  const TaskModel({required super.id, required super.text, required super.importance, required super.done, super.deadline});

  factory TaskModel.fromJson(Map<String, dynamic> json){
    return TaskModel(
      id: json['id'] as String,
      text: json['text'] as String,
      importance: json['importance'] as String,
      done: json['done'] as bool,
      deadline: DateTime.parse(json['deadline'] as String),
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'id': id,
      'text': text,
      'importance': importance,
      'done':done,
      'deadline':deadline==null ? '' : deadline!.toUtc(), //спорный момент
    };
  }
}