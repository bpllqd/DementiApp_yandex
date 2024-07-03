part of 'todo_list_bloc.dart';

abstract class ToDoListState extends Equatable {
  @override
  String toString() {
    return runtimeType.toString();
  }
}

class ToDoListInitState extends ToDoListState {
  @override
  List<Object?> get props => [];
}

class LoadingState extends ToDoListState {
  @override
  List<Object?> get props => [];
}

class CreateInProgressState extends ToDoListState {
  final TaskEntity? task;

  CreateInProgressState({this.task});
  @override
  List<Object?> get props => [task];
}

class EditInProgressState extends ToDoListState {
  final TaskEntity task;

  EditInProgressState({required this.task});
  @override
  List<Object?> get props => [task];
}

class CreatingSuccessState extends ToDoListState {
  @override
  List<Object?> get props => [];
}

class EditingSuccessState extends ToDoListState {
  @override
  List<Object?> get props => [];
}

class SuccessState extends ToDoListState {
  final List<TaskEntity> tasks;
  final int completedTasks;
  final TasksFilter filter;
  List<TaskEntity> get filteredTasks => filter.applyFilter(tasks);

  SuccessState({
    required this.tasks,
    required this.completedTasks,
    this.filter = TasksFilter.showAll,
  });

  @override
  List<Object?> get props => [tasks, completedTasks, filter];
}

class ErrorState extends ToDoListState {
  final String errorDescription;

  ErrorState({required this.errorDescription});

  @override
  List<Object?> get props => [errorDescription];
}
