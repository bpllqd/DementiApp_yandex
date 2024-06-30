part of 'todo_create_bloc.dart';

abstract class ToDoCreateEvent extends Equatable {}

class ToDoCreateInitEvent extends ToDoCreateEvent {
  @override
  List<Object?> get props => [];
}

class ToDoCreateNewEvent extends ToDoCreateEvent {
  final TaskEntity task;

  ToDoCreateNewEvent(this.task);

  @override
  List<Object> get props => [task];
}

class ToDoCreateDeleteEvent extends ToDoCreateEvent {
  final TaskEntity task;

  ToDoCreateDeleteEvent(this.task);

  @override
  List<Object> get props => [task];
}

class ToDoCreateEditEvent extends ToDoCreateEvent {
  final TaskEntity task;

  ToDoCreateEditEvent({required this.task});

  @override
  List<Object?> get props => [task];
}

class ToDoCreateSwitchDateEvent extends ToDoCreateEvent {
  final TaskEntity? task;

  ToDoCreateSwitchDateEvent(this.task);
  @override
  List<Object?> get props => [task];
}
