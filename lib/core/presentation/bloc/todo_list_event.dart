part of 'todo_list_bloc.dart';

abstract class ToDoListEvent extends Equatable {}

class GetTasksEvent extends ToDoListEvent {
  @override
  List<Object?> get props => [];
}

class GetAllEvent extends ToDoListEvent {
  @override
  List<Object?> get props => [];
}

class TaskCompleteEvent extends ToDoListEvent {
  final TaskEntity task;

  TaskCompleteEvent({required this.task});
  @override
  List<Object?> get props => [task];
}

class TaskDeleteEvent extends ToDoListEvent {
  final TaskEntity task;

  TaskDeleteEvent({required this.task});
  @override
  List<Object?> get props => [task];
}

class TaskEditEvent extends ToDoListEvent {
  final TaskEntity task;

  TaskEditEvent({required this.task});
  @override
  List<Object?> get props => [task];
}

class TaskCreateEvent extends ToDoListEvent {
  @override
  List<Object?> get props => [];
}

class ChangeFilterEvent extends ToDoListEvent {
  final List<TaskEntity> tasks;
  final bool filter;
  final int completedTasks;

  ChangeFilterEvent({
    required this.tasks,
    required this.completedTasks,
    required this.filter,
  });
  @override
  List<Object?> get props => [filter];
}

class TaskEditedSaveEvent extends ToDoListEvent {
  final TaskEntity oldTask;
  final TaskEntity newTask;

  TaskEditedSaveEvent({required this.oldTask, required this.newTask});
  @override
  List<Object?> get props => [oldTask, newTask];
}

class TaskCreatedSaveEvent extends ToDoListEvent {
  final TaskEntity task;

  TaskCreatedSaveEvent({required this.task});
  @override
  List<Object?> get props => [task];
}
