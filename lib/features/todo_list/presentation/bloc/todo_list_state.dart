part of 'todo_list_bloc.dart';

abstract class ToDoListState extends Equatable {}

class ToDoListInitialState extends ToDoListState {
  @override
  List<Object?> get props => [];
}

class ToDoListLoadingState extends ToDoListState {
  @override
  List<Object?> get props => [];
}

class TodoListSuccessState extends ToDoListState {
  final List<TaskEntity> tasks;
  final int completedTasks;
  final TasksFilter filter;
  List<TaskEntity> get filteredTasks => filter.applyFilter(tasks);

  TodoListSuccessState({
    required this.tasks,
    required this.completedTasks,
    this.filter = TasksFilter.showAll,
  });

  @override
  List<Object?> get props => [tasks, completedTasks, filter];
}

class ToDoListErrorState extends ToDoListState {
  final String errorDescription;

  ToDoListErrorState({required this.errorDescription});

  @override
  List<Object?> get props => [errorDescription];
}
