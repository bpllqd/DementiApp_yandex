part of 'todo_list_bloc.dart';

abstract class ToDoListEvent extends Equatable {
  const ToDoListEvent();

  @override
  List<Object> get props => [];
}

class GetTasksEvent extends ToDoListEvent {
  const GetTasksEvent();
}

class QuickAddNewTaskEvent extends ToDoListEvent {
  final TaskEntity task;

  const QuickAddNewTaskEvent(this.task);

  @override
  List<Object> get props => [task];
}

class DeleteTaskEvent extends ToDoListEvent {
  final String uuid;

  const DeleteTaskEvent(this.uuid);

  @override
  List<Object> get props => [uuid];
}

class CompleteTaskEvent extends ToDoListEvent {
  final TaskEntity task;

  const CompleteTaskEvent(this.task);

  @override
  List<Object> get props => [task];
}

class ChangeFilterEvent extends ToDoListEvent {
  final TaskFilter filter;

  const ChangeFilterEvent(this.filter);

  @override
  List<Object> get props => [filter];
}
