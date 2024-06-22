part of 'todo_list_bloc.dart';

abstract class ToDoListState extends Equatable {
  const ToDoListState();
}

class ToDoListInitialState extends ToDoListState {
  @override
  List<Object?> get props => [];
}

class ToDoListLoadingState extends ToDoListState {
  @override
  List<Object?> get props => [];
}

class TodoListSuccessState extends ToDoListState {
  final List<TaskEntity>? tasks;
  final int? completedTasks;
  final TaskFilter filter;
  List<TaskEntity> get filteredTasks => filter.applyFilter(tasks ?? []);

  const TodoListSuccessState(
      {required this.tasks,
      required this.completedTasks,
      this.filter = TaskFilter.showAll});

  @override
  List<Object?> get props => [tasks ?? '', completedTasks ?? 0, filter];
}

class ToDoListErrorState extends ToDoListState {
  final String errorDescription;

  const ToDoListErrorState({required this.errorDescription});

  @override
  List<Object?> get props => [errorDescription];
}
