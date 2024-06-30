part of 'todo_list_bloc.dart';

abstract class ToDoListEvent extends Equatable {}

class GetTasksEvent extends ToDoListEvent {
  @override
  List<Object?> get props => [];
}

class CreateNavigateTaskEvent extends ToDoListEvent {
  @override
  List<Object?> get props => [];
}

class DeleteTaskEvent extends ToDoListEvent {
  final TaskEntity task;

  DeleteTaskEvent(this.task);

  @override
  List<Object> get props => [task];
}

class CompleteTaskEvent extends ToDoListEvent {
  final TaskEntity task;

  CompleteTaskEvent(this.task);

  @override
  List<Object> get props => [task];
}

class EditNavigateTaskEvent extends ToDoListEvent {
  final TaskEntity task;

  EditNavigateTaskEvent(this.task);

  @override
  List<Object> get props => [task];
}

class ToDoCreateNewEvent extends ToDoListEvent {
  final TaskEntity task;

  ToDoCreateNewEvent(this.task);

  @override
  List<Object> get props => [task];
}

class ToDoCreateEditEvent extends ToDoListEvent {
  final TaskEntity task;

  ToDoCreateEditEvent({required this.task});

  @override
  List<Object?> get props => [task];
}

class UnCompleteTaskEvent extends ToDoListEvent {
  final TaskEntity task;

  UnCompleteTaskEvent({required this.task});

  @override
  List<Object?> get props => [task];
}

class ChangeFilterEvent extends ToDoListEvent {
  final bool filter;

  ChangeFilterEvent({required this.filter});

  @override
  List<Object> get props => [filter];
}
