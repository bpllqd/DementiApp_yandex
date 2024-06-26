import 'package:equatable/equatable.dart';

class TaskEntity extends Equatable{
  final String id; //TODO: завести Uuid?
  final String text;
  final String importance;
  final DateTime? deadline;
  final bool done;

  const TaskEntity({
    required this.id,
    required this.text,
    required this.importance,
    this.deadline,
    required this.done,
    });
    
      @override
      List<Object?> get props => [
        id,
        text,
        importance,
        deadline,
        done,
      ];
}