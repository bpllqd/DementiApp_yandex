part of 'todo_list_bloc.dart';

abstract class ToDoListEvent extends Equatable {}

class GetTasksEvent extends ToDoListEvent {
  @override
  List<Object?> get props => [];
}

class AddNewTaskEvent extends ToDoListEvent {
  @override
  List<Object> get props => [];
}

class EditTaskEvent extends ToDoListEvent {
  final String taskID;

  EditTaskEvent({required this.taskID});

  @override
  List<Object?> get props => [taskID];
}

class DeleteTaskEvent extends ToDoListEvent {
  final String taskID;

  DeleteTaskEvent(this.taskID);

  @override
  List<Object> get props => [taskID];
}

class CompleteTaskEvent extends ToDoListEvent {
  final String taskID;

  CompleteTaskEvent(this.taskID);

  @override
  List<Object> get props => [taskID];
}

class UnCompleteTaskEvent extends ToDoListEvent {
  final String taskID;

  UnCompleteTaskEvent({required this.taskID});

  @override
  List<Object?> get props => [taskID];
}

class ChangeFilterEvent extends ToDoListEvent {
  final TasksFilter filter;

  ChangeFilterEvent({required this.filter});

  @override
  List<Object> get props => [filter];
}
